import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/day_summary.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';
import 'package:vitalia/services/async_combine.dart';

@immutable
final class HistoryEventState {
  const HistoryEventState({
    required this.id,
    required this.name,
    required this.detail,
    required this.action,
  });

  final String id;
  final String name;
  final String detail;
  final DoseAction action;
}

@immutable
final class HistoryState {
  const HistoryState({
    required this.percentLabel,
    required this.summaryLabel,
    required this.streakLabel,
    required this.days,
    required this.events,
    this.failure,
  });

  factory HistoryState.fromCabinet({
    required List<Medication> medications,
    required List<DoseEvent> events,
    required DateTime now,
  }) {
    final adherence = adherenceForRange(
      medications: medications,
      events: events,
      from: mondayOf(now),
      to: dateOnly(now),
      now: now,
    );
    final rate = adherence.rate;
    final streak = cleanStreak(
      medications: medications,
      events: events,
      now: now,
    );
    final recent = [...events]
      ..sort((first, second) => second.at.compareTo(first.at));
    return HistoryState(
      percentLabel: rate == null ? '—' : '${(rate * 100).round()}%',
      summaryLabel: rate == null
          ? 'No resolved doses this week yet.'
          : '${adherence.taken} of ${adherence.resolved} doses taken',
      streakLabel: switch (streak) {
        0 => 'No streak yet',
        1 => '1 clean day',
        _ => '$streak clean days',
      },
      days: lastSevenDays(medications: medications, events: events, now: now),
      events: [
        for (final event in recent.take(30))
          HistoryEventState(
            id: event.id,
            name: event.medicationName,
            detail:
                '${actionLabel(event.action)} · ${formatRelativeEvent(event.at, now)}',
            action: event.action,
          ),
      ],
    );
  }

  factory HistoryState.unavailable(StorageFailure failure) {
    return HistoryState(
      percentLabel: '—',
      summaryLabel: 'History is unavailable.',
      streakLabel: 'No streak yet',
      days: const [],
      events: const [],
      failure: failure,
    );
  }

  final String percentLabel;
  final String summaryLabel;
  final String streakLabel;
  final List<DaySummary> days;
  final List<HistoryEventState> events;
  final StorageFailure? failure;
}

final class HistoryNotifier extends Notifier<AsyncValue<HistoryState>> {
  @override
  AsyncValue<HistoryState> build() {
    final now =
        ref.watch(currentMinuteProvider).value ??
        ref.watch(clockProvider).now();
    return combineAsync2(
      ref.watch(medicationsProvider),
      ref.watch(doseEventsProvider),
    ).whenData((results) {
      return foldResults2(
        first: results.$1,
        second: results.$2,
        onErr: HistoryState.unavailable,
        onOk: (medications, events) => HistoryState.fromCabinet(
          medications: medications,
          events: events,
          now: now,
        ),
      );
    });
  }
}

final historyNotifierProvider =
    NotifierProvider<HistoryNotifier, AsyncValue<HistoryState>>(
      HistoryNotifier.new,
    );
