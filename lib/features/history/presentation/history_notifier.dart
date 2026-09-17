import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:vitalia/core/day_summary.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/core/result.dart';
import 'package:vitalia/core/schedule.dart';
import 'package:vitalia/core/snapshot.dart';
import 'package:vitalia/core/storage_failure.dart';
import 'package:vitalia/data/providers.dart';
import 'package:vitalia/services/app_providers.dart';

@immutable
final class HistoryEventState {
  const HistoryEventState({
    required this.name,
    required this.detail,
    required this.action,
  });

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

  factory HistoryState.fromSnapshot(Snapshot snapshot, DateTime now) {
    final adherence = adherenceForRange(
      medications: snapshot.medications,
      events: snapshot.events,
      from: mondayOf(now),
      to: dateOnly(now),
      now: now,
    );
    final rate = adherence.rate;
    final streak = cleanStreak(
      medications: snapshot.medications,
      events: snapshot.events,
      now: now,
    );
    final recent = [...snapshot.events]
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
      days: lastSevenDays(
        medications: snapshot.medications,
        events: snapshot.events,
        now: now,
      ),
      events: [
        for (final event in recent.take(30))
          HistoryEventState(
            name: event.medicationName,
            detail:
                '${actionLabel(event.action)} · ${formatRelativeEvent(event.at, now)}',
            action: event.action,
          ),
      ],
    );
  }

  final String percentLabel;
  final String summaryLabel;
  final String streakLabel;
  final List<DaySummary> days;
  final List<HistoryEventState> events;
  final StorageFailure? failure;
}

final class HistoryNotifier extends StreamNotifier<HistoryState> {
  @override
  Stream<HistoryState> build() {
    final now =
        ref.watch(currentTimeProvider).value ?? ref.watch(clockProvider).now();
    return ref.watch(vitaliaRepositoryProvider).watchSnapshot().map((result) {
      return switch (result) {
        Ok(:final value) => HistoryState.fromSnapshot(value, now),
        Err(:final failure) => HistoryState(
          percentLabel: '—',
          summaryLabel: 'History is unavailable.',
          streakLabel: 'No streak yet',
          days: const [],
          events: const [],
          failure: failure,
        ),
      };
    });
  }
}

final historyNotifierProvider =
    StreamNotifierProvider<HistoryNotifier, HistoryState>(HistoryNotifier.new);
