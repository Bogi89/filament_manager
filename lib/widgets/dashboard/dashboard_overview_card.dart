import 'package:flutter/material.dart';

import 'dashboard_card.dart';

class DashboardOverviewCard extends StatelessWidget {
  const DashboardOverviewCard({
    super.key,
    required this.totalWeight,
    required this.totalValue,
  });

  final double totalWeight;
  final double totalValue;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      title: "Gesamtbestand",
      child: Center(
        child: Column(
          children: [
            Text(
              "${(totalWeight / 1000).toStringAsFixed(2)} kg",
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 18),

                const SizedBox(width: 8),

                Text(
                  "Lagerwert: ${totalValue.toStringAsFixed(2)} €",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
