import 'package:flutter/material.dart';

import '../filament_spool_icon.dart';
import '../../models/filament.dart';

class FilamentSpoolGroupWidget extends StatelessWidget {

  final int spoolCount;
  final double spoolWeight;

  const FilamentSpoolGroupWidget({
    super.key,
    required this.spoolCount,
    required this.spoolWeight,
  });

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [

        /// Spool Icons

        Row(
          children: List.generate(

            spoolCount > 3
                ? 3
                : spoolCount,

            (index) {

              return Padding(

                padding:
                    const EdgeInsets.only(
                  right: 4,
                ),

                child: SizedBox(

                  width: 18,
                  height: 18,

                  child: Opacity(

                    opacity: 0.8,

                    child: Icon(

                      Icons.circle,

                      size: 18,

                      color:
                          isDark
                              ? Colors.grey
                                  .shade400
                              : Colors.grey
                                  .shade600,

                    ),

                  ),

                ),

              );

            },

          ),
        ),

        const SizedBox(height: 2),

        /// Spool Text

        Text(

          spoolCount == 1
              ? "1 Spool"
              : "$spoolCount Spools",

          style: TextStyle(

            fontSize: 12,

            color:
                isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade700,

            fontWeight:
                FontWeight.w500,

          ),

        ),

      ],
    );
  }
}