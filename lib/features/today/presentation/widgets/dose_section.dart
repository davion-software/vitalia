import 'package:flutter/material.dart';
import 'package:vitalia/core/dose_slot.dart';
import 'package:vitalia/features/today/presentation/widgets/dose_tile.dart';
import 'package:vitalia/theme/widgets/paper_card.dart';

final class DoseSection extends StatelessWidget {
  const DoseSection({
    required this.label,
    required this.slots,
    required this.onTake,
    required this.onSkip,
    super.key,
  });

  final String label;
  final List<DoseSlot> slots;
  final ValueChanged<String> onTake;
  final ValueChanged<String> onSkip;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: SectionLabel(label)),
        SliverList.builder(
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(
                key: ValueKey(slot.id),
                slot: slot,
                onTake: onTake,
                onSkip: onSkip,
              ),
            );
          },
        ),
      ],
    );
  }
}
