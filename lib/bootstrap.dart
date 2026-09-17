import 'dart:developer' as developer;
import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/app.dart';
import 'package:vitalia/core/id_generator.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/database_connection.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/data/repository.dart';
import 'package:vitalia/services/app_providers.dart';
import 'package:vitalia/theme/palette.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: VitaliaPalette.paper,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final database = AppDatabase(await openDatabaseConnection());
  final repository = VitaliaRepository(database);
  final initialization = await repository.initialize();
  switch (initialization) {
    case Ok():
      break;
    case Err(:final failure):
      developer.log(failure.code, name: 'vitalia.bootstrap');
  }

  const appClock = Clock();
  final idGenerator = _createIdGenerator(appClock, Random.secure());
  runApp(
    ProviderScope(
      retry: (count, error) => null,
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        vitaliaRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(appClock),
        idGeneratorProvider.overrideWithValue(idGenerator),
      ],
      child: const VitaliaApp(),
    ),
  );
}

IdGenerator _createIdGenerator(Clock appClock, Random random) {
  return () {
    final timestamp = appClock.now().microsecondsSinceEpoch.toRadixString(36);
    final noise = random.nextInt(0x7fffffff).toRadixString(36);
    return '$timestamp$noise';
  };
}

void _installErrorHandlers() {
  FlutterError.onError = (details) {
    try {
      FlutterError.presentError(details);
      developer.log(
        details.exceptionAsString(),
        name: 'vitalia.flutter',
        error: details.exception,
        stackTrace: details.stack,
      );
      // Licensed error-handler swallow marker: // ignore: swallowed_catch
    } on Object catch (_) {
      // Error handlers must never throw and recursively invoke themselves.
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    try {
      developer.log(
        'uncaught async error',
        name: 'vitalia.platform',
        error: error,
        stackTrace: stack,
      );
      if (kDebugMode) debugPrint('$error\n$stack');
      // Licensed error-handler swallow marker: // ignore: swallowed_catch
    } on Object catch (_) {
      // Error handlers must never throw and recursively invoke themselves.
    }
    return true;
  };
}
