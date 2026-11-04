import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Displays one circle with equal sectors for every filament color.
class FilamentColorCircle extends StatelessWidget {
  const FilamentColorCircle({
    super.key,
    required this.colors,
    this.size = 38,
    this.fallbackColor = Colors.grey,
  });

  final List<Color> colors;
  final double size;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final visibleColors = colors.isEmpty ? <Color>[fallbackColor] : colors;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _FilamentColorPainter(visibleColors)),
    );
  }
}

class _FilamentColorPainter extends CustomPainter {
  const _FilamentColorPainter(this.colors);

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 0.8;
    final circle = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()..style = PaintingStyle.fill;

    if (colors.length == 1) {
      paint.color = colors.first;
      canvas.drawCircle(center, radius, paint);
    } else {
      final sweep = 2 * math.pi / colors.length;
      for (var index = 0; index < colors.length; index++) {
        paint.color = colors[index];
        canvas.drawArc(
          circle,
          -math.pi / 2 + index * sweep,
          sweep,
          true,
          paint,
        );
      }
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0x66000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  @override
  bool shouldRepaint(covariant _FilamentColorPainter oldDelegate) {
    if (colors.length != oldDelegate.colors.length) return true;
    for (var i = 0; i < colors.length; i++) {
      if (colors[i] != oldDelegate.colors[i]) return true;
    }
    return false;
  }
}
