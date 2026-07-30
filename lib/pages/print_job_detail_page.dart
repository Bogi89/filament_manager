import 'package:flutter/material.dart';
import '../models/print_job.dart';
import '../widgets/common/page_header.dart';

class PrintJobDetailPage extends StatelessWidget {
  final PrintJob job;

  const PrintJobDetailPage({super.key, required this.job});

  Widget _sectionTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context, Widget child) {
    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${job.date.day.toString().padLeft(2, '0')}."
        "${job.date.month.toString().padLeft(2, '0')}."
        "${job.date.year}";

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: Column(
        children: [
          PageHeader(
            title: job.projectName.isEmpty ? "Druckdetails" : job.projectName,
            showBackButton: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
              children: [
                Center(
                  child: CircleAvatar(radius: 44, backgroundColor: job.color),
                ),

                const SizedBox(height: 40),

                _sectionTitle(context, Icons.inventory_2_outlined, "Filament"),

                const SizedBox(height: 10),

                _sectionCard(
                  context,
                  Column(
                    children: [
                      _infoRow(context, "Hersteller", job.filamentBrand),
                      _infoRow(context, "Material", job.material),
                      _infoRow(context, "Variante", job.variant),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle(context, Icons.print_outlined, "Druckdaten"),

                const SizedBox(height: 10),

                _sectionCard(
                  context,
                  Column(
                    children: [
                      _infoRow(
                        context,
                        "Gewicht",
                        "${job.weightUsed.toStringAsFixed(0)} g",
                      ),
                      _infoRow(
                        context,
                        "Druckzeit",
                        "${job.printHours.toStringAsFixed(1)} h",
                      ),
                      _infoRow(
                        context,
                        "Kosten",
                        "${job.totalCost.toStringAsFixed(2)} €",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle(context, Icons.calendar_today_outlined, "Datum"),

                const SizedBox(height: 10),

                _sectionCard(
                  context,
                  _infoRow(context, "Gedruckt am", formattedDate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
