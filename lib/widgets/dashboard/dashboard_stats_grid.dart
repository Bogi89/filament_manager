import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    // Gesamtanzahl aller gespeicherten Spulen.
    final spoolCount = filaments.fold<int>(
      0,
      (sum, filament) => sum + filament.spools.length,
    );

    return Column(
      children: [
        Row(
          children: [
            // Filamente
            Expanded(
              child: DashboardStatCard(
                icon: const SpoolIcon(size: 24),
                value: "${filaments.length}",
                label: l10n.filaments,
                iconBackgroundColor: const Color(0xFFE8F0FF),
                compact: true,
              ),
            ),
            const SizedBox(width: 8),
            // Spulen
            Expanded(
              child: DashboardStatCard(
                icon: const SpoolIcon(size: 24),
                value: "$spoolCount",
                label: l10n.spools,
                iconBackgroundColor: const Color(0xFFE8F0FF),
                compact: true,
              ),
            ),
            const SizedBox(width: 8),
            // Kritisch
            Expanded(
              child: DashboardStatCard(
                icon: const Icon(Icons.warning, color: Colors.red),
                value: "${criticalFilaments.length}",
                label: l10n.critical,
                iconBackgroundColor: const Color(0xFFFFE8E8),
                compact: true,
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
                label: l10n.printJobs,
                iconBackgroundColor: const Color(0xFFEAF8EC),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DashboardStatCard(
                icon: const Icon(Icons.scale),
                value: "${printedWeight.toStringAsFixed(0)} g",
                label: l10n.printed,
                iconBackgroundColor: const Color(0xFFFFF3E4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
