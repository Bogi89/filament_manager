import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final spoolText = spoolCount == 1
        ? l10n.spool
        : l10n.spools;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SpoolIcon(
          size: 18,
        ),
        const SizedBox(
          width: 6,
        ),
        Text(
          '$spoolCount $spoolText',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context)
                .colorScheme
                .onSurface,
          ),
        ),
        if (showArrow)
          const Padding(
            padding: EdgeInsets.only(
              left: 4,
            ),
            child: Icon(
              Icons.chevron_right,
              size: 16,
            ),
          ),
      ],
    );
  }
}