import 'package:vitalia/core/dose_event.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

String greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String formatClock(DateTime time) {
  return formatHourMinute(time.hour, time.minute);
}

String formatMinutes(int minutes) {
  final wrapped = ((minutes % (24 * 60)) + (24 * 60)) % (24 * 60);
  return formatHourMinute(wrapped ~/ 60, wrapped % 60);
}

String formatHourMinute(int hour, int minute) {
  final suffix = hour < 12 ? 'AM' : 'PM';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  final mm = minute.toString().padLeft(2, '0');
  return '$hour12:$mm $suffix';
}

String formatDate(DateTime day) {
  return '${_weekdays[day.weekday - 1]} ${day.day} ${_months[day.month - 1]}';
}

String formatDays(List<int> daysOfWeek) {
  if (daysOfWeek.isEmpty) return 'Every day';
  final sorted = [...daysOfWeek]..sort();
  return sorted.map((d) => _weekdays[d - 1]).join(', ');
}

String formatTimes(List<int> timesMinutes) {
  final sorted = [...timesMinutes]..sort();
  return sorted.map(formatMinutes).join(' · ');
}

String formatRelativeEvent(DateTime at, DateTime now) {
  final sameDay =
      at.year == now.year && at.month == now.month && at.day == now.day;
  if (sameDay) return 'Today ${formatClock(at)}';
  return '${_weekdays[at.weekday - 1]} ${formatClock(at)}';
}

String actionLabel(DoseAction action) {
  switch (action) {
    case DoseAction.taken:
      return 'Taken';
    case DoseAction.skipped:
      return 'Skipped';
    case DoseAction.snoozed:
      return 'Snoozed';
  }
}

String weekdayLetter(int weekday) => _weekdays[weekday - 1][0];
