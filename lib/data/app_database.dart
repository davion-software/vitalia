import 'package:drift/drift.dart';

part 'app_database.g.dart';

@DataClassName('MetadataRow')
class Metadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};

  @override
  bool get isStrict => true;
}

@DataClassName('MedicationRow')
class Medications extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get dosage => text().withLength(min: 1, max: 120)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get shape => text()();
  TextColumn get color => text()();
  IntColumn get quantity => integer().nullable()();
  IntColumn get refillThreshold => integer().nullable()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get updatedAtUtcMs => integer()();
  IntColumn get deletedAtUtcMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (shape IN ('capsule', 'tablet', 'softgel'))",
    "CHECK (color IN ('sage', 'moss', 'terracotta', 'clay', 'sand', 'slate', 'ink', 'blush'))",
    'CHECK (quantity IS NULL OR quantity >= 0)',
    'CHECK (refill_threshold IS NULL OR refill_threshold >= 0)',
    'CHECK ((quantity IS NULL) = (refill_threshold IS NULL))',
    'CHECK ((is_deleted = 0 AND deleted_at_utc_ms IS NULL) OR (is_deleted = 1 AND deleted_at_utc_ms IS NOT NULL))',
  ];

  @override
  bool get isStrict => true;
}

@DataClassName('MedicationTimeRow')
class MedicationTimes extends Table {
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  IntColumn get minutes => integer()();

  @override
  Set<Column<Object>> get primaryKey => {medicationId, minutes};

  @override
  List<String> get customConstraints => const [
    'CHECK (minutes BETWEEN 0 AND 1439)',
  ];

  @override
  bool get isStrict => true;
}

@DataClassName('MedicationDayRow')
class MedicationDays extends Table {
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  IntColumn get weekday => integer()();

  @override
  Set<Column<Object>> get primaryKey => {medicationId, weekday};

  @override
  List<String> get customConstraints => const [
    'CHECK (weekday BETWEEN 1 AND 7)',
  ];

  @override
  bool get isStrict => true;
}

@DataClassName('DoseEventRow')
class DoseEvents extends Table {
  TextColumn get id => text()();
  TextColumn get medicationId =>
      text().references(Medications, #id, onDelete: KeyAction.cascade)();
  TextColumn get medicationName => text().withLength(min: 1, max: 120)();
  IntColumn get scheduledAtUtcMs => integer()();
  IntColumn get occurredAtUtcMs => integer()();
  TextColumn get action => text().check(
    // Drift's schema DSL resolves this getter to the generated column.
    // ignore: recursive_getters
    action.isIn(const ['taken', 'skipped', 'snoozed']),
  )();
  IntColumn get snoozeUntilUtcMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  bool get isStrict => true;
}

@DataClassName('SettingsRow')
class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  BoolColumn get sound => boolean()();
  BoolColumn get vibration => boolean()();
  BoolColumn get banners => boolean()();
  IntColumn get snoozeMinutes => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    'CHECK (id = 1)',
    'CHECK (snooze_minutes BETWEEN 1 AND 60)',
  ];

  @override
  bool get isStrict => true;
}

@DriftDatabase(
  tables: [
    Metadata,
    Medications,
    MedicationTimes,
    MedicationDays,
    DoseEvents,
    Settings,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await customStatement(
        'CREATE INDEX dose_events_scheduled_idx '
        'ON dose_events (scheduled_at_utc_ms DESC)',
      );
      await customStatement(
        'CREATE INDEX dose_events_medication_idx '
        'ON dose_events (medication_id, scheduled_at_utc_ms)',
      );
      await customStatement(
        'CREATE TRIGGER dose_events_snooze_insert BEFORE INSERT ON dose_events '
        "WHEN (NEW.action = 'snoozed') != "
        '(NEW.snooze_until_utc_ms IS NOT NULL) '
        "BEGIN SELECT RAISE(ABORT, 'invalid snooze event'); END",
      );
      await customStatement(
        'CREATE TRIGGER dose_events_snooze_update BEFORE UPDATE ON dose_events '
        "WHEN (NEW.action = 'snoozed') != "
        '(NEW.snooze_until_utc_ms IS NOT NULL) '
        "BEGIN SELECT RAISE(ABORT, 'invalid snooze event'); END",
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = FULL');
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA busy_timeout = 5000');
    },
  );
}
