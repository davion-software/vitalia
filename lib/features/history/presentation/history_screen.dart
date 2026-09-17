import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/core/day_summary.dart';
import 'package:vitalia/core/dose_event.dart';
import 'package:vitalia/core/format.dart';
import 'package:vitalia/features/history/presentation/history_notifier.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';

final class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(historyNotifierProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          const Center(child: Text('History is temporarily unavailable.')),
      data: (value) => _HistoryContent(state: value),
    );
  }
}

final class _HistoryContent extends StatelessWidget {
  const _HistoryContent({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
      children: [
        Text('This week', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 18),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: state.days
                .map((day) => Expanded(child: _DayCell(summary: day)))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Recent log'),
        if (state.events.isEmpty)
          Text(
            'Takes, skips, and snoozes will land here.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: VitaliaPalette.inkSoft),
          )
        else
          ...state.events.map(
            (event) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PaperCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _actionColor(event.action),
                        shape: BoxShape.circle,
                      ),
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
              ),
            ),
          ),
      ],
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
    Color fill;
    Color border;
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
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fill,
            shape: BoxShape.circle,
            border: Border.all(color: border, width: 1.6),
          ),
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
      ],
    );
  }
}
