import 'entities.dart';

const missAfter = Duration(hours: 2);

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

List<DoseEvent> eventsForSlot(
  List<DoseEvent> events,
  String medicationId,
  DateTime scheduledAt,
) {
  final matches = events
      .where(
        (event) =>
            event.medicationId == medicationId &&
            sameMinute(event.scheduledAt, scheduledAt),
      )
      .toList();
  matches.sort((a, b) => a.at.compareTo(b.at));
  return matches;
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
}) {
  final slots = <DoseSlot>[];
  for (final medication in medications) {
    if (!runsOn(medication, day)) continue;
    for (final minutes in medication.timesMinutes) {
      final scheduledAt = combine(day, minutes);
      final slotEvents = eventsForSlot(events, medication.id, scheduledAt);
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
  while (!day.isAfter(last)) {
    for (final slot in slotsForDay(
      medications: medications,
      events: events,
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
  for (var i = 0; i < 365; i++) {
    final slots = slotsForDay(
      medications: medications,
      events: events,
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
  return List.generate(7, (index) {
    final day = today.subtract(Duration(days: 6 - index));
    final slots = slotsForDay(
      medications: medications,
      events: events,
      day: day,
      now: now,
    );
    return DaySummary(day: day, mark: markFor(slots));
  });
}
