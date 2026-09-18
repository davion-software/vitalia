import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/services/app_providers.dart';

void main() {
  testWidgets('the minute clock emits only at the next minute boundary', (
    tester,
  ) async {
    final start = DateTime(2026, 8, 26, 10, 15, 42);
    final bindingStart = tester.binding.clock.now();
    final appClock = Clock(
      () => start.add(tester.binding.clock.now().difference(bindingStart)),
    );
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(appClock)],
    );
    final emitted = <DateTime>[];
    final subscription = container.listen(currentMinuteProvider, (
      previous,
      next,
    ) {
      final value = next.value;
      if (value != null) emitted.add(value);
    }, fireImmediately: true);
    try {
      await tester.pump();
      expect(emitted, [start]);

      await tester.pump(const Duration(seconds: 17));
      expect(emitted, [start]);

      await tester.pump(const Duration(seconds: 1));
      expect(emitted, [start, DateTime(2026, 8, 26, 10, 16)]);
    } finally {
      subscription.close();
      container.dispose();
    }
  });
}
