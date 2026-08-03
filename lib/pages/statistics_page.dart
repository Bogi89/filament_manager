import 'package:flutter/material.dart';
import '../models/print_job.dart';
import '../models/filament.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/app_card.dart';
import 'package:filament_manager_v2/widgets/statistics/statistics_summary_card.dart';
import '../widgets/statistics/statistics_selector.dart';

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

  String _selectedSection = 'Verbrauch pro Material';

  final List<String> _sections = [
    'Verbrauch pro Material',
    'Verbrauch pro Monat',
    'Kosten pro Material',
    'Kosten pro Monat',
  ];

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

      monthlyUsage[month] = (monthlyUsage[month] ?? 0) + job.weightUsed;

      monthlyCost[month] = (monthlyCost[month] ?? 0) + job.totalCost;
    }
  }

  String _formatNumber(num value) {
    final parts = value.toStringAsFixed(0).split('.');
    final number = parts[0];

    final buffer = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(number[i]);
    }

    return buffer.toString();
  }

  String _formatWeight(double value) => "${_formatNumber(value)} g";

  String _formatHours(double value) => "${_formatNumber(value)} h";

  String _formatCurrency(double value) =>
      "${value.toStringAsFixed(2).replaceAll('.', ',')} €";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: Column(
        children: [
          const PageHeader(title: "Statistik"),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                StatisticsSummaryCard(
                  jobCount: widget.jobs.length,
                  materialCount: materialUsage.length,
                  totalWeight: totalWeight,
                ),

                const SizedBox(height: 12),

                _buildOverview(),

                const SizedBox(height: 12),

                _buildAverage(),

                const SizedBox(height: 12),

                _buildTopMaterial(),

                const SizedBox(height: 12),

                StatisticsSelector(
                  value: _selectedSection,
                  items: _sections,
                  onChanged: (value) {
                    setState(() {
                      _selectedSection = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                _buildSelectedSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Gesamtübersicht",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  Icons.scale_rounded,
                  _formatWeight(totalWeight),
                  "Gewicht",
                ),
              ),

              Expanded(
                child: _buildOverviewItem(
                  Icons.schedule_rounded,
                  _formatHours(totalHours),
                  "Druckzeit",
                ),
              ),

              Expanded(
                child: _buildOverviewItem(
                  Icons.euro_rounded,
                  _formatCurrency(totalCost),
                  "Kosten",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(IconData icon, String value, String label) {
    Color iconColor;

    switch (icon) {
      case Icons.scale_rounded:
        iconColor = Colors.blue;
        break;

      case Icons.schedule_rounded:
        iconColor = Colors.orange;
        break;

      case Icons.euro_rounded:
        iconColor = Colors.green;
        break;

      default:
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: iconColor),

        const SizedBox(height: 6),

        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAverage() {
    if (widget.jobs.isEmpty) {
      return const SizedBox();
    }

    final avgWeight = totalWeight / widget.jobs.length;
    final avgHours = totalHours / widget.jobs.length;
    final avgCost = totalCost / widget.jobs.length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Durchschnitt pro Druck",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  Icons.scale_rounded,
                  _formatWeight(avgWeight),
                  "Gewicht",
                ),
              ),

              Expanded(
                child: _buildOverviewItem(
                  Icons.schedule_rounded,
                  _formatHours(avgHours),
                  "Druckzeit",
                ),
              ),

              Expanded(
                child: _buildOverviewItem(
                  Icons.euro_rounded,
                  _formatCurrency(avgCost),
                  "Kosten",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMaterial() {
    if (materialUsage.isEmpty) {
      return const SizedBox();
    }

    final top = materialUsage.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );

    final percentage = totalWeight > 0 ? (top.value / totalWeight) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF6D3FD3), Color(0xFFD73AF5)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                "Top Material",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            top.key,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            "${_formatWeight(top.value)} • ${percentage.toStringAsFixed(1)} %",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
    return _buildProgressSection("Verbrauch pro Monat (g)", monthlyUsage, "g");
  }

  Widget _buildMaterialCost() {
    return _buildProgressSection("Kosten pro Material (€)", materialCost, "€");
  }

  Widget _buildMonthlyCost() {
    return _buildProgressSection("Kosten pro Monat (€)", monthlyCost, "€");
  }

  Widget _buildProgressSection(
    String title,
    Map<String, double> data,
    String unit,
  ) {
    if (data.isEmpty) {
      return const Text("Noch keine Druckdaten");
    }

    final maxValue = data.values.reduce((a, b) => a > b ? a : b);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ...data.entries.map((entry) {
            final percent = entry.value / maxValue;

            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Text(
                        unit == "€"
                            ? _formatCurrency(entry.value)
                            : unit == "h"
                            ? _formatHours(entry.value)
                            : _formatWeight(entry.value),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF9C27B0),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSelectedSection() {
    switch (_selectedSection) {
      case 'Verbrauch pro Material':
        return _buildMaterialUsage();

      case 'Verbrauch pro Monat':
        return _buildMonthlyUsage();

      case 'Kosten pro Material':
        return _buildMaterialCost();

      case 'Kosten pro Monat':
        return _buildMonthlyCost();

      default:
        return _buildMaterialUsage();
    }
  }
}
