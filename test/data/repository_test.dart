import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/legacy_snapshot_codec.dart';
import 'package:vitalia/data/repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(SharedPreferences.resetStatic);

  test('fresh database seeds the demo cabinet', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);

    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final result = await repository.readSnapshot();

    switch (result) {
      case Ok(:final value):
        expect(value.medications.map((item) => item.name), [
          'Vitamin D3',
          'Omega-3',
          'Lisinopril',
          'Magnesium',
        ]);
      case Err(:final failure):
        fail('Unexpected storage failure: ${failure.code}');
    }
  });

  test(
    'recording a taken dose decrements quantity and persists history',
    () async {
      SharedPreferences.setMockInitialValues({});
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = VitaliaRepository(database);
      expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
      final initial = await repository.readSnapshot();
      final snapshot = switch (initial) {
        Ok(:final value) => value,
        Err(:final failure) => throw TestFailure(failure.code),
      };
      final medication = snapshot.medications.first;
      final scheduledAt = DateTime(2026, 8, 26, 8);

      final result = await repository.recordDose(
        DoseEvent(
          id: 'event-1',
          medicationId: medication.id,
          medicationName: medication.name,
          scheduledAt: scheduledAt,
          at: scheduledAt.add(const Duration(minutes: 5)),
          action: DoseAction.taken,
        ),
        decrementQuantity: true,
      );

      expect(result, isA<Ok<void, StorageFailure>>());
      final updated = await repository.readSnapshot();
      switch (updated) {
        case Ok(:final value):
          expect(value.events.single.action, DoseAction.taken);
          expect(value.medications.first.quantity, 7);
        case Err(:final failure):
          fail('Unexpected storage failure: ${failure.code}');
      }
    },
  );

  test(
    'legacy snapshot migrates once and clears its key after commit',
    () async {
      final legacy = Snapshot.empty.copyWith(medications: [demoMedication]);
      SharedPreferences.setMockInitialValues({
        VitaliaRepository.legacySnapshotKey: jsonEncode(
          encodeLegacySnapshot(legacy),
        ),
      });
      final preferences = await SharedPreferences.getInstance();
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final repository = VitaliaRepository(
        database,
        legacyPreferences: preferences,
      );

      expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
      final migrated = await repository.readSnapshot();
      switch (migrated) {
        case Ok(:final value):
          expect(value.medications.single.name, 'Migrated medicine');
        case Err(:final failure):
          fail('Unexpected storage failure: ${failure.code}');
      }
      expect(
        preferences.getString(VitaliaRepository.legacySnapshotKey),
        isNull,
      );
    },
  );

  test('database enforces medication time range', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());

    expect(
      () => database.customStatement(
        'INSERT INTO medication_times (medication_id, minutes) '
        "VALUES ('demo-vitamin-d3', 1440)",
      ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('updateSettings persists the singleton settings row', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());

    expect(
      await repository.updateSettings(
        AppSettings.defaults.copyWith(sound: false),
      ),
      isA<Ok<void, StorageFailure>>(),
    );
    switch (await repository.readSnapshot()) {
      case Ok(:final value):
        expect(value.settings.sound, isFalse);
      case Err(:final failure):
        fail('Unexpected storage failure: ${failure.code}');
    }
  });

  test('dose event watch ignores events older than the window', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final snapshot = switch (await repository.readSnapshot()) {
      Ok(:final value) => value,
      Err(:final failure) => throw TestFailure(failure.code),
    };
    final medication = snapshot.medications.first;
    expect(
      await repository.recordDose(
        DoseEvent(
          id: 'old-event',
          medicationId: medication.id,
          medicationName: medication.name,
          scheduledAt: DateTime(2024, 1, 1, 8),
          at: DateTime(2024, 1, 1, 8, 5),
          action: DoseAction.taken,
        ),
        decrementQuantity: false,
      ),
      isA<Ok<void, StorageFailure>>(),
    );
    expect(
      await repository.recordDose(
        DoseEvent(
          id: 'recent-event',
          medicationId: medication.id,
          medicationName: medication.name,
          scheduledAt: DateTime(2026, 8, 26, 8),
          at: DateTime(2026, 8, 26, 8, 5),
          action: DoseAction.skipped,
        ),
        decrementQuantity: false,
      ),
      isA<Ok<void, StorageFailure>>(),
    );

    final result = await repository.watchDoseEventsSince(DateTime(2026)).first;
    switch (result) {
      case Ok(:final value):
        expect(value.map((event) => event.id), ['recent-event']);
      case Err(:final failure):
        fail('Unexpected storage failure: ${failure.code}');
    }
  });
}

const demoMedication = Medication(
  id: 'legacy-medication',
  name: 'Migrated medicine',
  dosage: '5 mg',
  notes: '',
  shape: PillShape.tablet,
  color: PillColor.sage,
  timesMinutes: [480],
  daysOfWeek: [],
);
