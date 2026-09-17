import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/data/repository.dart';
import 'package:vitalia/data/store.dart';
import 'package:vitalia/domain/entities.dart';

void main() {
  test('first load seeds the demo cabinet', () async {
    final store = VitaliaStore(
      repository: MemoryRepository(),
      clock: () => DateTime(2026, 8, 26, 7),
    );
    await store.load();
    expect(store.medications.map((m) => m.name), [
      'Vitamin D3',
      'Omega-3',
      'Lisinopril',
      'Magnesium',
    ]);
    expect(store.todaySlots, hasLength(5));
  });

  test('take decrements quantity and logs history', () async {
    var now = DateTime(2026, 8, 26, 8, 5);
    final store = VitaliaStore(
      repository: MemoryRepository(),
      clock: () => now,
    );
    await store.load();
    final d3 = store.todaySlots.firstWhere(
      (slot) => slot.medication.name == 'Vitamin D3',
    );
    expect(d3.medication.quantity, 8);
    await store.take(d3);
    expect(
      store.medications.firstWhere((m) => m.name == 'Vitamin D3').quantity,
      7,
    );
    expect(store.recentEvents.first.action, DoseAction.taken);
    expect(
      store.todaySlots
          .firstWhere((slot) => slot.medication.name == 'Vitamin D3')
          .status,
      SlotStatus.taken,
    );
  });

  test('snooze hides the alarm until the snooze elapses', () async {
    var now = DateTime(2026, 8, 26, 20, 5);
    final store = VitaliaStore(
      repository: MemoryRepository(),
      clock: () => now,
    );
    await store.load();
    expect(store.ringingSlot?.medication.name, 'Lisinopril');
    await store.snooze(store.ringingSlot!);
    expect(store.ringingSlot, isNull);
    now = DateTime(2026, 8, 26, 20, 16);
    store.tick();
    expect(store.ringingSlot?.medication.name, 'Lisinopril');
  });

  test('data survives a second store on the same repository', () async {
    final repo = MemoryRepository();
    final first = VitaliaStore(
      repository: repo,
      clock: () => DateTime(2026, 8, 26, 7),
    );
    await first.load();
    await first.clearAll();
    expect(first.medications, isEmpty);

    final second = VitaliaStore(
      repository: repo,
      clock: () => DateTime(2026, 8, 26, 7),
    );
    await second.load();
    expect(second.medications, isEmpty);

    await second.restoreDemo();
    expect(second.medications, hasLength(4));
  });

  test('upsert and delete update the cabinet', () async {
    final store = VitaliaStore(
      repository: MemoryRepository(),
      clock: () => DateTime(2026, 8, 26, 7),
    );
    await store.load();
    await store.upsertMedication(
      Medication(
        id: 'aspirin',
        name: 'Aspirin',
        dosage: '81 mg',
        notes: '',
        shape: PillShape.tablet,
        color: PillColor.blush,
        timesMinutes: const [8 * 60],
        daysOfWeek: const [],
      ),
    );
    expect(store.medications.any((med) => med.name == 'Aspirin'), isTrue);
    expect(store.todaySlots, hasLength(6));

    await store.deleteMedication('aspirin');
    expect(store.medications.any((med) => med.name == 'Aspirin'), isFalse);
    expect(store.todaySlots, hasLength(5));
  });
}
