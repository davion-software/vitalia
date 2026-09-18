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

  test('the next alarm change is the next scheduled dose', () {
    expect(
      nextAlarmChange(
        medications: medications,
        events: const [],
        now: DateTime(2026, 8, 26, 7, 30),
      ),
      DateTime(2026, 8, 26, 8),
    );
  });

  test('a due alarm refreshes when the dose becomes missed', () {
    expect(
      nextAlarmChange(
        medications: medications,
        events: const [],
        now: DateTime(2026, 8, 26, 8),
      ),
      DateTime(2026, 8, 26, 10),
    );
  });

  test('a snoozed alarm refreshes at its exact expiration second', () {
    final scheduledAt = DateTime(2026, 8, 26, 8);
    final snoozeUntil = DateTime(2026, 8, 26, 8, 10, 37);
    final event = DoseEvent(
      id: 'snooze',
      medicationId: vitaminD3Id,
      medicationName: 'Vitamin D3',
      scheduledAt: scheduledAt,
      at: DateTime(2026, 8, 26, 8, 0, 37),
      action: DoseAction.snoozed,
      snoozeUntil: snoozeUntil,
    );

    expect(
      nextAlarmChange(
        medications: [medications.first],
        events: [event],
        now: DateTime(2026, 8, 26, 8, 5),
      ),
      snoozeUntil,
    );
  });

  test('a resolved dose has no remaining alarm transition today', () {
    final scheduledAt = DateTime(2026, 8, 26, 8);
    final event = DoseEvent(
      id: 'taken',
      medicationId: vitaminD3Id,
      medicationName: 'Vitamin D3',
      scheduledAt: scheduledAt,
      at: DateTime(2026, 8, 26, 8, 1),
      action: DoseAction.taken,
    );

    expect(
      nextAlarmChange(
        medications: [medications.first],
        events: [event],
        now: DateTime(2026, 8, 26, 8, 5),
      ),
      DateTime(2026, 8, 27),
    );
  });

  test('an empty schedule refreshes at the next local midnight', () {
    expect(
      nextAlarmChange(
        medications: const [],
        events: const [],
        now: DateTime(2026, 8, 26, 23, 45),
      ),
      DateTime(2026, 8, 27),
    );
  });

  test('indexEventsBySlot groups matching minutes together', () {
    final scheduled = DateTime(2026, 8, 26, 8);
    final events = [
      DoseEvent(
        id: 'snooze',
        medicationId: vitaminD3Id,
        medicationName: 'Vitamin D3',
        scheduledAt: scheduled,
        at: DateTime(2026, 8, 26, 8, 1),
        action: DoseAction.snoozed,
        snoozeUntil: DateTime(2026, 8, 26, 8, 10),
      ),
      DoseEvent(
        id: 'taken',
        medicationId: vitaminD3Id,
        medicationName: 'Vitamin D3',
        scheduledAt: scheduled,
        at: DateTime(2026, 8, 26, 8, 2),
        action: DoseAction.taken,
      ),
    ];
    final index = indexEventsBySlot(events);
    expect(index, hasLength(1));
    expect(
      eventsForSlot(index, vitaminD3Id, scheduled).map((event) => event.id),
      ['snooze', 'taken'],
    );
  });
}
