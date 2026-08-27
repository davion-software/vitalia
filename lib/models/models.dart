enum PillShape { capsule, tablet, softgel }

enum PillColor { sage, moss, terracotta, clay, sand, slate, ink, blush }

enum DoseAction { taken, skipped, snoozed }

enum SlotStatus { later, due, missed, taken, skipped, snoozed }

enum DayMark { empty, pending, complete, mixed }

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
}

class DoseEvent {
  const DoseEvent({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledAt,
    required this.at,
    required this.action,
    this.snoozeUntil,
  });

  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledAt;
  final DateTime at;
  final DoseAction action;
  final DateTime? snoozeUntil;

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'medicationName': medicationName,
    'scheduledAt': scheduledAt.toIso8601String(),
    'at': at.toIso8601String(),
    'action': action.name,
    'snoozeUntil': snoozeUntil?.toIso8601String(),
  };

  factory DoseEvent.fromJson(Map<String, dynamic> json) {
    return DoseEvent(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      at: DateTime.parse(json['at'] as String),
      action: DoseAction.values.byName(json['action'] as String),
      snoozeUntil: json['snoozeUntil'] == null
          ? null
          : DateTime.parse(json['snoozeUntil'] as String),
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.sound,
    required this.vibration,
    required this.banners,
    required this.snoozeMinutes,
  });

  final bool sound;
  final bool vibration;
  final bool banners;
  final int snoozeMinutes;

  static const defaults = AppSettings(
    sound: true,
    vibration: true,
    banners: true,
    snoozeMinutes: 10,
  );

  AppSettings copyWith({
    bool? sound,
    bool? vibration,
    bool? banners,
    int? snoozeMinutes,
  }) {
    return AppSettings(
      sound: sound ?? this.sound,
      vibration: vibration ?? this.vibration,
      banners: banners ?? this.banners,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'sound': sound,
    'vibration': vibration,
    'banners': banners,
    'snoozeMinutes': snoozeMinutes,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      sound: json['sound'] as bool? ?? true,
      vibration: json['vibration'] as bool? ?? true,
      banners: json['banners'] as bool? ?? true,
      snoozeMinutes: (json['snoozeMinutes'] as num?)?.toInt() ?? 10,
    );
  }
}

class Snapshot {
  const Snapshot({
    required this.initialized,
    required this.medications,
    required this.events,
    required this.settings,
  });

  final bool initialized;
  final List<Medication> medications;
  final List<DoseEvent> events;
  final AppSettings settings;

  static const empty = Snapshot(
    initialized: true,
    medications: [],
    events: [],
    settings: AppSettings.defaults,
  );

  Snapshot copyWith({
    bool? initialized,
    List<Medication>? medications,
    List<DoseEvent>? events,
    AppSettings? settings,
  }) {
    return Snapshot(
      initialized: initialized ?? this.initialized,
      medications: medications ?? this.medications,
      events: events ?? this.events,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
    'initialized': initialized,
    'medications': medications.map((m) => m.toJson()).toList(),
    'events': events.map((e) => e.toJson()).toList(),
    'settings': settings.toJson(),
  };

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    return Snapshot(
      initialized: json['initialized'] as bool? ?? true,
      medications: (json['medications'] as List<dynamic>)
          .map((e) => Medication.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>)
          .map((e) => DoseEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] == null
          ? AppSettings.defaults
          : AppSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );
  }
}

class DoseSlot {
  const DoseSlot({
    required this.medication,
    required this.scheduledAt,
    required this.status,
    this.snoozeUntil,
    this.isTest = false,
  });

  final Medication medication;
  final DateTime scheduledAt;
  final SlotStatus status;
  final DateTime? snoozeUntil;
  final bool isTest;

  String get id => isTest
      ? 'test-alarm'
      : '${medication.id}@${scheduledAt.year.toString().padLeft(4, '0')}-${scheduledAt.month.toString().padLeft(2, '0')}-${scheduledAt.day.toString().padLeft(2, '0')}T${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}';
}

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

class DaySummary {
  const DaySummary({required this.day, required this.mark});

  final DateTime day;
  final DayMark mark;
}

List<int> _ints(dynamic value) {
  if (value is! List) return const [];
  return value.map((item) => (item as num).toInt()).toList();
}

Medication sampleMedication() {
  return const Medication(
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
