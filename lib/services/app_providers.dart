import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/id_generator.dart';

final clockProvider = Provider<Clock>(
  (ref) => throw UnimplementedError('Override clockProvider in bootstrap'),
);

final idGeneratorProvider = Provider<IdGenerator>(
  (ref) =>
      throw UnimplementedError('Override idGeneratorProvider in bootstrap'),
);

final currentTimeProvider = StreamProvider<DateTime>((ref) async* {
  final appClock = ref.watch(clockProvider);
  yield appClock.now();
  while (ref.mounted) {
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!ref.mounted) return;
    yield appClock.now();
  }
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
