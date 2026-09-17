import 'app_settings.dart';
import 'dose_event.dart';
import 'medication.dart';

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
