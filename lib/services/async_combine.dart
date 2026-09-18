import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';

AsyncValue<(A, B)> combineAsync2<A, B>(
  AsyncValue<A> first,
  AsyncValue<B> second,
) {
  return first.when(
    data: (firstValue) => second.when(
      data: (secondValue) => AsyncData((firstValue, secondValue)),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    ),
    error: AsyncError.new,
    loading: AsyncLoading.new,
  );
}

AsyncValue<(A, B, C)> combineAsync3<A, B, C>(
  AsyncValue<A> first,
  AsyncValue<B> second,
  AsyncValue<C> third,
) {
  return combineAsync2(first, second).when(
    data: (pair) => third.when(
      data: (thirdValue) => AsyncData((pair.$1, pair.$2, thirdValue)),
      error: AsyncError.new,
      loading: AsyncLoading.new,
    ),
    error: AsyncError.new,
    loading: AsyncLoading.new,
  );
}

R foldResults2<A, B, R>({
  required Result<A, StorageFailure> first,
  required Result<B, StorageFailure> second,
  required R Function(A first, B second) onOk,
  required R Function(StorageFailure failure) onErr,
}) {
  return switch ((first, second)) {
    (Err(:final failure), _) => onErr(failure),
    (_, Err(:final failure)) => onErr(failure),
    (Ok(value: final firstValue), Ok(value: final secondValue)) => onOk(
      firstValue,
      secondValue,
    ),
  };
}

R foldResults3<A, B, C, R>({
  required Result<A, StorageFailure> first,
  required Result<B, StorageFailure> second,
  required Result<C, StorageFailure> third,
  required R Function(A first, B second, C third) onOk,
  required R Function(StorageFailure failure) onErr,
}) {
  return switch ((first, second, third)) {
    (Err(:final failure), _, _) => onErr(failure),
    (_, Err(:final failure), _) => onErr(failure),
    (_, _, Err(:final failure)) => onErr(failure),
    (
      Ok(value: final firstValue),
      Ok(value: final secondValue),
      Ok(value: final thirdValue),
    ) =>
      onOk(firstValue, secondValue, thirdValue),
  };
}
