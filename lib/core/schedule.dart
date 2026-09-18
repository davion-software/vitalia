import 'package:vitalia/core/adherence.dart';
import 'package:vitalia/core/day_summary.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/medication.dart';

const missAfter = Duration(hours: 2);
const doseEventLookback = Duration(days: 400);

DateTime dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

bool sameMinute(DateTime a, DateTime b) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;
}

bool runsOn(Medication medication, DateTime day) {
  if (medication.daysOfWeek.isEmpty) return true;
  return medication.daysOfWeek.contains(day.weekday);
}

DateTime combine(DateTime day, int minutes) {
  final d = dateOnly(day);
  return DateTime(d.year, d.month, d.day, minutes ~/ 60, minutes % 60);
}

Map<String, List<DoseEvent>> indexEventsBySlot(List<DoseEvent> events) {
  final index = <String, List<DoseEvent>>{};
  for (final event in events) {
    final key = doseSlotKey(
      medicationId: event.medicationId,
      scheduledAt: event.scheduledAt,
    );
    (index[key] ??= []).add(event);
  }
  for (final slotEvents in index.values) {
    slotEvents.sort((a, b) => a.at.compareTo(b.at));
  }
  return index;
}

List<DoseEvent> eventsForSlot(
  Map<String, List<DoseEvent>> eventsBySlot,
  String medicationId,
  DateTime scheduledAt,
) {
  return eventsBySlot[doseSlotKey(
        medicationId: medicationId,
        scheduledAt: scheduledAt,
      )] ??
      const [];
}

SlotStatus statusFor({
  required DateTime scheduledAt,
  required DateTime now,
  required List<DoseEvent> events,
}) {
  if (events.any((event) => event.action == DoseAction.taken)) {
    return SlotStatus.taken;
  }
  if (events.any((event) => event.action == DoseAction.skipped)) {
    return SlotStatus.skipped;
  }
  final missedAt = scheduledAt.add(missAfter);
  if (!now.isBefore(missedAt)) {
    return SlotStatus.missed;
  }
  final snoozes = events.where((event) => event.action == DoseAction.snoozed);
  if (snoozes.isNotEmpty) {
    final until = snoozes.last.snoozeUntil;
    if (until != null && now.isBefore(until)) {
      return SlotStatus.snoozed;
    }
  }
  if (now.isBefore(scheduledAt)) {
    return SlotStatus.later;
  }
  return SlotStatus.due;
}

List<DoseSlot> slotsForDay({
  required List<Medication> medications,
  required List<DoseEvent> events,
  required DateTime day,
  required DateTime now,
  Map<String, List<DoseEvent>>? eventsBySlot,
}) {
  return _slotsForDay(
    medications: medications,
    eventsBySlot: eventsBySlot ?? indexEventsBySlot(events),
    day: day,
    now: now,
  );
}

List<DoseSlot> _slotsForDay({
  required List<Medication> medications,
  required Map<String, List<DoseEvent>> eventsBySlot,
  required DateTime day,
  required DateTime now,
}) {
  final slots = <DoseSlot>[];
  for (final medication in medications) {
    if (!runsOn(medication, day)) continue;
    for (final minutes in medication.timesMinutes) {
      final scheduledAt = combine(day, minutes);
      final slotEvents = eventsForSlot(
        eventsBySlot,
        medication.id,
        scheduledAt,
      );
      final snoozes = slotEvents.where(
        (event) => event.action == DoseAction.snoozed,
      );
      slots.add(
        DoseSlot(
          medication: medication,
          scheduledAt: scheduledAt,
          status: statusFor(
            scheduledAt: scheduledAt,
            now: now,
            events: slotEvents,
          ),
          snoozeUntil: snoozes.isEmpty ? null : snoozes.last.snoozeUntil,
        ),
      );
    }
  }
  slots.sort((a, b) {
    final byTime = a.scheduledAt.compareTo(b.scheduledAt);
    if (byTime != 0) return byTime;
    return a.medication.name.compareTo(b.medication.name);
  });
  return slots;
}

