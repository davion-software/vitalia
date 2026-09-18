import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';
import 'package:vitalia/services/async_combine.dart';

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
    this.actionFailure,
  });

  factory TodayState.fromCabinet({
    required List<Medication> medications,
    required List<DoseEvent> events,
    required bool showBanner,
    required DateTime now,
    StorageFailure? failure,
  }) {
    final slots = slotsForDay(
      medications: medications,
      events: events,
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
      refillSoon: medications.where((item) => item.needsRefill).toList(),
      showBanner: showBanner,
      failure: failure,
    );
  }

  factory TodayState.unavailable(DateTime now, StorageFailure failure) {
    return TodayState(
      nowLabel: greetingFor(now),
      dateLabel: formatDate(now),
      allSlots: const [],
      due: const [],
      later: const [],
      done: const [],
      refillSoon: const [],
      showBanner: false,
      failure: failure,
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
  final StorageFailure? actionFailure;

  int get takenCount =>
      done.where((slot) => slot.status == SlotStatus.taken).length;

  TodayState copyWith({StorageFailure? actionFailure}) {
    return TodayState(
      nowLabel: nowLabel,
      dateLabel: dateLabel,
      allSlots: allSlots,
      due: due,
      later: later,
      done: done,
      refillSoon: refillSoon,
      showBanner: showBanner,
      failure: failure,
      actionFailure: actionFailure,
    );
  }
}

final class TodayNotifier extends Notifier<AsyncValue<TodayState>> {
  @override
  AsyncValue<TodayState> build() {
    final now =
        ref.watch(currentMinuteProvider).value ??
        ref.watch(clockProvider).now();
    return combineAsync3(
      ref.watch(medicationsProvider),
      ref.watch(doseEventsProvider),
      ref.watch(settingsProvider),
    ).whenData((results) {
      return foldResults3(
        first: results.$1,
        second: results.$2,
        third: results.$3,
        onErr: (failure) => TodayState.unavailable(now, failure),
        onOk: (medications, events, settings) => TodayState.fromCabinet(
          medications: medications,
          events: events,
          showBanner: settings.banners,
          now: now,
        ),
      );
    });
  }

  void take(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.taken,
      ).catchError(unexpectedLogger('vitalia.today', 'today.intent')),
    );
  }

  void skip(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.skipped,
      ).catchError(unexpectedLogger('vitalia.today', 'today.intent')),
    );
  }

  Future<void> _record(String slotId, DoseAction action) async {
    final current = state.value;
    if (current == null) return;
    final slot = current.allSlots
        .where((item) => item.id == slotId)
        .firstOrNull;
    if (slot == null) return;
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .recordSlot(
          slot: slot,
          action: action,
          now: ref.read(clockProvider).now(),
          eventId: ref.read(idGeneratorProvider)(),
        );
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        logFailure('vitalia.today', failure);
        state = AsyncData(current.copyWith(actionFailure: failure));
    }
  }
}

final todayNotifierProvider =
    NotifierProvider<TodayNotifier, AsyncValue<TodayState>>(TodayNotifier.new);
