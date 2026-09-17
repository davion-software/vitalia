import 'package:meta/meta.dart';
import 'package:vitalia/core/medication.dart';

enum SlotStatus { later, due, missed, taken, skipped, snoozed }

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

  String get id => isTest
      ? 'test-alarm'
      : '${medication.id}@${scheduledAt.year.toString().padLeft(4, '0')}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')}T${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
}
