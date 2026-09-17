import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/features/today/presentation/today_notifier.dart';
import 'package:vitalia/features/today/presentation/widgets/dose_tile.dart';
import 'package:vitalia/features/today/presentation/widgets/taken_ring.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';
import 'package:vitalia/theme/widgets/pill_glyph.dart';

final class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(todayNotifierProvider);
    return asyncState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          const Center(child: Text('Today is temporarily unavailable.')),
      data: (state) => _TodayContent(
        state: state,
        onTake: ref.read(todayNotifierProvider.notifier).take,
        onSkip: ref.read(todayNotifierProvider.notifier).skip,
      ),
    );
  }
}

final class _TodayContent extends StatelessWidget {
  const _TodayContent({
    required this.state,
    required this.onTake,
    required this.onSkip,
  });

  final TodayState state;
  final ValueChanged<String> onTake;
  final ValueChanged<String> onSkip;

  @override
  Widget build(BuildContext context) {
    final slots = state.allSlots;
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.nowLabel,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Never miss a dose.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: VitaliaPalette.inkSoft),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.dateLabel,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TakenRing(taken: state.takenCount, total: slots.length),
          ],
        ),
        if (state.showBanner && state.due.isNotEmpty) ...[
          const SizedBox(height: 20),
          _BannerStrip(
            text: state.due.length == 1
                ? '1 dose is waiting'
                : '${state.due.length} doses are waiting',
          ),
        ],
        if (state.refillSoon.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionLabel('Refill soon'),
          ...state.refillSoon.map(
            (med) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PaperCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    PillGlyph(shape: med.shape, color: med.color, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${med.name} · ${med.quantity} left',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (slots.isEmpty) ...[
          const SizedBox(height: 48),
          Text(
            state.refillSoon.isEmpty && slots.isEmpty
                ? 'Add a medication to start the day.'
                : 'Nothing scheduled today.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: VitaliaPalette.inkSoft),
          ),
        ],
        if (state.due.isNotEmpty) ...[
          const SizedBox(height: 12),
          const SectionLabel('Due now'),
          ...state.due.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(slot: slot, onTake: onTake, onSkip: onSkip),
            ),
          ),
        ],
        if (state.later.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionLabel('Later'),
          ...state.later.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(slot: slot, onTake: onTake, onSkip: onSkip),
            ),
          ),
        ],
        if (state.done.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionLabel('Already done'),
          ...state.done.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(slot: slot, onTake: onTake, onSkip: onSkip),
            ),
          ),
        ],
      ],
    );
  }
}

final class _BannerStrip extends StatelessWidget {
  const _BannerStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: VitaliaPalette.sageMist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: VitaliaPalette.sage),
      ),
    );
  }
}
