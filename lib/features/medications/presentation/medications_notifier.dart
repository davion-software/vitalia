import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';

@immutable
final class MedicationItemState {
  const MedicationItemState({
    required this.medication,
    required this.scheduleLabel,
    required this.daysLabel,
    required this.quantityLabel,
  });

  final Medication medication;
  final String scheduleLabel;
  final String daysLabel;
  final String? quantityLabel;
}

@immutable
final class MedicationsState {
  const MedicationsState({required this.items, this.failure});

  final List<MedicationItemState> items;
  final StorageFailure? failure;

  Medication? medicationById(String id) {
    for (final item in items) {
      if (item.medication.id == id) return item.medication;
    }
    return null;
  }
}

@immutable
final class MedicationsFeedback {
  const MedicationsFeedback({this.shouldPop = false, this.failure});

  final bool shouldPop;
  final StorageFailure? failure;
}

final class MedicationsFeedbackNotifier extends Notifier<MedicationsFeedback> {
  @override
  MedicationsFeedback build() => const MedicationsFeedback();

  void pop() => state = const MedicationsFeedback(shouldPop: true);

  void fail(StorageFailure failure) =>
      state = MedicationsFeedback(failure: failure);

  void clear() => state = const MedicationsFeedback();
}

final medicationsFeedbackProvider =
    NotifierProvider<MedicationsFeedbackNotifier, MedicationsFeedback>(
      MedicationsFeedbackNotifier.new,
    );

final class MedicationsNotifier extends Notifier<AsyncValue<MedicationsState>> {
  @override
  AsyncValue<MedicationsState> build() {
    return ref.watch(medicationsProvider).whenData((result) {
      return switch (result) {
        Ok(:final value) => MedicationsState(
          items: [
            for (final medication in value)
              MedicationItemState(
                medication: medication,
                scheduleLabel:
                    '${medication.dosage} · ${formatTimes(medication.timesMinutes)}',
                daysLabel: formatDays(medication.daysOfWeek),
                quantityLabel: medication.tracksPills
                    ? medication.needsRefill
                          ? '${medication.quantity} left · refill soon'
                          : '${medication.quantity} left'
                    : null,
              ),
          ],
        ),
        Err(:final failure) => MedicationsState(
          items: const [],
          failure: failure,
        ),
      };
    });
  }

  String createId() => ref.read(idGeneratorProvider)();

  void save(Medication medication) {
    unawaited(
      _save(medication).catchError(
        unexpectedLogger('vitalia.medications', 'medications.intent'),
      ),
    );
  }

  void delete(String id) {
    unawaited(
      _delete(id).catchError(
        unexpectedLogger('vitalia.medications', 'medications.intent'),
      ),
    );
  }

  Future<void> _save(Medication medication) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .upsertMedication(medication, ref.read(clockProvider).now());
    if (!ref.mounted) return;
    _applyWrite(result);
  }

  Future<void> _delete(String id) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .softDeleteMedication(id, ref.read(clockProvider).now());
    if (!ref.mounted) return;
    _applyWrite(result);
  }

  void _applyWrite(Result<void, StorageFailure> result) {
    switch (result) {
      case Ok():
        ref.read(medicationsFeedbackProvider.notifier).pop();
      case Err(:final failure):
        logFailure('vitalia.medications', failure);
        ref.read(medicationsFeedbackProvider.notifier).fail(failure);
    }
  }
}

final medicationsNotifierProvider =
    NotifierProvider<MedicationsNotifier, AsyncValue<MedicationsState>>(
      MedicationsNotifier.new,
    );
