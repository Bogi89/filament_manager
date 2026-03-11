import 'package:flutter/material.dart';
import '../models/print_job.dart';
import '../models/filament.dart';

class StatisticsPage extends StatefulWidget {
  final List<PrintJob> jobs;
  final List<Filament> filaments;

  const StatisticsPage({
    super.key,
    required this.jobs,
    required this.filaments,
  });

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {

  double totalWeight = 0;
  double totalCost = 0;
  double totalHours = 0;

  Map<String, double> materialUsage = {};
  Map<String, double> materialCost = {};
  Map<String, double> monthlyUsage = {};
  Map<String, double> monthlyCost = {};

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  void _calculateStats() {

    for (var job in widget.jobs) {

      totalWeight += job.weightUsed;
      totalCost += job.totalCost;
      totalHours += job.printHours;

      materialUsage[job.material] =
          (materialUsage[job.material] ?? 0) + job.weightUsed;

      materialCost[job.material] =
          (materialCost[job.material] ?? 0) + job.totalCost;

      final month =
          "${job.date.year}-${job.date.month.toString().padLeft(2, '0')}";

      monthlyUsage[month] =
          (monthlyUsage[month] ?? 0) + job.weightUsed;

      monthlyCost[month] =
          (monthlyCost[month] ?? 0) + job.totalCost;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          _buildOverview(),

          const SizedBox(height: 20),

          _buildAverage(),

          const SizedBox(height: 20),

          _buildTopMaterial(),

          const SizedBox(height: 20),

          _buildMaterialUsage(),

          const SizedBox(height: 20),

          _buildMonthlyUsage(),

          const SizedBox(height: 20),

          _buildMaterialCost(),

          const SizedBox(height: 20),

          _buildMonthlyCost(),
        ],
      ),
    );
  }

  Widget _buildOverview() {

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Gesamtübersicht",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _row("Verbrauchtes Gewicht", "${totalWeight.toStringAsFixed(0)} g"),
            _row("Druckzeit", "${totalHours.toStringAsFixed(1)} h"),
            _row("Gesamtkosten", "${totalCost.toStringAsFixed(2)} €"),
          ],
        ),
      ),
    );
  }

  Widget _buildAverage() {

    if (widget.jobs.isEmpty) {
      return const SizedBox();
    }

    final avgWeight = totalWeight / widget.jobs.length;
    final avgHours = totalHours / widget.jobs.length;
    final avgCost = totalCost / widget.jobs.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Durchschnitt pro Druck",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _row("Gewicht", "${avgWeight.toStringAsFixed(0)} g"),
            _row("Druckzeit", "${avgHours.toStringAsFixed(1)} h"),
            _row("Kosten", "${avgCost.toStringAsFixed(2)} €"),
          ],
        ),
      ),
    );
  }

  Widget _buildTopMaterial() {

    if (materialUsage.isEmpty) {
      return const SizedBox();
    }

    final top = materialUsage.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Row(
            children: const [
              Icon(Icons.emoji_events, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Top Material",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),

          Text(
            top.key,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialUsage() {

    return _buildProgressSection(
      "Verbrauch pro Material (g)",
      materialUsage,
      "g",
    );
  }

  Widget _buildMonthlyUsage() {

    return _buildProgressSection(
      "Verbrauch pro Monat (g)",
      monthlyUsage,
      "g",
    );
  }

  Widget _buildMaterialCost() {

    return _buildProgressSection(
      "Kosten pro Material (€)",
      materialCost,
      "€",
    );
  }

  Widget _buildMonthlyCost() {

    return _buildProgressSection(
      "Kosten pro Monat (€)",
      monthlyCost,
      "€",
    );
  }

  Widget _buildProgressSection(
      String title,
      Map<String, double> data,
      String unit,
      ) {

    if (data.isEmpty) {
      return const Text("Noch keine Druckdaten");
    }

    final maxValue =
        data.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...data.entries.map((entry) {

              final percent = entry.value / maxValue;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [

                      Text(entry.key),

                      Text(
                        "${entry.value.toStringAsFixed(2)} $unit",
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                  ),

                  const SizedBox(height: 10),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(label),

          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}