import 'package:flutter/material.dart';

import 'package:vitalia/core/medication.dart';
import 'package:vitalia/theme/palette.dart';

class PillGlyph extends StatelessWidget {
  const PillGlyph({
    super.key,
    required this.shape,
    required this.color,
    this.size = 44,
  });

  final PillShape shape;
  final PillColor color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${pillShapeName(shape)} ${pillColorName(color)}',
      child: CustomPaint(
        size: Size(size, size),
        painter: _PillPainter(shape: shape, color: colorFor(color)),
      ),
    );
  }
}

class _PillPainter extends CustomPainter {
  const _PillPainter({required this.shape, required this.color});

  final PillShape shape;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case PillShape.capsule:
        _paintCapsule(canvas, size);
      case PillShape.tablet:
        _paintTablet(canvas, size);
      case PillShape.softgel:
        _paintSoftgel(canvas, size);
    }
  }

  void _paintCapsule(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.92,
      height: size.height * 0.46,
    );
    final radius = Radius.circular(rect.height / 2);
    final left = Rect.fromLTWH(
      rect.left,
      rect.top,
      rect.width / 2,
      rect.height,
    );
    final right = Rect.fromLTWH(
      rect.center.dx,
      rect.top,
      rect.width / 2,
      rect.height,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(left, topLeft: radius, bottomLeft: radius),
      Paint()..color = color,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(right, topRight: radius, bottomRight: radius),
      Paint()..color = Color.lerp(color, Colors.white, 0.28)!,
    );
    canvas.drawLine(
      Offset(rect.center.dx, rect.top + 3),
      Offset(rect.center.dx, rect.bottom - 3),
      Paint()
        ..color = Color.lerp(color, Colors.black, 0.18)!
        ..strokeWidth = 1.2,
    );
  }

  void _paintTablet(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.72,
      height: size.height * 0.72,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.width * 0.28),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
    canvas.drawLine(
      Offset(rect.center.dx, rect.top + 6),
      Offset(rect.center.dx, rect.bottom - 6),
      Paint()
        ..color = Color.lerp(color, Colors.white, 0.45)!
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintSoftgel(Canvas canvas, Size size) {
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.86,
      height: size.height * 0.58,
    );
    canvas.drawOval(rect, Paint()..color = color);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(rect.center.dx - rect.width * 0.12, rect.center.dy - 4),
        width: rect.width * 0.38,
        height: rect.height * 0.28,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(covariant _PillPainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.color != color;
  }
}
