import 'package:flutter/material.dart';
import 'package:vitalia/theme/palette.dart';

final class BannerStrip extends StatelessWidget {
  const BannerStrip({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: VitaliaPalette.sageMist,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: VitaliaPalette.sage),
        ),
      ),
    );
  }
}
