import 'package:flutter/material.dart';

import '../data/store.dart';
import '../format.dart';
import '../models/models.dart';
import '../theme/palette.dart';
import 'paper.dart';
import 'pill_glyph.dart';

class DoseTile extends StatelessWidget {
  const DoseTile({super.key, required this.slot, required this.store});

  final DoseSlot slot;
  final VitaliaStore store;

  @override
  Widget build(BuildContext context) {
    final med = slot.medication;
    return PaperCard(
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
                  '${med.dosage} · ${formatClock(slot.scheduledAt)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (med.notes.isNotEmpty)
                  Text(
                    med.notes,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 4),
                Text(
                  _statusLine(),
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: _statusColor(), letterSpacing: 0.4),
                ),
              ],
            ),
          ),
          if (_canAct) ...[
            const SizedBox(width: 8),
            Column(
              children: [
                TextButton(
                  onPressed: () => store.take(slot),
                  child: const Text('Take'),
                ),
                TextButton(
                  onPressed: () => store.skip(slot),
                  child: const Text('Skip'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  bool get _canAct {
    switch (slot.status) {
      case SlotStatus.later:
      case SlotStatus.due:
      case SlotStatus.missed:
      case SlotStatus.snoozed:
        return true;
      case SlotStatus.taken:
      case SlotStatus.skipped:
        return false;
    }
  }

  String _statusLine() {
    switch (slot.status) {
      case SlotStatus.later:
        return 'Later';
      case SlotStatus.due:
        return 'Due now';
      case SlotStatus.missed:
        return 'Missed';
      case SlotStatus.taken:
        return 'Taken';
      case SlotStatus.skipped:
        return 'Skipped';
      case SlotStatus.snoozed:
        final until = slot.snoozeUntil;
        if (until == null) return 'Snoozed';
        return 'Snoozed until ${formatClock(until)}';
    }
  }

  Color _statusColor() {
    switch (slot.status) {
      case SlotStatus.due:
        return VitaliaPalette.sage;
      case SlotStatus.missed:
        return VitaliaPalette.terracotta;
      case SlotStatus.taken:
        return VitaliaPalette.sage;
      case SlotStatus.skipped:
      case SlotStatus.later:
      case SlotStatus.snoozed:
        return VitaliaPalette.inkSoft;
    }
  }
}
