import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';

@immutable
final class TodayState {
  const TodayState({
    required this.nowLabel,
    required this.dateLabel,
    required this.allSlots,
    required this.due,
    required this.later,
    required this.done,
    required this.refillSoon,
    required this.showBanner,
    this.failure,
  });

  factory TodayState.fromSnapshot(Snapshot snapshot, DateTime now) {
    final slots = slotsForDay(
      medications: snapshot.medications,
      events: snapshot.events,
      day: now,
      now: now,
    );
    final due = <DoseSlot>[];
    final later = <DoseSlot>[];
    final done = <DoseSlot>[];
    for (final slot in slots) {
      switch (slot.status) {
        case SlotStatus.due:
        case SlotStatus.missed:
          due.add(slot);
        case SlotStatus.later:
        case SlotStatus.snoozed:
          later.add(slot);
        case SlotStatus.taken:
        case SlotStatus.skipped:
          done.add(slot);
      }
    }
    return TodayState(
      nowLabel: greetingFor(now),
      dateLabel: formatDate(now),
      allSlots: slots,
      due: due,
      later: later,
      done: done,
      refillSoon: snapshot.medications
          .where((item) => item.needsRefill)
          .toList(),
      showBanner: snapshot.settings.banners,
    );
  }

  final String nowLabel;
  final String dateLabel;
  final List<DoseSlot> allSlots;
  final List<DoseSlot> due;
  final List<DoseSlot> later;
  final List<DoseSlot> done;
  final List<Medication> refillSoon;
  final bool showBanner;
  final StorageFailure? failure;

  int get takenCount =>
      done.where((slot) => slot.status == SlotStatus.taken).length;
}

final class TodayNotifier extends StreamNotifier<TodayState> {
  @override
  Stream<TodayState> build() {
    final now =
        ref.watch(currentTimeProvider).value ?? ref.watch(clockProvider).now();
    return ref.watch(vitaliaRepositoryProvider).watchSnapshot().map((result) {
      return switch (result) {
        Ok(:final value) => TodayState.fromSnapshot(value, now),
        Err(:final failure) => TodayState(
          nowLabel: greetingFor(now),
          dateLabel: formatDate(now),
          allSlots: const [],
          due: const [],
          later: const [],
          done: const [],
          refillSoon: const [],
          showBanner: false,
          failure: failure,
        ),
      };
    });
  }

  void take(String slotId) {
    unawaited(_record(slotId, DoseAction.taken).catchError(_reportUnexpected));
  }

  void skip(String slotId) {
    unawaited(
      _record(slotId, DoseAction.skipped).catchError(_reportUnexpected),
    );
  }

  Future<void> _record(String slotId, DoseAction action) async {
    final current = state.value;
    if (current == null) return;
    final slot = current.allSlots
        .where((item) => item.id == slotId)
        .firstOrNull;
    if (slot == null) return;
    final now = ref.read(clockProvider).now();
    final event = DoseEvent(
      id: ref.read(idGeneratorProvider)(),
      medicationId: slot.medication.id,
      medicationName: slot.medication.name,
      scheduledAt: slot.scheduledAt,
      at: now,
      action: action,
    );
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .recordDose(event, decrementQuantity: action == DoseAction.taken);
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.today');
    }
  }

  void _reportUnexpected(Object error, StackTrace stack) {
    developer.log(
      'today.intent',
      name: 'vitalia.today',
      error: error,
      stackTrace: stack,
    );
  }
}

final todayNotifierProvider = StreamNotifierProvider<TodayNotifier, TodayState>(
  TodayNotifier.new,
);
