import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/features/alarm/presentation/alarm_notifier.dart';
import 'package:vitalia/services/app_providers.dart';

void main() {
  testWidgets('Alarm appears exactly when a scheduled dose becomes due', (
    tester,
  ) async {
    final start = DateTime(2026, 8, 26, 7, 59, 50);
    final harness = _alarmHarness(tester, start, _snapshot());
    try {
      expect(harness.container.read(alarmNotifierProvider).value, isNull);

      await tester.pump(const Duration(seconds: 9));
      expect(harness.container.read(alarmNotifierProvider).value, isNull);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      final alarm = harness.container.read(alarmNotifierProvider).value;
      expect(alarm, isNotNull);
      expect(alarm?.slot.medication.id, 'morning-dose');
    } finally {
      harness.dispose();
    }
  });

  testWidgets('Alarm returns at the exact snooze expiration second', (
    tester,
  ) async {
    final start = DateTime(2026, 8, 26, 8, 5, 15);
    final scheduledAt = DateTime(2026, 8, 26, 8);
    final snoozeUntil = DateTime(2026, 8, 26, 8, 5, 37);
    final snapshot = _snapshot(
      events: [
        DoseEvent(
          id: 'snooze',
          medicationId: 'morning-dose',
          medicationName: 'Morning dose',
          scheduledAt: scheduledAt,
          at: DateTime(2026, 8, 26, 7, 55, 37),
          action: DoseAction.snoozed,
          snoozeUntil: snoozeUntil,
        ),
      ],
    );
    final harness = _alarmHarness(tester, start, snapshot);
    try {
      expect(harness.container.read(alarmNotifierProvider).value, isNull);

      await tester.pump(const Duration(seconds: 21));
      expect(harness.container.read(alarmNotifierProvider).value, isNull);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(harness.container.read(alarmNotifierProvider).value, isNotNull);
    } finally {
      harness.dispose();
    }
  });
}

({ProviderContainer container, void Function() dispose}) _alarmHarness(
  WidgetTester tester,
  DateTime start,
  Snapshot snapshot,
) {
  final bindingStart = tester.binding.clock.now();
  final appClock = Clock(
    () => start.add(tester.binding.clock.now().difference(bindingStart)),
  );
  final container = ProviderContainer(
    overrides: [
      clockProvider.overrideWithValue(appClock),
      currentMinuteProvider.overrideWithValue(AsyncData(start)),
      vitaliaSnapshotProvider.overrideWithValue(AsyncData(Ok(snapshot))),
    ],
  );
  final subscription = container.listen(
    alarmNotifierProvider,
    (previous, next) {},
  );
  return (
    container: container,
    dispose: () {
      subscription.close();
      container.dispose();
    },
  );
}

Snapshot _snapshot({List<DoseEvent> events = const []}) {
  return Snapshot(
    initialized: true,
    medications: const [
      Medication(
        id: 'morning-dose',
        name: 'Morning dose',
        dosage: '10 mg',
        notes: '',
        shape: PillShape.tablet,
        color: PillColor.sage,
        timesMinutes: [8 * 60],
        daysOfWeek: [],
      ),
    ],
    events: events,
    settings: AppSettings.defaults,
  );
}
