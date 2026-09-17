import 'package:meta/meta.dart';

@immutable
sealed class Failure {
  const Failure();

  String get code;
}

sealed class StorageFailure extends Failure {
  const StorageFailure();
}

final class StorageUnavailable extends StorageFailure {
  const StorageUnavailable();

  @override
  String get code => 'storage.unavailable';
}

final class StorageCorrupt extends StorageFailure {
  const StorageCorrupt();

  @override
  String get code => 'storage.corrupt';
}

final class StorageConstraintViolation extends StorageFailure {
  const StorageConstraintViolation(this.operation);

  final String operation;

  @override
  String get code => 'storage.constraint_violation';
}

final class StorageNotFound extends StorageFailure {
  const StorageNotFound(this.id);

  final String id;

  @override
  String get code => 'storage.not_found';
}
