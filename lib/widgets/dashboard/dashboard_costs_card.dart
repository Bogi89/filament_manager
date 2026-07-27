import 'package:flutter/material.dart';

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
    return Column(
      children: [
        DashboardCard(
          title: "Druckkosten Gesamt",
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: Text(
              "${totalPrintCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 12),

        DashboardCard(
          title: "Ø Kosten pro Druck",
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: Text(
              "${avgCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
