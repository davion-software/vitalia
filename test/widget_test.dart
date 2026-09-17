import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitalia/app/app.dart';
import 'package:vitalia/data/repository.dart';
import 'package:vitalia/data/store.dart';

Future<VitaliaStore> pumpVitalia(
  WidgetTester tester, {
  DateTime? now,
  VitaliaRepository? repository,
}) async {
  tester.view.physicalSize = const Size(1200, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final time = now ?? DateTime(2026, 8, 26, 7, 0);
  final store = VitaliaStore(
    repository: repository ?? MemoryRepository(),
    clock: () => time,
  );
  await store.load();
  await tester.pumpWidget(VitaliaApp(store: store, liveTick: false));
  await tester.pump();
  return store;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo cabinet seeds Today without the counter demo', (
    tester,
  ) async {
    await pumpVitalia(tester);
    expect(find.text('Never miss a dose.'), findsOneWidget);
    expect(find.textContaining('Vitamin D3'), findsWidgets);
    expect(
      find.text('You have pushed the button this many times:'),
      findsNothing,
    );
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('Refill soon'), findsOneWidget);
  });

  testWidgets('four tabs open', (tester) async {
    await pumpVitalia(tester);
    await tester.tap(find.text('Meds'));
    await tester.pumpAndSettle();
    expect(find.text('Cabinet'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('This week'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Alarms ring while Vitalia is open'),
      findsOneWidget,
    );
  });

  testWidgets('adding a medication shows it on Today', (tester) async {
    final store = await pumpVitalia(tester);
    await tester.tap(find.text('Meds'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Aspirin');
    await tester.enterText(find.byType(TextFormField).at(1), '81 mg');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(store.medications.any((med) => med.name == 'Aspirin'), isTrue);
    expect(find.text('Aspirin'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.text('Aspirin'), findsWidgets);
  });

  testWidgets('Settings test alarm offers Take, Snooze, and Skip', (
    tester,
  ) async {
    await pumpVitalia(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Test alarm'));
    await tester.tap(find.text('Test alarm'));
    await tester.pump();

    expect(find.text('Take now'), findsOneWidget);
    expect(find.text('Skip'), findsWidgets);
    expect(find.text('Snooze 10 min'), findsOneWidget);

    await tester.tap(find.text('Take now'));
    await tester.pump();
    expect(find.text('Take now'), findsNothing);
  });

  testWidgets('a due dose opens the alarm overlay', (tester) async {
    await pumpVitalia(tester, now: DateTime(2026, 8, 26, 8, 5));
    expect(find.text('Take now'), findsOneWidget);
    expect(find.text('Dose due'), findsOneWidget);
  });

  testWidgets('alarm overlay fits a short phone', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final store = VitaliaStore(
      repository: MemoryRepository(),
      clock: () => DateTime(2026, 8, 26, 8, 5),
    );
    await store.load();
    await tester.pumpWidget(VitaliaApp(store: store, liveTick: false));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Take now'), findsOneWidget);
  });
}
