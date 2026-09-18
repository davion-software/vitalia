import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';

@immutable
final class AlarmState {
  const AlarmState({
    required this.slot,
    required this.settings,
    required this.clockLabel,
  });

  final DoseSlot slot;
  final AppSettings settings;
  final String clockLabel;
}

final class AlarmNotifier extends Notifier<AsyncValue<AlarmState?>> {
  Timer? _refreshTimer;

  @override
  AsyncValue<AlarmState?> build() {
    ref.onDispose(_cancelRefresh);
    ref.watch(currentMinuteProvider);
    final now = ref.watch(clockProvider).now();
    final testAlarm = ref.watch(testAlarmProvider);
    return ref.watch(vitaliaSnapshotProvider).whenData((result) {
      return switch (result) {
        Err() => _storageUnavailable(),
        Ok(:final value) when testAlarm => _testAlarm(value, now),
        Ok(:final value) => _scheduledAlarm(value, now),
      };
    });
  }

  AlarmState? _storageUnavailable() {
    _cancelRefresh();
    return null;
  }

  AlarmState _testAlarm(Snapshot snapshot, DateTime now) {
    _cancelRefresh();
    return AlarmState(
      slot: DoseSlot(
        medication: snapshot.medications.isEmpty
            ? const Medication.sample()
            : snapshot.medications.first,
        scheduledAt: now,
        status: SlotStatus.due,
        isTest: true,
      ),
      settings: snapshot.settings,
      clockLabel: formatClock(now),
    );
  }

  AlarmState? _scheduledAlarm(Snapshot snapshot, DateTime now) {
    _armRefresh(snapshot, now);
    return _dueAlarm(
      snapshot.settings,
      snapshot.medications,
      snapshot.events,
      now,
    );
  }

  void _armRefresh(Snapshot snapshot, DateTime now) {
    _cancelRefresh();
    final next = nextAlarmChange(
      medications: snapshot.medications,
      events: snapshot.events,
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
    unawaited(_record(slotId, DoseAction.taken).catchError(_reportUnexpected));
  }

  void skip(String slotId) {
    unawaited(
      _record(slotId, DoseAction.skipped).catchError(_reportUnexpected),
    );
  }

  void snooze(String slotId) {
    unawaited(
      _record(slotId, DoseAction.snoozed).catchError(_reportUnexpected),
    );
  }

  Future<void> _record(String slotId, DoseAction action) async {
    final alarm = state.value;
    if (alarm == null || alarm.slot.id != slotId) return;
    if (alarm.slot.isTest) {
      ref.read(testAlarmProvider.notifier).stop();
      return;
    }
    final now = ref.read(clockProvider).now();
    final slot = alarm.slot;
    final event = DoseEvent(
      id: ref.read(idGeneratorProvider)(),
      medicationId: slot.medication.id,
      medicationName: slot.medication.name,
      scheduledAt: slot.scheduledAt,
      at: now,
      action: action,
      snoozeUntil: action == DoseAction.snoozed
          ? now.add(Duration(minutes: alarm.settings.snoozeMinutes))
          : null,
    );
    final result = await ref
        .read(vitaliaRepositoryProvider)
        .recordDose(event, decrementQuantity: action == DoseAction.taken);
    if (!ref.mounted) return;
    switch (result) {
      case Ok():
        return;
      case Err(:final failure):
        developer.log(failure.code, name: 'vitalia.alarm');
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

  void _reportUnexpected(Object error, StackTrace stack) {
    developer.log(
      'alarm.intent',
      name: 'vitalia.alarm',
      error: error,
      stackTrace: stack,
    );
  }
}

final alarmNotifierProvider =
    NotifierProvider<AlarmNotifier, AsyncValue<AlarmState?>>(AlarmNotifier.new);
