import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:vitalia/core/theme/palette.dart';

class TakenRing extends StatelessWidget {
  const TakenRing({
    super.key,
    required this.taken,
    required this.total,
    this.size = 72,
  });

  final int taken;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(progress: total == 0 ? 0 : taken / total),
        child: Center(
          child: Text(
            '$taken/$total',
            style: const TextStyle(
              fontFamily: 'Fraunces',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: VitaliaPalette.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;
    final background = Paint()
      ..color = VitaliaPalette.sageMist
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final foreground = Paint()
      ..color = VitaliaPalette.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, background);
    if (progress <= 0) return;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
