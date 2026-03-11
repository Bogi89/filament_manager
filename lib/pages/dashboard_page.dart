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

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();

    final List<Filament> filaments = appState.filaments;
    final List<PrintJob> jobs = appState.jobs;

    final warning = appState.warningPercent / 100;

    double totalWeight =
        filaments.fold(0.0, (sum, f) => sum + f.remainingWeight);

    int filamentCount = filaments.length;

    int criticalCount = filaments.where((f) {
      if (f.totalWeight == 0) return false;
      return (f.remainingWeight / f.totalWeight) <= warning;
    }).length;

    final List<Filament> criticalFilaments = filaments.where((f) {
      if (f.totalWeight == 0) return false;
      return (f.remainingWeight / f.totalWeight) <= warning;
    }).toList();

    double totalValue =
        filaments.fold(0.0, (sum, f) => sum + (f.remainingWeight / 1000 * f.price));

    int jobCount = jobs.length;

    double printedWeight =
        jobs.fold(0.0, (sum, j) => sum + j.weightUsed);

    double totalPrintCost =
        jobs.fold(0.0, (sum, j) => sum + j.totalCost);

    double avgCost =
        jobCount == 0 ? 0 : totalPrintCost / jobCount;

    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.centerLeft,
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

              if (criticalCount > 0)
                Card(
                  color: Colors.orange.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 10),
                        Text(
                          "$criticalCount Filament(e) kritisch",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              if (criticalFilaments.isNotEmpty)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "⚠ Kritische Filamente",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        ...criticalFilaments.map((f) {

                          final percent =
                              ((f.remainingWeight / f.totalWeight) * 100).round();

                          return InkWell(
                            onTap: () => onNavigate(1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                "${f.material} ${f.variant} — $percent%",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );

                        })

                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("Gesamt Filament"),
                      const SizedBox(height: 10),
                      Text(
                        "${(totalWeight / 1000).toStringAsFixed(2)} kg",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("Lagerwert"),
                      Text(
                        "${totalValue.toStringAsFixed(2)} €",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.inventory),
                            const SizedBox(height: 8),
                            Text(
                              filamentCount.toString(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Filamente"),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.warning, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              criticalCount.toString(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Kritisch"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.print),
                            const SizedBox(height: 8),
                            Text(
                              jobCount.toString(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Druckjobs"),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.scale),
                            const SizedBox(height: 8),
                            Text(
                              "${printedWeight.toStringAsFixed(0)} g",
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text("Gedruckt"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("Druckkosten Gesamt"),
                      const SizedBox(height: 10),
                      Text(
                        "${totalPrintCost.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("Ø Kosten pro Druck"),
                      const SizedBox(height: 10),
                      Text(
                        "${avgCost.toStringAsFixed(2)} €",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Schnellaktionen",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Filament hinzufügen"),
                      onPressed: () => onNavigate(1),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calculate),
                      label: const Text("Druck berechnen"),
                      onPressed: () => onNavigate(2),
                    ),
                  ),

                ],
              ),

              const SizedBox(height: 60),

            ],
          ),
        ),
      ],
    );
  }
}