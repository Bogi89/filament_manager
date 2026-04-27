import 'package:flutter/material.dart';

import 'spool_icon.dart';

class SpoolCountWidget extends StatelessWidget {

  final int spoolCount;

  final bool showArrow;

  const SpoolCountWidget({
    super.key,
    required this.spoolCount,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {

    return Row(

      mainAxisSize:
          MainAxisSize.min,

      children: [

        /// 🧵 Spulen-Icon

        const SpoolIcon(
          size: 18,
        ),

        const SizedBox(
          width: 6,
        ),

        /// Anzahl Text

        Text(

          "$spoolCount Spools",

          style:
              TextStyle(

            fontSize: 13,

            fontWeight:
                FontWeight.w600,

            color:
                Theme.of(context)
                    .colorScheme
                    .onSurface,

          ),

        ),

        /// Pfeil optional

        if (showArrow)
          const Padding(
            padding:
                EdgeInsets.only(
                    left: 4),
            child: Icon(
              Icons.chevron_right,
              size: 16,
            ),
          ),

      ],

    );

  }

}