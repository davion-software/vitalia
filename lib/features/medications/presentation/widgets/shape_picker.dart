import 'package:flutter/material.dart';
import 'package:vitalia/core/medication.dart';
import 'package:vitalia/features/medications/presentation/widgets/choice_tile.dart';
import 'package:vitalia/theme/palette.dart';
import 'package:vitalia/theme/widgets/pill_glyph.dart';

final class ShapePicker extends StatelessWidget {
  const ShapePicker({
    required this.shape,
    required this.color,
    required this.onChanged,
    super.key,
  });

  final PillShape shape;
  final PillColor color;
  final ValueChanged<PillShape> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final value in PillShape.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceTile(
                selected: shape == value,
                onTap: () => onChanged(value),
                child: Column(
                  children: [
                    PillGlyph(shape: value, color: color, size: 36),
                    const SizedBox(height: 6),
                    Text(pillShapeName(value)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
