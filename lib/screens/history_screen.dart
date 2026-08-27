import 'package:flutter/material.dart';

import '../format.dart';
import '../models/models.dart';
import '../theme/palette.dart';
import '../widgets/paper.dart';
import '../widgets/vitalia_scope.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VitaliaScope.of(context);
    final adherence = store.weekAdherence;
    final rate = adherence.rate;
    final percent = rate == null ? '—' : '${(rate * 100).round()}%';
    final streak = store.streak;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Text('This week', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 18),
        PaperCard(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(percent, style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 6),
              Text(
                rate == null
                    ? 'No resolved doses this week yet.'
                    : '${adherence.taken} of ${adherence.resolved} doses taken',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: VitaliaPalette.inkSoft),
              ),
              const SizedBox(height: 16),
              Text(
                streak == 0
                    ? 'No streak yet'
                    : streak == 1
                    ? '1 clean day'
                    : '$streak clean days',
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
            children: store.lastSeven
                .map((day) => Expanded(child: _DayCell(summary: day)))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Recent log'),
        if (store.recentEvents.isEmpty)
          Text(
            'Takes, skips, and snoozes will land here.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: VitaliaPalette.inkSoft),
          )
        else
          ...store.recentEvents.map(
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
                            event.medicationName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${actionLabel(event.action)} · ${formatRelativeEvent(event.at, store.now)}',
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

class _DayCell extends StatelessWidget {
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
