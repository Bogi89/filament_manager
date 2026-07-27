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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${(totalWeight / 1000).toStringAsFixed(2)} kg",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 18),

                  const SizedBox(width: 8),

                  Text(
                    "Lagerwert",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "${totalValue.toStringAsFixed(2)} €",
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
