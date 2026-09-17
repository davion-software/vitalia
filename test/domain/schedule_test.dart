import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/data/demo_cabinet.dart';
import 'package:vitalia/domain/entities.dart';
import 'package:vitalia/domain/schedule.dart';

void main() {
  final meds = demoCabinet();
  const d3 = 'demo-vitamin-d3';

  test('before 8:00 the breakfast doses sit in Later', () {
    final now = DateTime(2026, 8, 26, 7, 30);
    final slots = slotsForDay(
      medications: meds,
      events: const [],
      day: now,
      now: now,
    );
    expect(slots, hasLength(5));
    expect(slots.every((slot) => slot.status == SlotStatus.later), isTrue);
  });

  test('at 8:05 breakfast doses are due and evening stays later', () {
    final now = DateTime(2026, 8, 26, 8, 5);
    final slots = slotsForDay(
      medications: meds,
      events: const [],
      day: now,
      now: now,
    );
    final due = slots.where((slot) => slot.status == SlotStatus.due).toList();
    final later = slots.where((slot) => slot.status == SlotStatus.later);
    expect(due, hasLength(3));
    expect(later, hasLength(2));
  });

  test('two hours after a dose it becomes missed', () {
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
        medicationId: d3,
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

  test('empty days of week means every day', () {
    final wednesday = DateTime(2026, 8, 26);
    expect(runsOn(meds.first, wednesday), isTrue);
    final weekendOnly = meds.first.copyWith(daysOfWeek: const [6, 7]);
    expect(runsOn(weekendOnly, wednesday), isFalse);
    expect(runsOn(weekendOnly, DateTime(2026, 8, 29)), isTrue);
  });
}
