import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AsyncPage<T> extends StatelessWidget {
  const AsyncPage({
    required this.value,
    required this.builder,
    required this.errorMessage,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text(errorMessage)),
      data: builder,
    );
  }
}
