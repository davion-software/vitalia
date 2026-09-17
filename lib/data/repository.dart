import 'dart:convert';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/demo_cabinet.dart';
import 'package:vitalia/data/legacy_snapshot_codec.dart';

final class VitaliaRepository {
  VitaliaRepository(this._database, {SharedPreferences? legacyPreferences}) {
    _legacyPreferences = legacyPreferences;
  }

  static const legacySnapshotKey = 'vitalia.snapshot.v1';
  static const _initializedKey = 'database.initialized';

  final AppDatabase _database;
  SharedPreferences? _legacyPreferences;

  Stream<Result<Snapshot, StorageFailure>> watchSnapshot() async* {
    try {
      final trigger = _database.customSelect(
        'SELECT 1',
        readsFrom: {
          _database.medications,
          _database.medicationTimes,
          _database.medicationDays,
          _database.doseEvents,
          _database.settings,
        },
      );
      await for (final _ in trigger.watch()) {
        yield Ok(await _loadSnapshot());
      }
    } on SqliteException catch (error, stack) {
      _log('snapshot.watch.sqlite', error, stack);
      yield const Err(StorageUnavailable());
    } on FormatException catch (error, stack) {
      _log('snapshot.watch.format', error, stack);
      yield const Err(StorageCorrupt());
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
        final changed =
            await (_database.update(
              _database.medications,
            )..where((row) => row.id.equals(id))).write(
              MedicationsCompanion(
                isDeleted: const Value(true),
                deletedAtUtcMs: Value(_utcMs(now)),
                updatedAtUtcMs: Value(_utcMs(now)),
              ),
            );
        if (changed == 0) return;
      });
    });
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
                      row.scheduledAtUtcMs.equals(_utcMs(event.scheduledAt)) &
                      row.action.isIn(const ['taken', 'skipped']),
                ))
                .getSingleOrNull();
        if (resolved != null) return;
        await _database
            .into(_database.doseEvents)
            .insert(
              DoseEventsCompanion.insert(
                id: event.id,
                medicationId: event.medicationId,
                medicationName: event.medicationName,
                scheduledAtUtcMs: _utcMs(event.scheduledAt),
                occurredAtUtcMs: _utcMs(event.at),
                action: event.action.name,
                snoozeUntilUtcMs: Value(
                  event.snoozeUntil?.toUtc().millisecondsSinceEpoch,
                ),
              ),
            );
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
            updatedAtUtcMs: Value(_utcMs(event.at)),
          ),
        );
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> updateSettings(AppSettings settings) {
    return _write('settings.update', () {
      return _database.transaction(() async {
        await _database
            .into(_database.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(
                sound: settings.sound,
                vibration: settings.vibration,
                banners: settings.banners,
                snoozeMinutes: settings.snoozeMinutes,
              ),
            );
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> restoreDemo(DateTime now) {
    return _write('cabinet.restore_demo', () {
      return _database.transaction(() async {
        await _database.delete(_database.doseEvents).go();
        await _database
            .update(_database.medications)
            .write(
              MedicationsCompanion(
                isDeleted: const Value(true),
                deletedAtUtcMs: Value(_utcMs(now)),
                updatedAtUtcMs: Value(_utcMs(now)),
              ),
            );
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
        await _database.delete(_database.doseEvents).go();
        await _database
            .update(_database.medications)
            .write(
              MedicationsCompanion(
                isDeleted: const Value(true),
                deletedAtUtcMs: Value(_utcMs(now)),
                updatedAtUtcMs: Value(_utcMs(now)),
              ),
            );
        await _database
            .into(_database.settings)
            .insertOnConflictUpdate(
              SettingsCompanion.insert(
                sound: true,
                vibration: true,
                banners: true,
                snoozeMinutes: 10,
              ),
            );
      });
    });
  }

  @useResult
  Future<Result<void, StorageFailure>> flush() {
    return _write('database.flush', () async {
      await _database.customStatement('PRAGMA wal_checkpoint(PASSIVE)');
    });
  }

  Future<Snapshot> _loadSnapshot() async {
    final medicationRows = await (_database.select(
      _database.medications,
    )..where((row) => row.isDeleted.equals(false))).get();
    final timeRows = await _database.select(_database.medicationTimes).get();
    final dayRows = await _database.select(_database.medicationDays).get();
    final eventRows = await (_database.select(
      _database.doseEvents,
    )..orderBy([(row) => OrderingTerm.desc(row.occurredAtUtcMs)])).get();
    final settingsRow = await _database.select(_database.settings).getSingle();
    return Snapshot(
      initialized: true,
      medications: [
        for (final row in medicationRows)
          Medication(
            id: row.id,
            name: row.name,
            dosage: row.dosage,
            notes: row.notes,
            shape: _pillShape(row.shape),
            color: _pillColor(row.color),
            timesMinutes: [
              for (final time in timeRows)
                if (time.medicationId == row.id) time.minutes,
            ]..sort(),
            daysOfWeek: [
              for (final day in dayRows)
                if (day.medicationId == row.id) day.weekday,
            ]..sort(),
            quantity: row.quantity,
            refillThreshold: row.refillThreshold,
          ),
      ],
      events: [
        for (final row in eventRows)
          DoseEvent(
            id: row.id,
            medicationId: row.medicationId,
            medicationName: row.medicationName,
            scheduledAt: _localDateTime(row.scheduledAtUtcMs),
            at: _localDateTime(row.occurredAtUtcMs),
            action: _doseAction(row.action),
            snoozeUntil: switch (row.snoozeUntilUtcMs) {
              final int milliseconds => _localDateTime(milliseconds),
              null => null,
            },
          ),
      ],
      settings: AppSettings(
        sound: settingsRow.sound,
        vibration: settingsRow.vibration,
        banners: settingsRow.banners,
        snoozeMinutes: settingsRow.snoozeMinutes,
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
      await _database
          .into(_database.doseEvents)
          .insert(
            DoseEventsCompanion.insert(
              id: event.id,
              medicationId: event.medicationId,
              medicationName: event.medicationName,
              scheduledAtUtcMs: _utcMs(event.scheduledAt),
              occurredAtUtcMs: _utcMs(event.at),
              action: event.action.name,
              snoozeUntilUtcMs: Value(
                event.snoozeUntil?.toUtc().millisecondsSinceEpoch,
              ),
            ),
          );
    }
    await _database
        .into(_database.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            sound: snapshot.settings.sound,
            vibration: snapshot.settings.vibration,
            banners: snapshot.settings.banners,
            snoozeMinutes: snapshot.settings.snoozeMinutes,
          ),
        );
  }

  Future<void> _writeMedication(Medication medication, DateTime now) async {
    final existing = await (_database.select(
      _database.medications,
    )..where((row) => row.id.equals(medication.id))).getSingleOrNull();
    final stamp = _utcMs(now);
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
      _log('legacy.decode', error, stack);
      return const Err(StorageCorrupt());
    } on PlatformException catch (error, stack) {
      _log('legacy.read.plugin', error, stack);
      return const Err(StorageUnavailable());
    } on MissingPluginException catch (error, stack) {
      _log('legacy.read.missing_plugin', error, stack);
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
      _log('initialize.read', error, stack);
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
      _log('legacy.remove.plugin', error, stack);
      return const Err(StorageUnavailable());
    } on MissingPluginException catch (error, stack) {
      _log('legacy.remove.missing_plugin', error, stack);
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
      _log(operation, error, stack);
      return Err(StorageConstraintViolation(operation));
    }
  }

  static int _utcMs(DateTime value) => value.toUtc().millisecondsSinceEpoch;

  static DateTime _localDateTime(int milliseconds) =>
      DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true).toLocal();

  static PillShape _pillShape(String name) {
    for (final value in PillShape.values) {
      if (value.name == name) return value;
    }
    throw const FormatException('Unknown medication shape');
  }

  static PillColor _pillColor(String name) {
    for (final value in PillColor.values) {
      if (value.name == name) return value;
    }
    throw const FormatException('Unknown medication color');
  }

  static DoseAction _doseAction(String name) {
    for (final value in DoseAction.values) {
      if (value.name == name) return value;
    }
    throw const FormatException('Unknown dose action');
  }

  static void _log(String operation, Object error, StackTrace stack) {
    developer.log(
      operation,
      name: 'vitalia.storage',
      error: error,
      stackTrace: stack,
    );
  }
}
