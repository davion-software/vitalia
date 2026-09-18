import 'dart:async';

import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalia/app.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/app_database.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/data/repository.dart';
import 'package:vitalia/services/app_providers.dart';

Future<void> pumpAppFrames(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> pumpVitalia(
  WidgetTester tester, {
  DateTime? at,
  Stream<DateTime>? timeStream,
  Size size = const Size(1200, 2400),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({});
  final now = at ?? DateTime(2026, 8, 26, 7);
  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  final repository = VitaliaRepository(database);
  expect(await repository.initialize(), isA<Ok<void, StorageFailure>>());
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        vitaliaRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(Clock.fixed(now)),
        idGeneratorProvider.overrideWithValue(() => 'widget-medication'),
        if (timeStream == null)
          currentMinuteProvider.overrideWithValue(AsyncData(now))
        else
          currentMinuteProvider.overrideWith((ref) => timeStream),
      ],
      child: const VitaliaApp(),
    ),
  );
  await pumpAppFrames(tester);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('demo cabinet renders Today', (tester) async {
    await pumpVitalia(tester);

    expect(find.text('Never miss a dose.'), findsOneWidget);
    expect(find.textContaining('Vitamin D3'), findsWidgets);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('Refill soon'), findsOneWidget);
  });

  testWidgets('Today stays visible when the clock changes', (tester) async {
    final now = DateTime(2026, 8, 26, 7);
    final ticks = StreamController<DateTime>();
    addTearDown(ticks.close);
    await pumpVitalia(tester, at: now, timeStream: ticks.stream);
    expect(find.text('Never miss a dose.'), findsOneWidget);

    ticks.add(now.add(const Duration(minutes: 1)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Never miss a dose.'), findsOneWidget);
    expect(find.textContaining('Vitamin D3'), findsWidgets);
  });

  testWidgets('four state-preserving shell branches open', (tester) async {
    await pumpVitalia(tester);

    await tester.tap(find.text('Meds'));
    await pumpAppFrames(tester);
    expect(find.text('Cabinet'), findsOneWidget);

    await tester.tap(find.text('History'));
    await pumpAppFrames(tester);
    expect(find.text('This week'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await pumpAppFrames(tester);
    expect(
      find.textContaining('Alarms ring while Vitalia is open'),
      findsOneWidget,
    );
  });

  testWidgets('adding a medication returns to the cabinet', (tester) async {
    await pumpVitalia(tester);
    await tester.tap(find.text('Meds'));
    await pumpAppFrames(tester);
    await tester.tap(find.byIcon(Icons.add));
    await pumpAppFrames(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Aspirin');
    await tester.enterText(find.byType(TextFormField).at(1), '81 mg');
    await tester.tap(find.text('Save'));
    await pumpAppFrames(tester);

    expect(find.text('Aspirin'), findsOneWidget);
  });

  testWidgets('a due dose opens an alarm that fits a short phone', (
    tester,
  ) async {
    await pumpVitalia(
      tester,
      at: DateTime(2026, 8, 26, 8, 5),
      size: const Size(320, 568),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Dose due'), findsOneWidget);
    expect(find.text('Take now'), findsOneWidget);
    expect(find.text('Snooze 10 min'), findsOneWidget);
  });
}
