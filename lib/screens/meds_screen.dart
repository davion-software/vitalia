import 'package:flutter/material.dart';

import '../format.dart';
import '../models/models.dart';
import '../theme/palette.dart';
import '../widgets/paper.dart';
import '../widgets/pill_glyph.dart';
import '../widgets/vitalia_scope.dart';
import 'medication_editor.dart';

class MedsScreen extends StatelessWidget {
  const MedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = VitaliaScope.of(context);
    final meds = store.medications;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        Text('Cabinet', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 6),
        Text(
          'What you take, when, and on which days.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: VitaliaPalette.inkSoft),
        ),
        const SizedBox(height: 24),
        if (meds.isEmpty)
          Text(
            'The cabinet is empty. Add a medication to start today\'s slots.',
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: VitaliaPalette.inkSoft),
          )
        else
          ...meds.map(
            (med) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MedCard(medication: med),
            ),
          ),
      ],
    );
  }
}

class _MedCard extends StatelessWidget {
  const _MedCard({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final med = medication;
    return PaperCard(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => MedicationEditor(existing: med),
          ),
        );
      },
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
                  '${med.dosage} · ${formatTimes(med.timesMinutes)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  formatDays(med.daysOfWeek),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (med.tracksPills)
                  Text(
                    med.needsRefill
                        ? '${med.quantity} left · refill soon'
                        : '${med.quantity} left',
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
