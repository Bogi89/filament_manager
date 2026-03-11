import 'package:flutter/material.dart';

class FilamentSpoolWidget extends StatelessWidget {
  final double percent;
  final Color filamentColor;

  const FilamentSpoolWidget({
    super.key,
    required this.percent,
    required this.filamentColor,
  });

  bool _isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (percent * 100).round();

    Color indicatorColor;
    if (percent <= 0.2) {
      indicatorColor = Colors.red;
    } else if (percent <= 0.5) {
      indicatorColor = Colors.orange;
    } else {
      indicatorColor = Colors.green;
    }

    final textColor =
        _isDark(filamentColor) ? Colors.white : Colors.black;

    return SizedBox(
      width: 70,
      height: 70,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          alignment: Alignment.center,
          children: [

            // 3D Schatten
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
            ),

            // Außenring
            CircularProgressIndicator(
              value: percent,
              strokeWidth: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor:
                  AlwaysStoppedAnimation(indicatorColor),
            ),

            // Spulenfläche
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    filamentColor.withOpacity(0.9),
                    filamentColor,
                  ],
                ),
              ),
            ),

            // Innenloch
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
            ),

            // Prozentanzeige dynamisch
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}