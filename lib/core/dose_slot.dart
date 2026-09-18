import 'package:meta/meta.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';

enum SlotStatus { later, due, missed, taken, skipped, snoozed }

String minuteStamp(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$year-$month-${day}T$hour:$minute';
}

String doseSlotKey({
  required String medicationId,
  required DateTime scheduledAt,
  bool isTest = false,
}) {
  if (isTest) return 'test-alarm';
  return '$medicationId@${minuteStamp(scheduledAt)}';
}

@immutable
final class DoseSlot {
  const DoseSlot({
    required this.medication,
    required this.scheduledAt,
    required this.status,
    this.snoozeUntil,
    this.isTest = false,
  });

  final Medication medication;
  final DateTime scheduledAt;
  final SlotStatus status;
  final DateTime? snoozeUntil;
  final bool isTest;

  String get id => doseSlotKey(
    medicationId: medication.id,
    scheduledAt: scheduledAt,
    isTest: isTest,
  );

  DoseEvent toEvent({
    required String id,
    required DateTime at,
    required DoseAction action,
    int snoozeMinutes = 0,
  }) {
    return DoseEvent(
      id: id,
      medicationId: medication.id,
      medicationName: medication.name,
      scheduledAt: scheduledAt,
      at: at,
      action: action,
      snoozeUntil: action == DoseAction.snoozed
          ? at.add(Duration(minutes: snoozeMinutes))
          : null,
    );
  }
}
