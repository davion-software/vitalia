import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/data/app_database.dart';

int utcMs(DateTime value) => value.toUtc().millisecondsSinceEpoch;

DateTime localDateTime(int milliseconds) =>
    DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true).toLocal();

T requireParsed<T>(T? value, String message) {
  if (value == null) throw FormatException(message);
  return value;
}

Medication medicationFromRow(
  MedicationRow row, {
  required List<int> timesMinutes,
  required List<int> daysOfWeek,
}) {
  return Medication(
    id: row.id,
    name: row.name,
    dosage: row.dosage,
    notes: row.notes,
    shape: requireParsed(
      PillShape.byName(row.shape),
      'Unknown medication shape',
    ),
    color: requireParsed(
      PillColor.byName(row.color),
      'Unknown medication color',
    ),
    timesMinutes: timesMinutes,
    daysOfWeek: daysOfWeek,
    quantity: row.quantity,
    refillThreshold: row.refillThreshold,
  );
}

DoseEvent doseEventFromRow(DoseEventRow row) {
  return DoseEvent(
    id: row.id,
    medicationId: row.medicationId,
    medicationName: row.medicationName,
    scheduledAt: localDateTime(row.scheduledAtUtcMs),
    at: localDateTime(row.occurredAtUtcMs),
    action: requireParsed(DoseAction.byName(row.action), 'Unknown dose action'),
    snoozeUntil: switch (row.snoozeUntilUtcMs) {
      final int milliseconds => localDateTime(milliseconds),
      null => null,
    },
  );
}

AppSettings settingsFromRow(SettingsRow row) {
  return AppSettings(
    sound: row.sound,
    vibration: row.vibration,
    banners: row.banners,
    snoozeMinutes: row.snoozeMinutes,
  );
}
