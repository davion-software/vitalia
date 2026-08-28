enum DoseAction { taken, skipped, snoozed }

class DoseEvent {
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'medicationName': medicationName,
    'scheduledAt': scheduledAt.toIso8601String(),
    'at': at.toIso8601String(),
    'action': action.name,
    'snoozeUntil': snoozeUntil?.toIso8601String(),
  };

  factory DoseEvent.fromJson(Map<String, dynamic> json) {
    return DoseEvent(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      at: DateTime.parse(json['at'] as String),
      action: DoseAction.values.byName(json['action'] as String),
      snoozeUntil: json['snoozeUntil'] == null
          ? null
          : DateTime.parse(json['snoozeUntil'] as String),
    );
  }
}
