import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/print_job.dart';
import '../widgets/common/page_header.dart';

class PrintJobDetailPage extends StatelessWidget {
  final PrintJob job;

  const PrintJobDetailPage({
    super.key,
    required this.job,
  });

  String _localizedText(
    BuildContext context, {
    required String german,
    required String english,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return languageCode == 'de' ? german : english;
  }

  Widget _sectionTitle(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context,
    String label,
    String value,
  ) {
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
                color: isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context,
    Widget child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final formattedDate =
        '${job.date.day.toString().padLeft(2, '0')}.'
        '${job.date.month.toString().padLeft(2, '0')}.'
        '${job.date.year}';

    final pageTitle = job.projectName.isEmpty
        ? _localizedText(
            context,
            german: 'Druckdetails',
            english: 'Print Details',
          )
        : job.projectName;

    final variantLabel = _localizedText(
      context,
      german: 'Variante',
      english: 'Variant',
    );

    final printDataLabel = _localizedText(
      context,
      german: 'Druckdaten',
      english: 'Print Data',
    );

    final weightLabel = _localizedText(
      context,
      german: 'Gewicht',
      english: 'Weight',
    );

    final printTimeLabel = _localizedText(
      context,
      german: 'Druckzeit',
      english: 'Print Time',
    );

    final costsLabel = _localizedText(
      context,
      german: 'Kosten',
      english: 'Costs',
    );

    final dateLabel = _localizedText(
      context,
      german: 'Datum',
      english: 'Date',
    );

    final printedOnLabel = _localizedText(
      context,
      german: 'Gedruckt am',
      english: 'Printed on',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: Column(
        children: [
          PageHeader(
            title: pageTitle,
            showBackButton: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 28,
              ),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: job.color,
                  ),
                ),

                const SizedBox(height: 40),

                _sectionTitle(
                  context,
                  Icons.inventory_2_outlined,
                  l10n.filament,
                ),

                const SizedBox(height: 10),

                _sectionCard(
                  context,
                  Column(
                    children: [
                      _infoRow(
                        context,
                        l10n.manufacturer,
                        job.filamentBrand,
                      ),
                      _infoRow(
                        context,
                        l10n.material,
                        job.material,
                      ),
                      _infoRow(
                        context,
                        variantLabel,
                        job.variant,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle(
                  context,
                  Icons.print_outlined,
                  printDataLabel,
                ),

                const SizedBox(height: 10),

                _sectionCard(
                  context,
                  Column(
                    children: [
                      _infoRow(
                        context,
                        weightLabel,
                        '${job.weightUsed.toStringAsFixed(0)} g',
                      ),
                      _infoRow(
                        context,
                        printTimeLabel,
                        '${job.printHours.toStringAsFixed(1)} h',
                      ),
                      _infoRow(
                        context,
                        costsLabel,
                        '${job.totalCost.toStringAsFixed(2)} €',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle(
                  context,
                  Icons.calendar_today_outlined,
                  dateLabel,
                ),

                const SizedBox(height: 10),

                _sectionCard(
                  context,
                  _infoRow(
                    context,
                    printedOnLabel,
                    formattedDate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}