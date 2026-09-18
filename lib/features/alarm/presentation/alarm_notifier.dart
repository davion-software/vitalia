import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/app_settings.dart';
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
final class AlarmState {
  const AlarmState({
    required this.slot,
    required this.settings,
    required this.clockLabel,
    this.actionFailure,
  });

  final DoseSlot slot;
  final AppSettings settings;
  final String clockLabel;
  final StorageFailure? actionFailure;

  AlarmState copyWith({StorageFailure? actionFailure}) {
    return AlarmState(
      slot: slot,
      settings: settings,
      clockLabel: clockLabel,
      actionFailure: actionFailure,
    );
  }
}

final class AlarmNotifier extends Notifier<AsyncValue<AlarmState?>> {
  Timer? _refreshTimer;

  @override
  AsyncValue<AlarmState?> build() {
    ref.onDispose(_cancelRefresh);
    ref.watch(currentMinuteProvider);
    final now = ref.watch(clockProvider).now();
    final testAlarm = ref.watch(testAlarmProvider);
    return combineAsync3(
      ref.watch(medicationsProvider),
      ref.watch(doseEventsProvider),
      ref.watch(settingsProvider),
    ).whenData((results) {
      return foldResults3(
        first: results.$1,
        second: results.$2,
        third: results.$3,
        onErr: (_) => _storageUnavailable(),
        onOk: (medications, events, settings) {
          if (testAlarm) return _testAlarm(medications, settings, now);
          return _scheduledAlarm(medications, events, settings, now);
        },
      );
    });
  }

  AlarmState? _storageUnavailable() {
    _cancelRefresh();
    return null;
  }

  AlarmState _testAlarm(
    List<Medication> medications,
    AppSettings settings,
    DateTime now,
  ) {
    _cancelRefresh();
    return AlarmState(
      slot: DoseSlot(
        medication: medications.isEmpty
            ? const Medication.sample()
            : medications.first,
        scheduledAt: now,
        status: SlotStatus.due,
        isTest: true,
      ),
      settings: settings,
      clockLabel: formatClock(now),
    );
  }

  AlarmState? _scheduledAlarm(
    List<Medication> medications,
    List<DoseEvent> events,
    AppSettings settings,
    DateTime now,
  ) {
    _armRefresh(medications, events, now);
    return _dueAlarm(settings, medications, events, now);
  }

  void _armRefresh(
    List<Medication> medications,
    List<DoseEvent> events,
    DateTime now,
  ) {
    _cancelRefresh();
    final next = nextAlarmChange(
      medications: medications,
      events: events,
      now: now,
    );
    _refreshTimer = Timer(next.difference(now), () {
      _refreshTimer = null;
      if (!ref.mounted) return;
      ref.invalidateSelf();
    });
  }

  void _cancelRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void take(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.taken,
      ).catchError(unexpectedLogger('vitalia.alarm', 'alarm.intent')),
    );
  }

  void skip(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.skipped,
      ).catchError(unexpectedLogger('vitalia.alarm', 'alarm.intent')),
    );
  }

  void snooze(String slotId) {
    unawaited(
      _record(
        slotId,
        DoseAction.snoozed,
      ).catchError(unexpectedLogger('vitalia.alarm', 'alarm.intent')),
    );
  }

  Future<void> _record(String slotId, DoseAction action) async {
    final alarm = state.value;
    if (alarm == null || alarm.slot.id != slotId) return;
    if (alarm.slot.isTest) {
      ref.read(testAlarmProvider.notifier).stop();
      return;
    }
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .recordSlot(
          slot: alarm.slot,
          action: action,
          now: ref.read(clockProvider).now(),
          eventId: ref.read(idGeneratorProvider)(),
          snoozeMinutes: alarm.settings.snoozeMinutes,
        );
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        logFailure('vitalia.alarm', failure);
        state = AsyncData(alarm.copyWith(actionFailure: failure));
    }
  }

  AlarmState? _dueAlarm(
    AppSettings settings,
    List<Medication> medications,
    List<DoseEvent> events,
    DateTime now,
  ) {
    final slots = slotsForDay(
      medications: medications,
      events: events,
      day: now,
      now: now,
    );
    final due = slots
        .where((slot) => slot.status == SlotStatus.due)
        .firstOrNull;
    if (due == null) return null;
    return AlarmState(
      slot: due,
      settings: settings,
      clockLabel: formatClock(now),
    );
  }
}

final alarmNotifierProvider =
    NotifierProvider<AlarmNotifier, AsyncValue<AlarmState?>>(AlarmNotifier.new);
