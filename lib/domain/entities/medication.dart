enum PillShape { capsule, tablet, softgel }

enum PillColor { sage, moss, terracotta, clay, sand, slate, ink, blush }

class Medication {
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

  bool get needsRefill =>
      quantity != null &&
      refillThreshold != null &&
      quantity! <= refillThreshold!;

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dosage': dosage,
    'notes': notes,
    'shape': shape.name,
    'color': color.name,
    'timesMinutes': timesMinutes,
    'daysOfWeek': daysOfWeek,
    'quantity': quantity,
    'refillThreshold': refillThreshold,
  };

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      notes: json['notes'] as String? ?? '',
      shape: PillShape.values.byName(json['shape'] as String),
      color: PillColor.values.byName(json['color'] as String),
      timesMinutes: _ints(json['timesMinutes']),
      daysOfWeek: _ints(json['daysOfWeek']),
      quantity: (json['quantity'] as num?)?.toInt(),
      refillThreshold: (json['refillThreshold'] as num?)?.toInt(),
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
        timesMinutes: [480],
        daysOfWeek: [],
      );
}

List<int> _ints(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => (item as num).toInt()).toList();
}
