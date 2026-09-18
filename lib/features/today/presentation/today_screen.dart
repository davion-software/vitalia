import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitalia/features/today/presentation/today_notifier.dart';
import 'package:vitalia/features/today/presentation/widgets/banner_strip.dart';
import 'package:vitalia/features/today/presentation/widgets/dose_section.dart';
import 'package:vitalia/features/today/presentation/widgets/refill_card.dart';
import 'package:vitalia/features/today/presentation/widgets/taken_ring.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/async_page.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';
import 'package:vitalia/theme/widgets/storage_banner.dart';

final class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(todayNotifierProvider, (previous, next) {
      final failure = next.value?.actionFailure;
      if (failure == null || failure == previous?.value?.actionFailure) return;
      showStorageFailureSnackBar(context, failure);
    });
    return AsyncPage(
      value: ref.watch(todayNotifierProvider),
      errorMessage: 'Today is temporarily unavailable.',
      builder: (state) => _TodayContent(
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
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverList.list(
                children: [
                  _TodayHeader(state: state),
                  if (state.failure case final failure?) ...[
                    const SizedBox(height: 16),
                    StorageBanner(failure: failure),
                  ],
                  if (state.showBanner && state.due.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    BannerStrip(
                      text: state.due.length == 1
                          ? '1 dose is waiting'
                          : '${state.due.length} doses are waiting',
                    ),
                  ],
                  if (state.refillSoon.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const SectionLabel('Refill soon'),
                    for (final medication in state.refillSoon)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: RefillCard(
                          key: ValueKey(medication.id),
                          medication: medication,
                        ),
                      ),
                  ],
                  if (slots.isEmpty) ...[
                    const SizedBox(height: 48),
                    Text(
                      state.refillSoon.isEmpty
                          ? 'Add a medication to start the day.'
                          : 'Nothing scheduled today.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: VitaliaPalette.inkSoft),
                    ),
                  ],
                ],
              ),
              if (state.due.isNotEmpty)
                DoseSection(
                  label: 'Due now',
                  slots: state.due,
                  onTake: onTake,
                  onSkip: onSkip,
                ),
              if (state.later.isNotEmpty)
                DoseSection(
                  label: 'Later',
                  slots: state.later,
                  onTake: onTake,
                  onSkip: onSkip,
                ),
              if (state.done.isNotEmpty)
                DoseSection(
                  label: 'Already done',
                  slots: state.done,
                  onTake: onTake,
                  onSkip: onSkip,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _TodayHeader extends StatelessWidget {
  const _TodayHeader({required this.state});

  final TodayState state;

  @override
  Widget build(BuildContext context) {
    return Row(
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
        TakenRing(taken: state.takenCount, total: state.allSlots.length),
      ],
    );
  }
}
