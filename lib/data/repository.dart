import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vitalia/core/app_log.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/demo_cabinet.dart';
import 'package:vitalia/data/legacy_snapshot_codec.dart';
import 'package:vitalia/data/row_mapping.dart';

final class VitaliaRepository {
  VitaliaRepository(this._database, {SharedPreferences? legacyPreferences}) {
    _legacyPreferences = legacyPreferences;
  }

  static const legacySnapshotKey = 'vitalia.snapshot.v1';
  static const _initializedKey = 'database.initialized';

  final AppDatabase _database;
  SharedPreferences? _legacyPreferences;

  Stream<Result<List<Medication>, StorageFailure>> watchMedications() {
    return _watch(
      readsFrom: {
        _database.medications,
        _database.medicationTimes,
        _database.medicationDays,
      },
      load: _loadMedications,
      triggerSql: 'SELECT 1 AS medications_watch',
      sqliteOp: 'medications.watch.sqlite',
      formatOp: 'medications.watch.format',
    );
  }

  Stream<Result<List<DoseEvent>, StorageFailure>> watchDoseEventsSince(
    DateTime from,
  ) async* {
    final fromUtcMs = utcMs(DateTime(from.year, from.month, from.day));
    try {
      final query = _database.select(_database.doseEvents)
        ..where(
          (row) =>
              row.scheduledAtUtcMs.isBiggerOrEqualValue(fromUtcMs) |
              row.occurredAtUtcMs.isBiggerOrEqualValue(fromUtcMs),
        )
        ..orderBy([(row) => OrderingTerm.desc(row.occurredAtUtcMs)]);
      await for (final rows in query.watch()) {
        yield Ok([for (final row in rows) doseEventFromRow(row)]);
      }
    } on SqliteException catch (error, stack) {
      logUnexpected('vitalia.storage', 'events.watch.sqlite', error, stack);
      yield const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      logUnexpected('vitalia.storage', 'events.watch.format', error, stack);
      yield const Err(StorageCorrupt());
    }
  }

  Stream<Result<AppSettings, StorageFailure>> watchSettings() {
    return _watch(
      readsFrom: {_database.settings},
      load: _loadSettings,
      triggerSql: 'SELECT 1 AS settings_watch',
      sqliteOp: 'settings.watch.sqlite',
      formatOp: 'settings.watch.format',
    );
  }

  @useResult
  Future<Result<Snapshot, StorageFailure>> readSnapshot() async {
    try {
      return Ok(
        Snapshot(
          initialized: true,
          medications: await _loadMedications(),
          events: await _loadEvents(),
          settings: await _loadSettings(),
        ),
      );
    } on SqliteException catch (error, stack) {
      logUnexpected('vitalia.storage', 'snapshot.read.sqlite', error, stack);
      return const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      logUnexpected('vitalia.storage', 'snapshot.read.format', error, stack);
      return const Err(StorageCorrupt());
    }
  }

  @useResult
  Future<Result<void, StorageFailure>> initialize() async {
    final initialized = await _isInitialized();
    switch (initialized) {
      case Err(:final failure):
        return Err(failure);
      case Ok(value: true):
        return const Ok(null);
      case Ok(value: false):
        break;
    }
    final legacy = await _readLegacySnapshot();
    switch (legacy) {
      case Err(:final failure):
        return Err(failure);
      case Ok(:final value):
        final result = await _write('initialize', () async {
          final snapshot =
              value ??
              Snapshot(
                initialized: true,
                medications: demoCabinet(),
                events: const [],
                settings: AppSettings.defaults,
              );
          await _database.transaction(() async {
            await _replaceSnapshot(snapshot, clearExisting: false);
            await _database
                .into(_database.metadata)
                .insert(
                  MetadataCompanion.insert(key: _initializedKey, value: '1'),
                );
          });
        });
        if (result case Err()) return result;
        if (value != null) {
          final cleanup = await _removeLegacySnapshot();
          if (cleanup case Err()) return cleanup;
        }
        return const Ok(null);
    }
  }

