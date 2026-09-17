import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/snapshot.dart';

Map<String, Object?> encodeLegacySnapshot(Snapshot snapshot) => {
  'initialized': snapshot.initialized,
  'medications': snapshot.medications.map(_encodeMedication).toList(),
  'events': snapshot.events.map(_encodeDoseEvent).toList(),
  'settings': _encodeSettings(snapshot.settings),
};

Snapshot decodeLegacySnapshot(Map<String, Object?> json) {
  final medications = _objectList(json, 'medications');
  final events = _objectList(json, 'events');
  final settings = json['settings'];
  return Snapshot(
    initialized: json['initialized'] as bool? ?? true,
    medications: medications.map((item) {
      final map = _objectMap(item);
      return Medication(
        id: _string(map, 'id'),
        name: _string(map, 'name'),
        dosage: _string(map, 'dosage'),
        notes: map['notes'] as String? ?? '',
        shape: _pillShape(_string(map, 'shape')),
        color: _pillColor(_string(map, 'color')),
        timesMinutes: _integers(map['timesMinutes']),
        daysOfWeek: _integers(map['daysOfWeek']),
        quantity: (map['quantity'] as num?)?.toInt(),
        refillThreshold: (map['refillThreshold'] as num?)?.toInt(),
      );
    }).toList(),
    events: events.map((item) {
      final map = _objectMap(item);
      final snoozeUntil = map['snoozeUntil'];
      return DoseEvent(
        id: _string(map, 'id'),
        medicationId: _string(map, 'medicationId'),
        medicationName: _string(map, 'medicationName'),
        scheduledAt: DateTime.parse(_string(map, 'scheduledAt')),
        at: DateTime.parse(_string(map, 'at')),
        action: _doseAction(_string(map, 'action')),
        snoozeUntil: snoozeUntil is String ? DateTime.parse(snoozeUntil) : null,
      );
    }).toList(),
    settings: settings == null
        ? AppSettings.defaults
        : _decodeSettings(_objectMap(settings)),
  );
}

Map<String, Object?> _encodeMedication(Medication medication) => {
  'id': medication.id,
  'name': medication.name,
  'dosage': medication.dosage,
  'notes': medication.notes,
  'shape': medication.shape.name,
  'color': medication.color.name,
  'timesMinutes': medication.timesMinutes,
  'daysOfWeek': medication.daysOfWeek,
  'quantity': medication.quantity,
  'refillThreshold': medication.refillThreshold,
};

Map<String, Object?> _encodeDoseEvent(DoseEvent event) => {
  'id': event.id,
  'medicationId': event.medicationId,
  'medicationName': event.medicationName,
  'scheduledAt': event.scheduledAt.toIso8601String(),
  'at': event.at.toIso8601String(),
  'action': event.action.name,
  'snoozeUntil': event.snoozeUntil?.toIso8601String(),
};

Map<String, Object?> _encodeSettings(AppSettings settings) => {
  'sound': settings.sound,
  'vibration': settings.vibration,
  'banners': settings.banners,
  'snoozeMinutes': settings.snoozeMinutes,
};

AppSettings _decodeSettings(Map<String, Object?> json) => AppSettings(
  sound: json['sound'] as bool? ?? true,
  vibration: json['vibration'] as bool? ?? true,
  banners: json['banners'] as bool? ?? true,
  snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 10,
);

List<Object?> _objectList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is List<Object?>) return value;
  throw FormatException('Expected a list for $key');
}

Map<String, Object?> _objectMap(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw const FormatException('Expected an object');
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw FormatException('Expected a string for $key');
}

List<int> _integers(Object? value) {
  if (value is! List<Object?>) return const [];
  return value.whereType<num>().map((item) => item.toInt()).toList();
}

PillShape _pillShape(String name) {
  for (final value in PillShape.values) {
    if (value.name == name) return value;
  }
  throw const FormatException('Unknown pill shape');
}

PillColor _pillColor(String name) {
  for (final value in PillColor.values) {
    if (value.name == name) return value;
  }
  throw const FormatException('Unknown pill color');
}

DoseAction _doseAction(String name) {
  for (final value in DoseAction.values) {
    if (value.name == name) return value;
  }
  throw const FormatException('Unknown dose action');
}
