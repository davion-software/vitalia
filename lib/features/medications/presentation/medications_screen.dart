import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vitalia/features/medications/presentation/medications_notifier.dart';
import 'package:vitalia/routing/routes.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/async_page.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';
import 'package:vitalia/theme/widgets/pill_glyph.dart';
import 'package:vitalia/theme/widgets/storage_banner.dart';

final class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncPage(
      value: ref.watch(medicationsNotifierProvider),
      errorMessage: 'The cabinet is temporarily unavailable.',
      builder: (value) => _MedicationList(state: value),
    );
  }
}

final class _MedicationList extends StatelessWidget {
  const _MedicationList({required this.state});

  final MedicationsState state;

  @override
  Widget build(BuildContext context) {
    final items = state.items;
    final failure = state.failure;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 96),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverList.list(
                children: [
                  Text(
                    'Cabinet',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'What you take, when, and on which days.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: VitaliaPalette.inkSoft),
                  ),
                  const SizedBox(height: 24),
                  if (failure != null) StorageBanner(failure: failure),
                  if (items.isEmpty && failure == null)
                    Text(
                      "The cabinet is empty. Add a medication to start today's slots.",
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: VitaliaPalette.inkSoft),
                    ),
                ],
              ),
              SliverList.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MedCard(
                      key: ValueKey(item.medication.id),
                      item: item,
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

final class _MedCard extends StatelessWidget {
  const _MedCard({required this.item, super.key});

  final MedicationItemState item;

  @override
  Widget build(BuildContext context) {
    final med = item.medication;
    final quantityLabel = item.quantityLabel;
    return PaperCard(
      onTap: () => context.push(Routes.editMedication(med.id)),
      child: Row(
        children: [
          PillGlyph(shape: med.shape, color: med.color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  item.scheduleLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  item.daysLabel,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (quantityLabel != null)
                  Text(
                    quantityLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: med.needsRefill
                          ? VitaliaPalette.terracotta
                          : VitaliaPalette.sage,
                      letterSpacing: 0.3,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: VitaliaPalette.inkSoft),
        ],
      ),
    );
  }
}
