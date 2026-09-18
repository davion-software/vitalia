import 'package:meta/meta.dart';

enum PillShape {
  capsule,
  tablet,
  softgel;

  static PillShape? byName(String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

enum PillColor {
  sage,
  moss,
  terracotta,
  clay,
  sand,
  slate,
  ink,
  blush;

  static PillColor? byName(String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }
}

@immutable
final class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.notes,
    required this.shape,
    required this.color,
    required this.timesMinutes,
    required this.daysOfWeek,
    this.quantity,
    this.refillThreshold,
  });

  final String id;
  final String name;
  final String dosage;
  final String notes;
  final PillShape shape;
  final PillColor color;
  final List<int> timesMinutes;
  final List<int> daysOfWeek;
  final int? quantity;
  final int? refillThreshold;

  bool get tracksPills => quantity != null;

  bool get needsRefill => switch ((quantity, refillThreshold)) {
    (final int remaining, final int threshold) => remaining <= threshold,
    _ => false,
  };

  Medication copyWith({
    String? name,
    String? dosage,
    String? notes,
    PillShape? shape,
    PillColor? color,
    List<int>? timesMinutes,
    List<int>? daysOfWeek,
    int? quantity,
    int? refillThreshold,
    bool clearQuantity = false,
  }) {
    return Medication(
      id: id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      notes: notes ?? this.notes,
      shape: shape ?? this.shape,
      color: color ?? this.color,
      timesMinutes: timesMinutes ?? this.timesMinutes,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      quantity: clearQuantity ? null : (quantity ?? this.quantity),
      refillThreshold: clearQuantity
          ? null
          : (refillThreshold ?? this.refillThreshold),
    );
  }

  const Medication.sample()
    : this(
        id: 'sample',
        name: 'Sample dose',
        dosage: '10 mg',
        notes: 'Test alarm',
        shape: PillShape.capsule,
        color: PillColor.sage,
        timesMinutes: const [480],
        daysOfWeek: const [],
      );
}
