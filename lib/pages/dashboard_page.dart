import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/filament.dart';
import '../models/print_job.dart';

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
                final percent =
                    ((f.remainingWeight / f.totalWeight) * 100)
                        .round();

                return ListTile(
                  title: Text(
                    "${f.material} ${f.variant}",
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
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Schließen"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState =
        context.watch<AppState>();

    final filaments =
        appState.filaments;

    final jobs =
        appState.jobs;

    final warning =
        appState.warningPercent / 100;

    final criticalFilaments =
        filaments.where((f) {
      if (f.totalWeight == 0)
        return false;

      return (f.remainingWeight /
              f.totalWeight) <=
          warning;
    }).toList();

    double totalWeight =
        filaments.fold(
            0.0,
            (sum, f) =>
                sum + f.remainingWeight);

    double totalValue =
        filaments.fold(
            0.0,
            (sum, f) =>
                sum +
                (f.remainingWeight /
                        1000 *
                    f.price));

    double printedWeight =
        jobs.fold(
            0.0,
            (sum, j) =>
                sum + j.weightUsed);

    double totalPrintCost =
        jobs.fold(
            0.0,
            (sum, j) =>
                sum + j.totalCost);

    double avgCost =
        jobs.isEmpty
            ? 0
            : totalPrintCost /
                jobs.length;

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Container(
      color: Theme.of(context)
          .colorScheme
          .surface,
      child: Column(
        children: [

          /// Titel

          Padding(
            padding:
                const EdgeInsets.all(20),
            child: Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                "Dashboard",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall,
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 20),
              children: [

                /// 🔥 Neue kompakte Warnleiste

                if (criticalFilaments
                    .isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.orange
                              .shade900
                              .withOpacity(0.18)
                          : Colors.orange
                              .shade100,
                      borderRadius:
                          BorderRadius.circular(
                              12),
                      border: Border.all(
                        color: isDark
                            ? Colors.orange
                                .shade700
                            : Colors.orange
                                .shade300,
                      ),
                    ),
                    child: Row(
                      children: [

                        Icon(
                          Icons
                              .warning_amber_rounded,
                          size: 20,
                          color: Colors.orange,
                        ),

                        const SizedBox(
                            width: 8),

                        Expanded(
                          child: Text(
                            "${criticalFilaments.length} Filament(e) kritisch",
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed: () =>
                              _showCriticalDialog(
                                  context,
                                  criticalFilaments),
                          child: const Text(
                              "Details"),
                        ),

                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                /// Gesamt Filament

                Card(
                  child: Padding(
                    padding:
                        const EdgeInsets
                            .all(20),
                    child: Column(
                      children: [

                        const Text(
                            "Gesamt Filament"),

                        const SizedBox(
                            height: 10),

                        Text(
                          "${(totalWeight / 1000).toStringAsFixed(2)} kg",
                          style:
                              const TextStyle(
                            fontSize: 32,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        const Text(
                            "Lagerwert"),

                        Text(
                          "${totalValue.toStringAsFixed(2)} €",
                        ),

                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Grid Karten

                Row(
                  children: [

                    Expanded(
                      child: _statCard(
                        icon:
                            Icons.inventory,
                        value:
                            filaments.length
                                .toString(),
                        label:
                            "Filamente",
                      ),
                    ),

                    const SizedBox(
                        width: 12),

                    Expanded(
                      child: _statCard(
                        icon:
                            Icons.warning,
                        value:
                            criticalFilaments
                                .length
                                .toString(),
                        label:
                            "Kritisch",
                        iconColor:
                            Colors.red,
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [

                    Expanded(
                      child: _statCard(
                        icon:
                            Icons.print,
                        value:
                            jobs.length
                                .toString(),
                        label:
                            "Druckjobs",
                      ),
                    ),

                    const SizedBox(
                        width: 12),

                    Expanded(
                      child: _statCard(
                        icon:
                            Icons.scale,
                        value:
                            "${printedWeight.toStringAsFixed(0)} g",
                        label:
                            "Gedruckt",
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 20),

                /// Kosten

                _bigStatCard(
                  title:
                      "Druckkosten Gesamt",
                  value:
                      "${totalPrintCost.toStringAsFixed(2)} €",
                ),

                const SizedBox(height: 12),

                _bigStatCard(
                  title:
                      "Ø Kosten pro Druck",
                  value:
                      "${avgCost.toStringAsFixed(2)} €",
                ),

                const SizedBox(height: 30),

                /// Schnellaktionen

                Text(
                  "Schnellaktionen",
                  style:
                      Theme.of(context)
                          .textTheme
                          .titleMedium,
                ),

                const SizedBox(height: 10),

                Row(
                  children: [

                    Expanded(
                      child:
                          OutlinedButton.icon(
                        icon: const Icon(
                            Icons.add),
                        label: const Text(
                            "Filament hinzufügen"),
                        onPressed: () =>
                            onNavigate(1),
                      ),
                    ),

                    const SizedBox(
                        width: 12),

                    Expanded(
                      child:
                          OutlinedButton.icon(
                        icon: const Icon(
                            Icons.calculate),
                        label: const Text(
                            "Druck berechnen"),
                        onPressed: () =>
                            onNavigate(2),
                      ),
                    ),

                  ],
                ),

                const SizedBox(height: 60),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    Color? iconColor,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            Icon(
              icon,
              color: iconColor,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(label),

          ],
        ),
      ),
    );
  }

  Widget _bigStatCard({
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [

            Text(title),

            const SizedBox(height: 10),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}