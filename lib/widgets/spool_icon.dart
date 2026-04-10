import 'package:flutter/material.dart';

class SpoolIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SpoolIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {

    /// Holt automatisch:
    /// grau (inaktiv)
    /// blau/lila (aktiv)

    final iconColor =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SpoolPainter(iconColor),
      ),
    );
  }
}

class _SpoolPainter extends CustomPainter {
  final Color color;

  _SpoolPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07;

    final center =
        Offset(size.width / 2, size.height / 2);

    final topRadius =
        size.width * 0.35;

    final bottomRadius =
        size.width * 0.38;

    final holeRadius =
        size.width * 0.12;

    final bodyHeight =
        size.height * 0.45;

    final topY =
        size.height * 0.25;

    final bottomY =
        topY + bodyHeight;

    /// Top Ring
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, topY),
        width: topRadius * 2,
        height: topRadius * 0.7,
      ),
      paint,
    );

    /// Bottom Ring
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, bottomY),
        width: bottomRadius * 2,
        height: bottomRadius * 0.7,
      ),
      paint,
    );

    /// Center Hole
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, topY),
        width: holeRadius * 2,
        height: holeRadius * 0.6,
      ),
      paint,
    );

    /// Filament Lines
    const lineCount = 6;

    for (int i = 0; i < lineCount; i++) {

      final y =
          topY +
          (i + 1) *
              (bodyHeight / (lineCount + 1));

      canvas.drawLine(
        Offset(
            center.dx - topRadius * 0.9, y),
        Offset(
            center.dx + topRadius * 0.9, y),
        paint,
      );
    }

    /// Side Lines
    canvas.drawLine(
      Offset(center.dx - topRadius, topY),
      Offset(center.dx - bottomRadius, bottomY),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx + topRadius, topY),
      Offset(center.dx + bottomRadius, bottomY),
      paint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate) {
    return false;
  }
}