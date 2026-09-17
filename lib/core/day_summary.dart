import 'package:meta/meta.dart';

enum DayMark { empty, pending, complete, mixed }

@immutable
final class DaySummary {
  const DaySummary({required this.day, required this.mark});

  final DateTime day;
  final DayMark mark;
}
