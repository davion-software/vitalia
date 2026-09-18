import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:vitalia/data/database_pragmas.dart';

Future<QueryExecutor> openDatabaseConnection() async {
  final directory = await getApplicationSupportDirectory();
  final file = File(path.join(directory.path, 'vitalia.sqlite'));
  return NativeDatabase.createInBackground(
    file,
    setup: (database) {
      databaseSetupPragmas.forEach(database.execute);
    },
  );
}
