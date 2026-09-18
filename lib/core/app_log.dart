import 'dart:developer' as developer;

import 'package:vitalia/core/storage_failure.dart';

void logUnexpected(
  String name,
  String operation,
  Object error,
  StackTrace stack,
) {
  developer.log(operation, name: name, error: error, stackTrace: stack);
}

void logFailure(String name, StorageFailure failure) {
  developer.log(failure.code, name: name);
}

void Function(Object error, StackTrace stack) unexpectedLogger(
  String name,
  String operation,
) {
  return (error, stack) => logUnexpected(name, operation, error, stack);
}
