class Adherence {
  const Adherence({
    required this.taken,
    required this.skipped,
    required this.missed,
  });

  final int taken;
  final int skipped;
  final int missed;

  int get resolved => taken + skipped + missed;

  double? get rate => resolved == 0 ? null : taken / resolved;
}
