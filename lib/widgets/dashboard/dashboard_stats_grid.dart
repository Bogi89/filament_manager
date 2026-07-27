import 'package:flutter/material.dart';

import '../../models/filament.dart';
import '../spool_icon.dart';
import 'dashboard_stat_card.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.filaments,
    required this.jobs,
    required this.criticalFilaments,
    required this.printedWeight,
  });

  final List<Filament> filaments;
  final List jobs;
  final List<Filament> criticalFilaments;
  final double printedWeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: const SpoolIcon(size: 24),
                value: "${filaments.length}",
                label: "Filamente",
                iconBackgroundColor: const Color(0xFFE8F0FF),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: DashboardStatCard(
                icon: const Icon(Icons.warning, color: Colors.red),
                value: "${criticalFilaments.length}",
                label: "Kritisch",
                iconBackgroundColor: const Color(0xFFFFE8E8),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: const Icon(Icons.print),
                value: "${jobs.length}",
                label: "Druckjobs",
                iconBackgroundColor: const Color(0xFFEAF8EC),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: DashboardStatCard(
                icon: const Icon(Icons.scale),
                value: "${printedWeight.toStringAsFixed(0)} g",
                label: "Gedruckt",
                iconBackgroundColor: const Color(0xFFFFF3E4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
