import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/id_generator.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';

final clockProvider = Provider<Clock>(
  (ref) => throw UnimplementedError('Override clockProvider in bootstrap'),
);

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) =>
      throw UnimplementedError('Override idGeneratorProvider in bootstrap'),
);

final currentMinuteProvider = StreamProvider<DateTime>((ref) {
  final appClock = ref.watch(clockProvider);
  return Stream<DateTime>.multi((controller) {
    Timer? timer;

    void emitAndSchedule() {
      final now = appClock.now();
      controller.add(now);
      final nextMinute = DateTime(
        now.year,
        now.month,
        now.day,
        now.hour,
        now.minute + 1,
      );
      timer = Timer(nextMinute.difference(now), emitAndSchedule);
    }

    controller.onCancel = () => timer?.cancel();
    emitAndSchedule();
  });
});

final doseEventsProvider =
    StreamProvider<Result<List<DoseEvent>, StorageFailure>>((ref) {
      final now = ref.watch(clockProvider).now();
      final from = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(doseEventLookback);
      return ref.watch(vitaliaRepositoryProvider).watchDoseEventsSince(from);
    });

final class TestAlarmNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;

  void stop() => state = false;
}

final testAlarmProvider = NotifierProvider<TestAlarmNotifier, bool>(
  TestAlarmNotifier.new,
);
