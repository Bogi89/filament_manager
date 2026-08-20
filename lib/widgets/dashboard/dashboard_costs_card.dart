import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'dashboard_card.dart';

class DashboardCostsCard extends StatelessWidget {
  const DashboardCostsCard({
    super.key,
    required this.totalPrintCost,
    required this.avgCost,
  });

  final double totalPrintCost;
  final double avgCost;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        DashboardCard(
          title: l10n.totalPrintCosts,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: Text(
              "${totalPrintCost.toStringAsFixed(2)} €",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        DashboardCard(
          title: l10n.averageCostPerPrint,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: Text(
              "${avgCost.toStringAsFixed(2)} €",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}