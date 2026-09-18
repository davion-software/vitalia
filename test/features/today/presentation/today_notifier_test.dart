import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalia/core/app_settings.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/data/repository.dart';
import 'package:vitalia/features/today/presentation/today_notifier.dart';
import 'package:vitalia/services/app_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('take intent publishes a taken slot after it is persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 8, 26, 8, 5);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        vitaliaRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'notifier-event'),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
      ],
    );
    addTearDown(container.dispose);

    final initial = await _waitForToday(
      container,
      (state) => state.due.isNotEmpty,
    );
    final slot = initial.due.first;
    final updatedFuture = _waitForToday(
      container,
      (state) => state.done
          .where(
            (item) => item.id == slot.id && item.status == SlotStatus.taken,
          )
          .isNotEmpty,
    );

    container.read(todayNotifierProvider.notifier).take(slot.id);

    final updated = await updatedFuture;
    expect(updated.takenCount, 1);
  });

  test('settings writes complete while Today is subscribed', () async {
    SharedPreferences.setMockInitialValues({});
    final now = DateTime(2026, 8, 26, 8, 5);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        vitaliaRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'notifier-event'),
        currentMinuteProvider.overrideWithValue(AsyncData(now)),
      ],
    );
    addTearDown(container.dispose);
    await _waitForToday(container, (state) => state.due.isNotEmpty);

    expect(
      await repository.updateSettings(
        AppSettings.defaults.copyWith(sound: false),
      ),
      isA<Ok<void, StorageFailure>>(),
    );
    final snapshot = await repository.readSnapshot();
    switch (snapshot) {
      case Ok(:final value):
        expect(value.settings.sound, isFalse);
      case Err(:final failure):
        fail('Unexpected storage failure: ${failure.code}');
    }
  });

  test('clock changes update Today without returning to loading', () async {
    SharedPreferences.setMockInitialValues({});
    final beforeDose = DateTime(2026, 8, 26, 7, 59, 59);
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = VitaliaRepository(database);
    expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        vitaliaRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(beforeDose)),
        idGeneratorProvider.overrideWithValue(() => 'notifier-event'),
        currentMinuteProvider.overrideWith((ref) => ticks.stream),
      ],
    );
    addTearDown(container.dispose);
    final transitions = <AsyncValue<TodayState>>[];
    final subscription = container.listen(
      todayNotifierProvider,
      (previous, next) => transitions.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    final initial = await _waitForToday(
      container,
      (state) =>
          state.later.where((slot) => slot.scheduledAt.hour == 8).isNotEmpty,
    );
    final slotId = initial.later
        .firstWhere((slot) => slot.scheduledAt.hour == 8)
        .id;
    transitions.clear();
    final updatedFuture = _waitForToday(
      container,
      (state) => state.due.where((slot) => slot.id == slotId).isNotEmpty,
    );

    ticks.add(DateTime(2026, 8, 26, 8));

    final updated = await updatedFuture;
    expect(updated.due.where((slot) => slot.id == slotId), isNotEmpty);
    expect(transitions, isNotEmpty);
    expect(transitions.every((state) => !state.isLoading), isTrue);
  });
}

Future<TodayState> _waitForToday(
  ProviderContainer container,
  bool Function(TodayState state) predicate,
) async {
  final current = container.read(todayNotifierProvider).value;
  if (current != null && predicate(current)) return current;

  final completer = Completer<TodayState>();
  final subscription = container.listen(todayNotifierProvider, (
    previous,
    next,
  ) {
    final value = next.value;
    if (!completer.isCompleted && value != null && predicate(value)) {
      completer.complete(value);
    }
  });
  try {
    return await completer.future.timeout(const Duration(seconds: 2));
  } finally {
    subscription.close();
  }
}
