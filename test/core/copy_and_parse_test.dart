import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/core/copy.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/storage_failure.dart';

void main() {
  test('enum byName round-trips every known value', () {
    for (final shape in PillShape.values) {
      expect(PillShape.byName(shape.name), shape);
    }
    for (final color in PillColor.values) {
      expect(PillColor.byName(color.name), color);
    }
    for (final action in DoseAction.values) {
      expect(DoseAction.byName(action.name), action);
    }
    expect(PillShape.byName('unknown'), isNull);
    expect(PillColor.byName('unknown'), isNull);
    expect(DoseAction.byName('unknown'), isNull);
  });

  test('DoseSlot.toEvent copies identity and snooze window', () {
    const medication = Medication.sample();
    final scheduledAt = DateTime(2026, 8, 26, 8);
    final slot = DoseSlot(
      medication: medication,
      scheduledAt: scheduledAt,
      status: SlotStatus.due,
    );
    final event = slot.toEvent(
      id: 'event-1',
      at: DateTime(2026, 8, 26, 8, 1),
      action: DoseAction.snoozed,
      snoozeMinutes: 10,
    );
    expect(event.medicationId, medication.id);
    expect(event.scheduledAt, scheduledAt);
    expect(event.snoozeUntil, DateTime(2026, 8, 26, 8, 11));
  });

  test('storageFailureMessage covers every failure code', () {
    expect(
      storageFailureMessage(const StorageUnavailable()),
      'Storage is temporarily unavailable.',
    );
    expect(
      storageFailureMessage(const StorageCorrupt()),
      'Saved data could not be read.',
    );
    expect(
      storageFailureMessage(const StorageConstraintViolation('write')),
      'That change could not be saved.',
    );
    expect(
      storageFailureMessage(const StorageNotFound('id')),
      'That item is no longer available.',
    );
  });
}
