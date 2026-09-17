import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  test('take intent publishes a taken slot from the database stream', () async {
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
        currentTimeProvider.overrideWithValue(AsyncData(now)),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      todayNotifierProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    final initial = await container.read(todayNotifierProvider.future);
    final slot = initial.due.first;
    final persisted = repository.watchSnapshot().firstWhere(
      (result) => switch (result) {
        Ok(:final value) =>
          value.events
              .where((event) => event.id == 'notifier-event')
              .isNotEmpty,
        Err() => false,
      },
    );

    container.read(todayNotifierProvider.notifier).take(slot.id);

    await persisted.timeout(const Duration(seconds: 2));
    container.invalidate(todayNotifierProvider);
    final updated = await container.read(todayNotifierProvider.future);
    expect(
      updated.done
          .where(
            (item) => item.id == slot.id && item.status == SlotStatus.taken,
          )
          .isNotEmpty,
      isTrue,
    );
    expect(updated.takenCount, 1);
  });
}
