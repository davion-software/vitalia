import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/repository.dart';

final appDatabaseProvider = Provider<AppDatabase>(
  (ref) =>
      throw UnimplementedError('Override appDatabaseProvider in bootstrap'),
);

final vitaliaRepositoryProvider = Provider<VitaliaRepository>(
  (ref) => VitaliaRepository(ref.watch(appDatabaseProvider)),
);