  @useResult
  Future<Result<void, StorageFailure>> upsertMedication(
    Medication medication,
    DateTime now,
  ) {
    return _write('medication.upsert', () {
      return _database.transaction(() async {
        await _writeMedication(medication, now);
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> softDeleteMedication(
    String id,
    DateTime now,
  ) {
    return _write('medication.delete', () {
      return _database.transaction(() async {
        await (_database.update(
          _database.medications,
        )..where((row) => row.id.equals(id))).write(
          MedicationsCompanion(
            isDeleted: const Value(true),
            deletedAtUtcMs: Value(utcMs(now)),
            updatedAtUtcMs: Value(utcMs(now)),
          ),
        );
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> recordSlot({
    required DoseSlot slot,
    required DoseAction action,
    required DateTime now,
    required String eventId,
    int snoozeMinutes = 0,
  }) {
    return recordDose(
      slot.toEvent(
        id: eventId,
        at: now,
        action: action,
        snoozeMinutes: snoozeMinutes,
      ),
      decrementQuantity: action == DoseAction.taken,
    );
  }

  @useResult
  Future<Result<void, StorageFailure>> recordDose(
    DoseEvent event, {
    required bool decrementQuantity,
  }) {
    return _write('dose.record', () {
      return _database.transaction(() async {
        final resolved =
            await (_database.select(_database.doseEvents)..where(
                  (row) =>
                      row.medicationId.equals(event.medicationId) &
                      row.scheduledAtUtcMs.equals(utcMs(event.scheduledAt)) &
                      row.action.isIn(const ['taken', 'skipped']),
                ))
                .getSingleOrNull();
        if (resolved != null) return;
        await _insertEvent(event);
        if (!decrementQuantity) return;
        final medication = await (_database.select(
          _database.medications,
        )..where((row) => row.id.equals(event.medicationId))).getSingleOrNull();
        final quantity = medication?.quantity;
        if (medication == null || quantity == null) return;
        await (_database.update(
          _database.medications,
        )..where((row) => row.id.equals(event.medicationId))).write(
          MedicationsCompanion(
            quantity: Value(quantity > 0 ? quantity - 1 : 0),
            updatedAtUtcMs: Value(utcMs(event.at)),
          ),
        );
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> updateSettings(AppSettings settings) {
    return _write('settings.update', () {
      return _database.transaction(() async {
        await _writeSettings(settings);
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> restoreDemo(DateTime now) {
    return _write('cabinet.restore_demo', () {
      return _database.transaction(() async {
        await _retireCabinet(now);
        for (final medication in demoCabinet()) {
          await _writeMedication(medication, now);
        }
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> clearAll(DateTime now) {
    return _write('cabinet.clear', () {
      return _database.transaction(() async {
        await _retireCabinet(now);
        await _writeSettings(AppSettings.defaults);
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> flush() {
    return _write('database.flush', () async {
      await _database.customStatement('PRAGMA wal_checkpoint(PASSIVE)');
    });
  }

  Stream<Result<T, StorageFailure>> _watch<T>({
    required Set<ResultSetImplementation<dynamic, dynamic>> readsFrom,
    required Future<T> Function() load,
    required String triggerSql,
    required String sqliteOp,
    required String formatOp,
  }) async* {
    try {
      final trigger = _database.customSelect(triggerSql, readsFrom: readsFrom);
      await for (final _ in trigger.watch()) {
        yield Ok(await load());
      }
    } on SqliteException catch (error, stack) {
      logUnexpected('vitalia.storage', sqliteOp, error, stack);
      yield const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      logUnexpected('vitalia.storage', formatOp, error, stack);
      yield const Err(StorageCorrupt());
    }
  }

  Future<List<Medication>> _loadMedications() async {
    final medicationRows = await (_database.select(
      _database.medications,
    )..where((row) => row.isDeleted.equals(false))).get();
    final timeRows = await _database.select(_database.medicationTimes).get();
    final dayRows = await _database.select(_database.medicationDays).get();
    final timesByMedication = <String, List<int>>{};
    for (final row in timeRows) {
      (timesByMedication[row.medicationId] ??= []).add(row.minutes);
    }
    final daysByMedication = <String, List<int>>{};
    for (final row in dayRows) {
      (daysByMedication[row.medicationId] ??= []).add(row.weekday);
    }
    return [
      for (final row in medicationRows)
        medicationFromRow(
          row,
          timesMinutes: [...?timesByMedication[row.id]]..sort(),
          daysOfWeek: [...?daysByMedication[row.id]]..sort(),
        ),
    ];
  }

  Future<List<DoseEvent>> _loadEvents() async {
    final eventRows = await (_database.select(
      _database.doseEvents,
    )..orderBy([(row) => OrderingTerm.desc(row.occurredAtUtcMs)])).get();
    return [for (final row in eventRows) doseEventFromRow(row)];
  }

  Future<AppSettings> _loadSettings() async {
    return settingsFromRow(
      await _database.select(_database.settings).getSingle(),
    );
  }

  Future<void> _retireCabinet(DateTime now) async {
    await _database.delete(_database.doseEvents).go();
    await _database
        .update(_database.medications)
        .write(
          MedicationsCompanion(
            isDeleted: const Value(true),
            deletedAtUtcMs: Value(utcMs(now)),
            updatedAtUtcMs: Value(utcMs(now)),
          ),
        );
  }

  Future<void> _replaceSnapshot(
    Snapshot snapshot, {
    required bool clearExisting,
  }) async {
    if (clearExisting) {
      await _database.delete(_database.doseEvents).go();
      await _database.delete(_database.medicationDays).go();
      await _database.delete(_database.medicationTimes).go();
      await _database.delete(_database.medications).go();
      await _database.delete(_database.settings).go();
    }
    final importedAt = snapshot.events.isEmpty
        ? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true)
        : snapshot.events.last.at;
    for (final medication in snapshot.medications) {
      await _writeMedication(medication, importedAt);
    }
    for (final event in snapshot.events) {
      await _insertEvent(event);
    }
    await _writeSettings(snapshot.settings);
  }

  Future<void> _writeMedication(Medication medication, DateTime now) async {
    final existing = await (_database.select(
      _database.medications,
    )..where((row) => row.id.equals(medication.id))).getSingleOrNull();
    final stamp = utcMs(now);
    await _database
        .into(_database.medications)
        .insertOnConflictUpdate(
          MedicationsCompanion.insert(
            id: medication.id,
            name: medication.name,
            dosage: medication.dosage,
            notes: Value(medication.notes),
            shape: medication.shape.name,
            color: medication.color.name,
            quantity: Value(medication.quantity),
            refillThreshold: Value(medication.refillThreshold),
            isDeleted: const Value(false),
            createdAtUtcMs: existing?.createdAtUtcMs ?? stamp,
            updatedAtUtcMs: stamp,
            deletedAtUtcMs: const Value(null),
          ),
        );
    await (_database.delete(
      _database.medicationTimes,
    )..where((row) => row.medicationId.equals(medication.id))).go();
    await (_database.delete(
      _database.medicationDays,
    )..where((row) => row.medicationId.equals(medication.id))).go();
    for (final minutes in medication.timesMinutes) {
      await _database
          .into(_database.medicationTimes)
          .insert(
            MedicationTimesCompanion.insert(
              medicationId: medication.id,
              minutes: minutes,
            ),
          );
    }
    for (final weekday in medication.daysOfWeek) {
      await _database
          .into(_database.medicationDays)
          .insert(
            MedicationDaysCompanion.insert(
              medicationId: medication.id,
              weekday: weekday,
            ),
          );
    }
  }

  Future<void> _insertEvent(DoseEvent event) {
    return _database
        .into(_database.doseEvents)
        .insert(
          DoseEventsCompanion.insert(
            id: event.id,
            medicationId: event.medicationId,
            medicationName: event.medicationName,
            scheduledAtUtcMs: utcMs(event.scheduledAt),
            occurredAtUtcMs: utcMs(event.at),
            action: event.action.name,
            snoozeUntilUtcMs: Value(
              event.snoozeUntil?.toUtc().millisecondsSinceEpoch,
            ),
          ),
        );
  }

  Future<void> _writeSettings(AppSettings settings) {
    return _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            id: const Value(1),
            sound: settings.sound,
            vibration: settings.vibration,
            banners: settings.banners,
            snoozeMinutes: settings.snoozeMinutes,
          ),
        );
  }

  Future<Result<Snapshot?, StorageFailure>> _readLegacySnapshot() async {
    try {
      final preferences = _legacyPreferences ??=
          await SharedPreferences.getInstance();
      final raw = preferences.getString(legacySnapshotKey);
      if (raw == null) return const Ok(null);
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        return const Err(StorageCorrupt());
      }
      return Ok(decodeLegacySnapshot(decoded));
    } on FormatException catch (error, stack) {
      logUnexpected('vitalia.storage', 'legacy.decode', error, stack);
      return const Err(StorageCorrupt());
    } on PlatformException catch (error, stack) {
      logUnexpected('vitalia.storage', 'legacy.read.plugin', error, stack);
      return const Err(StorageUnavailable());
    } on MissingPluginException catch (error, stack) {
      logUnexpected(
        'vitalia.storage',
        'legacy.read.missing_plugin',
        error,
        stack,
      );
      return const Err(StorageUnavailable());
    }
  }

  Future<Result<bool, StorageFailure>> _isInitialized() async {
    try {
      final row = await (_database.select(
        _database.metadata,
      )..where((item) => item.key.equals(_initializedKey))).getSingleOrNull();
      return Ok(row != null);
    } on SqliteException catch (error, stack) {
      logUnexpected('vitalia.storage', 'initialize.read', error, stack);
      return const Err(StorageUnavailable());
    }
  }

  Future<Result<void, StorageFailure>> _removeLegacySnapshot() async {
    try {
      final preferences = _legacyPreferences ??=
          await SharedPreferences.getInstance();
      await preferences.remove(legacySnapshotKey);
      return const Ok(null);
    } on PlatformException catch (error, stack) {
      logUnexpected('vitalia.storage', 'legacy.remove.plugin', error, stack);
      return const Err(StorageUnavailable());
    } on MissingPluginException catch (error, stack) {
      logUnexpected(
        'vitalia.storage',
        'legacy.remove.missing_plugin',
        error,
        stack,
      );
      return const Err(StorageUnavailable());
    }
  }

  Future<Result<void, StorageFailure>> _write(
    String operation,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      return const Ok(null);
    } on SqliteException catch (error, stack) {
      logUnexpected('vitalia.storage', operation, error, stack);
      return Err(StorageConstraintViolation(operation));
    }
  }
}
