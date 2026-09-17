import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/data/demo_cabinet.dart';

void main() {
  final medications = demoCabinet();
  const vitaminD3Id = 'demo-vitamin-d3';

  test('before 8:00 the breakfast doses are later', () {
    final now = DateTime(2026, 8, 26, 7, 30);
    final slots = slotsForDay(
      medications: medications,
      events: const [],
      day: now,
      now: now,
    );
    expect(slots, hasLength(5));
    expect(slots.every((slot) => slot.status == SlotStatus.later), isTrue);
  });

  test('at 8:05 breakfast doses are due and evening remains later', () {
    final now = DateTime(2026, 8, 26, 8, 5);
    final slots = slotsForDay(
      medications: medications,
      events: const [],
      day: now,
      now: now,
    );
    expect(slots.where((slot) => slot.status == SlotStatus.due), hasLength(3));
    expect(
      slots.where((slot) => slot.status == SlotStatus.later),
      hasLength(2),
    );
  });

  test('a dose becomes missed exactly two hours after schedule', () {
    final scheduled = DateTime(2026, 8, 26, 8);
    expect(
      statusFor(
        scheduledAt: scheduled,
        now: DateTime(2026, 8, 26, 9, 59),
        events: const [],
      ),
      SlotStatus.due,
    );
    expect(
      statusFor(
        scheduledAt: scheduled,
        now: DateTime(2026, 8, 26, 10),
        events: const [],
      ),
      SlotStatus.missed,
    );
  });

  test('taken events win over the clock', () {
    final scheduled = DateTime(2026, 8, 26, 8);
    final events = [
      DoseEvent(
        id: '1',
        medicationId: vitaminD3Id,
        medicationName: 'Vitamin D3',
        scheduledAt: scheduled,
        at: DateTime(2026, 8, 26, 8, 1),
        action: DoseAction.taken,
      ),
    ];
    expect(
      statusFor(
        scheduledAt: scheduled,
        now: DateTime(2026, 8, 26, 11),
        events: events,
      ),
      SlotStatus.taken,
    );
  });

  test('an empty weekday set means every day', () {
    final wednesday = DateTime(2026, 8, 26);
    expect(runsOn(medications.first, wednesday), isTrue);
    final weekendOnly = medications.first.copyWith(daysOfWeek: const [6, 7]);
    expect(runsOn(weekendOnly, wednesday), isFalse);
    expect(runsOn(weekendOnly, DateTime(2026, 8, 29)), isTrue);
  });
}
