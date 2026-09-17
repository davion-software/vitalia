import 'package:meta/meta.dart';
import 'package:vitalia/core/storage_failure.dart';

@immutable
sealed class Result<T, F extends Failure> {
  const Result();
}

final class Ok<T, F extends Failure> extends Result<T, F> {
  const Ok(this.value);

  final T value;
}

final class Err<T, F extends Failure> extends Result<T, F> {
  const Err(this.failure);

  final F failure;
}
