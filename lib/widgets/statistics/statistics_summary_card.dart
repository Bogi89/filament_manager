import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class StatisticsSummaryCard extends StatelessWidget {
  const StatisticsSummaryCard({
    super.key,
    required this.jobCount,
    required this.materialCount,
    required this.totalWeight,
  });

  final int jobCount;
  final int materialCount;
  final double totalWeight;

 @override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(
  Icons.print_rounded,
  "$jobCount",
  l10n.statisticsPrints,
),

            _divider(),

            _buildItem(
  Icons.category_rounded,
  "$materialCount",
  l10n.statisticsMaterials,
),

            _divider(),

            _buildItem(
  Icons.scale_rounded,
  "${totalWeight.toStringAsFixed(0)} g",
  l10n.statisticsConsumption,
),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 34,
      color: Colors.grey.withValues(alpha: 0.30),
    );
  }

  Widget _buildItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