DateTime nextAlarmChange({
  required List<Medication> medications,
  required List<DoseEvent> events,
  required DateTime now,
}) {
  var next = DateTime(now.year, now.month, now.day + 1);
  final eventsBySlot = indexEventsBySlot(events);

  void consider(DateTime candidate) {
    if (candidate.isAfter(now) && candidate.isBefore(next)) {
      next = candidate;
    }
  }

  for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
    final day = DateTime(now.year, now.month, now.day + dayOffset);
    for (final medication in medications) {
      if (!runsOn(medication, day)) continue;
      for (final minutes in medication.timesMinutes) {
        final scheduledAt = combine(day, minutes);
        final slotEvents = eventsForSlot(
          eventsBySlot,
          medication.id,
          scheduledAt,
        );
        final resolved = slotEvents.any(
          (event) =>
              event.action == DoseAction.taken ||
              event.action == DoseAction.skipped,
        );
        if (resolved) continue;
        consider(scheduledAt);
        consider(scheduledAt.add(missAfter));
        for (final event in slotEvents) {
          final snoozeUntil = event.snoozeUntil;
          if (snoozeUntil != null) consider(snoozeUntil);
        }
      }
    }
  }
  return next;
}

Adherence adherenceForRange({
  required List<Medication> medications,
  required List<DoseEvent> events,
  required DateTime from,
  required DateTime to,
  required DateTime now,
}) {
  var taken = 0;
  var skipped = 0;
  var missed = 0;
  var day = dateOnly(from);
  final last = dateOnly(to);
  final eventsBySlot = indexEventsBySlot(events);
  while (!day.isAfter(last)) {
    for (final slot in _slotsForDay(
      medications: medications,
      eventsBySlot: eventsBySlot,
      day: day,
      now: now,
    )) {
      switch (slot.status) {
        case SlotStatus.taken:
          taken += 1;
        case SlotStatus.skipped:
          skipped += 1;
        case SlotStatus.missed:
          missed += 1;
        case SlotStatus.later:
        case SlotStatus.due:
        case SlotStatus.snoozed:
          break;
      }
    }
    day = day.add(const Duration(days: 1));
  }
  return Adherence(taken: taken, skipped: skipped, missed: missed);
}

DateTime mondayOf(DateTime day) {
  final d = dateOnly(day);
  return d.subtract(Duration(days: d.weekday - 1));
}

int cleanStreak({
  required List<Medication> medications,
  required List<DoseEvent> events,
  required DateTime now,
}) {
  var streak = 0;
  var day = dateOnly(now);
  final eventsBySlot = indexEventsBySlot(events);
  for (var i = 0; i < 365; i++) {
    final slots = _slotsForDay(
      medications: medications,
      eventsBySlot: eventsBySlot,
      day: day,
      now: now,
    );
    if (slots.isEmpty) {
      day = day.subtract(const Duration(days: 1));
      continue;
    }
    final failed = slots.any(
      (slot) =>
          slot.status == SlotStatus.skipped || slot.status == SlotStatus.missed,
    );
    if (failed) break;
    final unresolved = slots.any(
      (slot) =>
          slot.status == SlotStatus.later ||
          slot.status == SlotStatus.due ||
          slot.status == SlotStatus.snoozed,
    );
    if (unresolved) {
      if (day.year == now.year &&
          day.month == now.month &&
          day.day == now.day) {
        day = day.subtract(const Duration(days: 1));
        continue;
      }
      break;
    }
    streak += 1;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

DayMark markFor(List<DoseSlot> slots) {
  if (slots.isEmpty) return DayMark.empty;
  final failed = slots.any(
    (slot) =>
        slot.status == SlotStatus.skipped || slot.status == SlotStatus.missed,
  );
  if (failed) return DayMark.mixed;
  final unresolved = slots.any(
    (slot) =>
        slot.status == SlotStatus.later ||
        slot.status == SlotStatus.due ||
        slot.status == SlotStatus.snoozed,
  );
  if (unresolved) return DayMark.pending;
  return DayMark.complete;
}

List<DaySummary> lastSevenDays({
  required List<Medication> medications,
  required List<DoseEvent> events,
  required DateTime now,
}) {
  final today = dateOnly(now);
  final eventsBySlot = indexEventsBySlot(events);
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final slots = _slotsForDay(
      medications: medications,
      eventsBySlot: eventsBySlot,
      day: day,
      now: now,
    );
    return DaySummary(day: day, mark: markFor(slots));
  });
}
