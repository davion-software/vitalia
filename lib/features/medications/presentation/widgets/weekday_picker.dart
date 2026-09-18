import 'package:flutter/material.dart';
import 'package:vitalia/theme/palette.dart';

const weekdayLabels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

final class WeekdayPicker extends StatelessWidget {
  const WeekdayPicker({required this.days, required this.onToggle, super.key});

  final Set<int> days;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var weekday = 1; weekday <= 7; weekday++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DayChip(
                label: weekdayLabels[weekday - 1],
                selected: days.contains(weekday),
                onTap: () => onToggle(weekday),
              ),
            ),
          ),
      ],
    );
  }
}

final class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? VitaliaPalette.sage : VitaliaPalette.paperDeep,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? VitaliaPalette.paper : VitaliaPalette.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
