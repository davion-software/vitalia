import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/day_summary.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/features/history/presentation/history_notifier.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/async_page.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';
import 'package:vitalia/theme/widgets/storage_banner.dart';

final class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncPage(
      value: ref.watch(historyNotifierProvider),
      errorMessage: 'History is temporarily unavailable.',
      builder: (value) => _HistoryContent(state: value),
    );
  }
}

final class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverList.list(
                children: [
                  Text(
                    'This week',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 18),
                  if (state.failure case final failure?) ...[
                    StorageBanner(failure: failure),
                    const SizedBox(height: 16),
                  ],
                  PaperCard(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.percentLabel,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.summaryLabel,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: VitaliaPalette.inkSoft),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.streakLabel,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: VitaliaPalette.sage),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Last 7 days'),
                  PaperCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        for (final day in state.days)
                          Expanded(child: _DayCell(summary: day)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('Recent log'),
                  if (state.events.isEmpty)
                    Text(
                      'Takes, skips, and snoozes will land here.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: VitaliaPalette.inkSoft),
                    ),
                ],
              ),
              SliverList.builder(
                itemCount: state.events.length,
                itemBuilder: (context, index) {
                  final event = state.events[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistoryEventCard(
                      key: ValueKey(event.id),
                      event: event,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _HistoryEventCard extends StatelessWidget {
  const _HistoryEventCard({required this.event, super.key});

  final HistoryEventState event;

  @override
  Widget build(BuildContext context) {
    return PaperCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: _actionColor(event.action),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(width: 10, height: 10),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  event.detail,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _actionColor(DoseAction action) {
    switch (action) {
      case DoseAction.taken:
        return VitaliaPalette.sage;
      case DoseAction.skipped:
        return VitaliaPalette.terracotta;
      case DoseAction.snoozed:
        return VitaliaPalette.inkSoft;
    }
  }
}

final class _DayCell extends StatelessWidget {
  const _DayCell({required this.summary});

  final DaySummary summary;

  @override
  Widget build(BuildContext context) {
    final mark = summary.mark;
    final Color fill;
    final Color border;
    switch (mark) {
      case DayMark.complete:
        fill = VitaliaPalette.sage;
        border = VitaliaPalette.sage;
      case DayMark.mixed:
        fill = VitaliaPalette.terracotta;
        border = VitaliaPalette.terracotta;
      case DayMark.pending:
        fill = Colors.transparent;
        border = VitaliaPalette.sage;
      case DayMark.empty:
        fill = Colors.transparent;
        border = VitaliaPalette.line;
    }
    return Column(
      children: [
        Text(
          weekdayLetter(summary.day.weekday),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.6),
          ),
          child: SizedBox(
            width: 28,
            height: 28,
            child: Center(
              child: Text(
                '${summary.day.day}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: mark == DayMark.complete || mark == DayMark.mixed
                      ? VitaliaPalette.paper
                      : VitaliaPalette.ink,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
