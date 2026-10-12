import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/print_job.dart';
import '../widgets/common/page_header.dart';

class PrintJobDetailPage extends StatefulWidget {
  final PrintJob job;
  final bool Function(PrintJob) onUpdateJob;

  const PrintJobDetailPage({
    super.key,
    required this.job,
    required this.onUpdateJob,
  });

  @override
  State<PrintJobDetailPage> createState() => _PrintJobDetailPageState();
}

class _PrintJobDetailPageState extends State<PrintJobDetailPage> {
  late PrintJob job;

  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  String _localizedText(
    BuildContext context, {
    required String german,
    required String english,
  }) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return languageCode == 'de' ? german : english;
  }

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
      child: Padding(padding: const EdgeInsets.all(22), child: child),
    );
  }

  Future<void> _showEditDialog() async {
    final projectController = TextEditingController(text: job.projectName);
    final weightController = TextEditingController(
      text: job.weightUsed.toStringAsFixed(0),
    );
    final timeController = TextEditingController(
      text: job.printHours.toStringAsFixed(1),
    );
    final costController = TextEditingController(
      text: job.totalCost.toStringAsFixed(2),
    );

    DateTime selectedDate = job.date;

    final updatedJob = await showDialog<PrintJob>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                _localizedText(
                  context,
                  german: 'Druckauftrag bearbeiten',
                  english: 'Edit print job',
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: projectController,
                      decoration: InputDecoration(
                        labelText: _localizedText(
                          context,
                          german: 'Projektname',
                          english: 'Project name',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _localizedText(
                          context,
                          german: 'Gewicht (g)',
                          english: 'Weight (g)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: timeController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _localizedText(
                          context,
                          german: 'Druckzeit (h)',
                          english: 'Print time (h)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: _localizedText(
                          context,
                          german: 'Kosten (€)',
                          english: 'Costs (€)',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(
                        '${selectedDate.day.toString().padLeft(2, '0')}.'
                        '${selectedDate.month.toString().padLeft(2, '0')}.'
                        '${selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.edit_calendar_outlined),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    _localizedText(
                      context,
                      german: 'Abbrechen',
                      english: 'Cancel',
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    final weight = double.tryParse(
                      weightController.text.replaceAll(',', '.'),
                    );
                    final printTime = double.tryParse(
                      timeController.text.replaceAll(',', '.'),
                    );
                    final costs = double.tryParse(
                      costController.text.replaceAll(',', '.'),
                    );

                    if (weight == null ||
                        printTime == null ||
                        costs == null ||
                        weight < 0 ||
                        printTime < 0 ||
                        costs < 0) {
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      PrintJob(
                        projectName: projectController.text.trim(),
                        filamentId: job.filamentId,
                        filamentBrand: job.filamentBrand,
                        material: job.material,
                        variant: job.variant,
                        color: job.color,
                        weightUsed: weight,
                        printHours: printTime,
                        totalCost: costs,
                        date: selectedDate,
                      ),
                    );
                  },
                  child: Text(
                    _localizedText(
                      context,
                      german: 'Speichern',
                      english: 'Save',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (updatedJob == null || !mounted) {
      return;
    }

    final updateSuccessful = widget.onUpdateJob(updatedJob);

    if (!updateSuccessful) {
      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.insufficientFilamentStock)));

      return;
    }

    setState(() {
      job = updatedJob;
    });
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

    final dateLabel = _localizedText(context, german: 'Datum', english: 'Date');

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
          PageHeader(title: pageTitle, showBackButton: true),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _showEditDialog,
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  _localizedText(
                    context,
                    german: 'Bearbeiten',
                    english: 'Edit',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(40, 28, 40, 100),
              children: [
                Center(
                  child: CircleAvatar(radius: 44, backgroundColor: job.color),
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
                      _infoRow(context, l10n.manufacturer, job.filamentBrand),
                      _infoRow(context, l10n.material, job.material),
                      _infoRow(context, variantLabel, job.variant),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                _sectionTitle(context, Icons.print_outlined, printDataLabel),

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
                  _infoRow(context, printedOnLabel, formattedDate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
