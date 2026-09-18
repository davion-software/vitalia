import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/repository.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) =>
      throw UnimplementedError('Override appDatabaseProvider in bootstrap'),
);

final vitaliaRepositoryProvider = Provider<VitaliaRepository>(
  (ref) => VitaliaRepository(ref.watch(appDatabaseProvider)),
);

final medicationsProvider =
    StreamProvider<Result<List<Medication>, StorageFailure>>(
      (ref) => ref.watch(vitaliaRepositoryProvider).watchMedications(),
    );

final settingsProvider = StreamProvider<Result<AppSettings, StorageFailure>>(
  (ref) => ref.watch(vitaliaRepositoryProvider).watchSettings(),
);
