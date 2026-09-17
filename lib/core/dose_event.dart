import 'package:meta/meta.dart';

enum DoseAction { taken, skipped, snoozed }

@immutable
final class DoseEvent {
  const DoseEvent({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAt,
    required this.at,
    required this.action,
    this.snoozeUntil,
  });

  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledAt;
  final DateTime at;
  final DoseAction action;
  final DateTime? snoozeUntil;
}
