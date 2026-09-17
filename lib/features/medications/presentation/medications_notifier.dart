import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
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

final class MedicationsNotifier extends StreamNotifier<MedicationsState> {
  @override
  Stream<MedicationsState> build() {
    return ref.watch(vitaliaRepositoryProvider).watchSnapshot().map((result) {
      return switch (result) {
        Ok(:final value) => MedicationsState(
          items: [
            for (final medication in value.medications)
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

  void save(Medication medication, void Function() onSaved) {
    unawaited(_save(medication, onSaved).catchError(_reportUnexpected));
  }

  void delete(String id, void Function() onDeleted) {
    unawaited(_delete(id, onDeleted).catchError(_reportUnexpected));
  }

  Future<void> _save(Medication medication, void Function() onSaved) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .upsertMedication(medication, ref.read(clockProvider).now());
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        onSaved();
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.medications');
    }
  }

  Future<void> _delete(String id, void Function() onDeleted) async {
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .softDeleteMedication(id, ref.read(clockProvider).now());
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        onDeleted();
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.medications');
    }
  }

  void _reportUnexpected(Object error, StackTrace stack) {
    developer.log(
      'medications.intent',
      name: 'vitalia.medications',
      error: error,
      stackTrace: stack,
    );
  }
}

final medicationsNotifierProvider =
    StreamNotifierProvider<MedicationsNotifier, MedicationsState>(
      MedicationsNotifier.new,
    );
