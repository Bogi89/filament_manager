import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/filament.dart';

class DashboardWarningCard extends StatelessWidget {
  const DashboardWarningCard({
    super.key,
    required this.isDark,
    required this.criticalFilaments,
    required this.onDetails,
  });

  final bool isDark;
  final List<Filament> criticalFilaments;
  final VoidCallback onDetails;

  @override
  Widget build(BuildContext context) {
    if (criticalFilaments.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.orange.shade900.withValues(alpha: 0.12)
            : const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.orange.shade700.withValues(alpha: 0.35)
              : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 22,
            color: Colors.orange.shade600,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              l10n.criticalFilaments(criticalFilaments.length),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onDetails,
            child: Text(l10n.details),
          ),
        ],
      ),
    );
  }
}