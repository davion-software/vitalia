import 'package:vitalia/core/storage_failure.dart';

String storageFailureMessage(StorageFailure failure) {
  switch (failure) {
    case StorageUnavailable():
      return 'Storage is temporarily unavailable.';
    case StorageCorrupt():
      return 'Saved data could not be read.';
    case StorageConstraintViolation():
      return 'That change could not be saved.';
    case StorageNotFound():
      return 'That item is no longer available.';
  }
}
