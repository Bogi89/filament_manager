import 'package:flutter/material.dart';

class FilamentProgressBar extends StatelessWidget {

  final double percent;
  final double height;

  const FilamentProgressBar({
    super.key,
    required this.percent,
    this.height = 14,
  });

  Color _getPercentColor(double percent) {

    if (percent <= 20) {
      return Colors.red;
    }

    if (percent <= 50) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {

    final color =
        _getPercentColor(percent);

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return ClipRRect(

      borderRadius:
          BorderRadius.circular(10),

      child: LinearProgressIndicator(

        value: percent / 100,

        minHeight: height,

        backgroundColor:

            isDark
                ? Colors.grey.shade800
                : Colors.grey.shade200,

        valueColor:

            AlwaysStoppedAnimation(
              color,
            ),

      ),

    );
  }
}