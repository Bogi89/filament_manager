import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/filament.dart';
import '../widgets/dashboard/dashboard_overview_card.dart';
import '../widgets/dashboard/dashboard_costs_card.dart';
import '../widgets/dashboard/dashboard_stats_grid.dart';
import '../widgets/dashboard/dashboard_warning_card.dart';
import '../widgets/dashboard/dashboard_quick_actions.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardPage({super.key, required this.onNavigate});

  void _showCriticalDialog(
    BuildContext context,
    List<Filament> criticalFilaments,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kritische Filamente"),
          content: SizedBox(
            width: 400,
            height: 300,
            child: ListView(
              children: criticalFilaments.map((f) {
                final percent = ((f.remainingWeight / f.totalWeight) * 100)
                    .round();

                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Hersteller
                      Text(
                        f.brand,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      /// Material + Variante
                      Text(
                        f.variant.isNotEmpty
                            ? "${f.material} ${f.variant}"
                            : f.material,
                      ),
                    ],
                  ),
                  trailing: Text(
                    "$percent%",
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onNavigate(1);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Schließen"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final filaments = appState.filaments;

    final jobs = appState.jobs;

    final warning = appState.warningPercent / 100;

    final criticalFilaments = filaments.where((f) {
      if (f.totalWeight == 0) {
        return false;
      }

      return (f.remainingWeight / f.totalWeight) <= warning;
    }).toList();

    double totalWeight = filaments.fold(
      0.0,
      (sum, f) => sum + f.remainingWeight,
    );

    double totalValue = filaments.fold(
      0.0,
      (sum, f) => sum + (f.remainingWeight / 1000 * f.price),
    );

    double printedWeight = jobs.fold(0.0, (sum, j) => sum + j.weightUsed);

    double totalPrintCost = jobs.fold(0.0, (sum, j) => sum + j.totalCost);

    double avgCost = jobs.isEmpty ? 0 : totalPrintCost / jobs.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          /// Titel
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Dashboard",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                /// 🔥 Neue kompakte Warnleiste
                DashboardWarningCard(
                  isDark: isDark,
                  criticalFilaments: criticalFilaments,
                  onDetails: () =>
                      _showCriticalDialog(context, criticalFilaments),
                ),

                const SizedBox(height: 20),

                DashboardOverviewCard(
                  totalWeight: totalWeight,
                  totalValue: totalValue,
                ),

                const SizedBox(height: 20),

                /// Grid Karten
                DashboardStatsGrid(
                  filaments: filaments,
                  jobs: jobs,
                  criticalFilaments: criticalFilaments,
                  printedWeight: printedWeight,
                ),

                const SizedBox(height: 20),

                /// Kosten
                DashboardCostsCard(
                  totalPrintCost: totalPrintCost,
                  avgCost: avgCost,
                ),

                const SizedBox(height: 30),

                /// Schnellaktionen
                DashboardQuickActions(
                  onAddFilament: () => onNavigate(1),
                  onCalculate: () => onNavigate(2),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
