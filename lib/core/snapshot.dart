import 'package:meta/meta.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';

@immutable
final class Snapshot {
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
}
