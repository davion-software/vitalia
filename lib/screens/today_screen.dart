import 'package:flutter/material.dart';

import '../format.dart';
import '../models/models.dart';
import '../theme/palette.dart';
import '../widgets/dose_tile.dart';
import '../widgets/paper.dart';
import '../widgets/pill_glyph.dart';
import '../widgets/vitalia_scope.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VitaliaScope.of(context);
    final slots = store.todaySlots;
    final due = <DoseSlot>[];
    final later = <DoseSlot>[];
    final done = <DoseSlot>[];
    for (final slot in slots) {
      switch (slot.status) {
        case SlotStatus.due:
        case SlotStatus.missed:
          due.add(slot);
        case SlotStatus.later:
        case SlotStatus.snoozed:
          later.add(slot);
        case SlotStatus.taken:
        case SlotStatus.skipped:
          done.add(slot);
      }
    }
    final taken = done.where((slot) => slot.status == SlotStatus.taken).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingFor(store.now),
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
                    formatDate(store.now),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            TakenRing(taken: taken, total: slots.length),
          ],
        ),
        if (store.settings.banners && due.isNotEmpty) ...[
          const SizedBox(height: 20),
          _BannerStrip(
            text: due.length == 1
                ? '1 dose is waiting'
                : '${due.length} doses are waiting',
          ),
        ],
        if (store.refillSoon.isNotEmpty) ...[
          const SizedBox(height: 16),
          const SectionLabel('Refill soon'),
          ...store.refillSoon.map(
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
            store.medications.isEmpty
                ? 'Add a medication to start the day.'
                : 'Nothing scheduled today.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: VitaliaPalette.inkSoft),
          ),
        ],
        if (due.isNotEmpty) ...[
          const SizedBox(height: 12),
          const SectionLabel('Due now'),
          ...due.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(slot: slot, store: store),
            ),
          ),
        ],
        if (later.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionLabel('Later'),
          ...later.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(slot: slot, store: store),
            ),
          ),
        ],
        if (done.isNotEmpty) ...[
          const SizedBox(height: 8),
          const SectionLabel('Already done'),
          ...done.map(
            (slot) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DoseTile(slot: slot, store: store),
            ),
          ),
        ],
      ],
    );
  }
}

class _BannerStrip extends StatelessWidget {
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
