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

final class AlarmNotifier extends StreamNotifier<AlarmState?> {
  @override
  Stream<AlarmState?> build() {
    final now =
        ref.watch(currentTimeProvider).value ?? ref.watch(clockProvider).now();
    final testAlarm = ref.watch(testAlarmProvider);
    return ref.watch(vitaliaRepositoryProvider).watchSnapshot().map((result) {
      return switch (result) {
        Err() => null,
        Ok(:final value) when testAlarm => AlarmState(
          slot: DoseSlot(
            medication: value.medications.isEmpty
                ? const Medication.sample()
                : value.medications.first,
            scheduledAt: now,
            status: SlotStatus.due,
            isTest: true,
          ),
          settings: value.settings,
          clockLabel: formatClock(now),
        ),
        Ok(:final value) => _dueAlarm(
          value.settings,
          value.medications,
          value.events,
          now,
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
    StreamNotifierProvider<AlarmNotifier, AlarmState?>(AlarmNotifier.new);
