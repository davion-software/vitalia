enum DayMark { empty, pending, complete, mixed }

class DaySummary {
  const DaySummary({required this.day, required this.mark});

  final DateTime day;
  final DayMark mark;
}
