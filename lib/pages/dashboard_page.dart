import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/filament.dart';
import '../state/app_state.dart';
import '../widgets/common/page_header.dart';
import '../widgets/dashboard/dashboard_costs_card.dart';
import '../widgets/dashboard/dashboard_overview_card.dart';
import '../widgets/dashboard/dashboard_quick_actions.dart';
import '../widgets/dashboard/dashboard_stats_grid.dart';
import '../widgets/dashboard/dashboard_warning_card.dart';

class DashboardPage extends StatelessWidget {
  final Function(int) onNavigate;

  const DashboardPage({
    super.key,
    required this.onNavigate,
  });

  void _showCriticalDialog(
    BuildContext context,
    List<Filament> criticalFilaments,
  ) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.criticalFilaments(criticalFilaments.length),
          ),
          content: SizedBox(
            width: 420,
            child: ListView(
              shrinkWrap: true,
              children: criticalFilaments.map((f) {
                final percent =
                    ((f.remainingWeight / f.totalWeight) * 100).round();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.pop(context);
                      onNavigate(1);
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.brand,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                f.variant.isNotEmpty
                                    ? '${f.material} ${f.variant}'
                                    : f.material,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$percent%',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            24,
            0,
            24,
            20,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

    final double totalWeight = filaments.fold(
      0.0,
      (sum, f) => sum + f.remainingWeight,
    );

    final double totalValue = filaments.fold(
      0.0,
      (sum, f) => sum + (f.remainingWeight / 1000 * f.price),
    );

    final double printedWeight = jobs.fold(
      0.0,
      (sum, j) => sum + j.weightUsed,
    );

    final double totalPrintCost = jobs.fold(
      0.0,
      (sum, j) => sum + j.totalCost,
    );

    final double avgCost = jobs.isEmpty
        ? 0.0
        : totalPrintCost / jobs.length;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      child: Column(
        children: [
          PageHeader(
            title: l10n.dashboard,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                DashboardWarningCard(
                  isDark: isDark,
                  criticalFilaments: criticalFilaments,
                  onDetails: () =>
                      _showCriticalDialog(context, criticalFilaments),
                ),
                const SizedBox(height: 16),
                DashboardOverviewCard(
                  totalWeight: totalWeight,
                  totalValue: totalValue,
                ),
                const SizedBox(height: 12),
                DashboardStatsGrid(
                  filaments: filaments,
                  jobs: jobs,
                  criticalFilaments: criticalFilaments,
                  printedWeight: printedWeight,
                ),
                const SizedBox(height: 12),
                DashboardCostsCard(
                  totalPrintCost: totalPrintCost,
                  avgCost: avgCost,
                ),
                const SizedBox(height: 16),
                DashboardQuickActions(
                  onAddFilament: () => onNavigate(1),
                  onCalculate: () => onNavigate(2),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}