import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/print_job.dart';
import '../services/print_job_cost_recalculator.dart';
import '../utils/print_duration_formatter.dart';
import '../widgets/common/page_header.dart';
import '../widgets/common/filament_color_circle.dart';

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

  static const _productionKeys = <String>[
    'filamentCost',
    'electricityCost',
    'printerDepreciation',
    'maintenance',
    'additionalWear',
    'preparation',
    'postProcessing',
    'packagingWork',
    'failedPrint',
    'supportAndWaste',
    'additionalMaterials',
    'packagingAndShipping',
    'overhead',
  ];

  static const _sellingKeys = <String>[
    'profitMarkupAmount',
    'platformFeeAmount',
    'vatAmount',
    'actualProfit',
  ];

  @override
  void initState() {
    super.initState();
    job = widget.job;
  }

  String _money(double amount) =>
      '${amount.toStringAsFixed(2).replaceAll('.', ',')} €';

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.'
      '${date.month.toString().padLeft(2, '0')}.'
      '${date.year}';

  String _costLabel(String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'filamentCost':
        return l10n.v12FilamentCost;
      case 'electricityCost':
        return l10n.v12ElectricityCost;
      case 'printerDepreciation':
        return l10n.v12PrinterDepreciation;
      case 'maintenance':
        return l10n.v12Maintenance;
      case 'additionalWear':
        return l10n.v12AdditionalWear;
      case 'preparation':
        return l10n.v12Preparation;
      case 'postProcessing':
        return l10n.v12PostProcessing;
      case 'packagingWork':
        return l10n.v12PackagingLabor;
      case 'failedPrint':
        return l10n.v12FailedPrints;
      case 'supportAndWaste':
        return l10n.v12SupportAndWaste;
      case 'additionalMaterials':
        return l10n.v12AdditionalMaterials;
      case 'packagingAndShipping':
        return l10n.v12PackagingAndShipping;
      case 'overhead':
        return l10n.v12Overhead;
      case 'profitMarkupAmount':
        return l10n.v12ProfitMarkup;
      case 'platformFeeAmount':
        return l10n.v12PlatformFees;
      case 'vatAmount':
        return l10n.v12Vat;
      case 'actualProfit':
        return l10n.v12ActualProfit;
      default:
        return key;
    }
  }

  double? _positiveCost(String key) {
    final amount = job.costBreakdown[key];
    if (amount == null || !amount.isFinite || amount < 0.005) {
      return null;
    }
    return amount;
  }

  Widget _heading(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: child,
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: strong ? FontWeight.bold : FontWeight.w500,
                color: strong
                    ? null
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: strong ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costRow(String key) {
    final amount = _positiveCost(key);
    if (amount == null) {
      return const SizedBox.shrink();
    }
    return _row(_costLabel(key), _money(amount));
  }

  Widget _colorRow() {
    final names = job.colorNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty && name.toLowerCase() != 'unknown')
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.v12Color,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilamentColorCircle(
                  colors: job.colors,
                  fallbackColor: job.color,
                  size: 24,
                ),
                if (names.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      names.join(' + '),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filamentSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(Icons.inventory_2_outlined, l10n.filament),
        _card(
          _costPanel(
            Column(
              children: [
                _row(l10n.manufacturer, job.filamentBrand),
                _row(l10n.material, job.material),
                _row(AppLocalizations.of(context)!.v12Variant, job.variant),
                _colorRow(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _printSection({required bool includeDate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          Icons.print_outlined,
          AppLocalizations.of(context)!.v12PrintData,
        ),
        _card(
          _costPanel(
            Column(
              children: [
                _row(
                  AppLocalizations.of(context)!.v12Weight,
                  '${job.weightUsed.toStringAsFixed(0)} g',
                ),
                _row(
                  AppLocalizations.of(context)!.v12PrintTime,
                  PrintDurationFormatter.format(job.printMinutes),
                ),
                _row(
                  AppLocalizations.of(context)!.v12Costs,
                  _money(job.totalCost),
                  strong: true,
                ),
                if (includeDate)
                  _row(AppLocalizations.of(context)!.v12Date, _date(job.date)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _totalHighlight(String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _costPanel(Widget child) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _productionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.v12ProductionCosts,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        for (final key in _productionKeys) _costRow(key),
        if ((job.costBreakdown['manualAdjustment'] ?? 0).abs() > 0.000001)
          _row(
            AppLocalizations.of(context)!.v12Costs,
            _money(job.costBreakdown['manualAdjustment']!),
          ),
        const SizedBox(height: 12),
        _totalHighlight(
          AppLocalizations.of(context)!.v12TotalProductionCost,
          _money(job.costBreakdown['productionCost'] ?? job.totalCost),
        ),
      ],
    );
  }

  Widget _sellingSection() {
    final net = _positiveCost('netSellingPrice');
    final gross = _positiveCost('grossSellingPrice') ?? job.sellingPrice;
    final hasSelling =
        _sellingKeys.any((key) => _positiveCost(key) != null) ||
        net != null ||
        (gross != null && gross > 0);
    if (!hasSelling) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.v12SalesCalculation,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _row(
          AppLocalizations.of(context)!.v12ProductionCosts,
          _money(job.totalCost),
        ),
        for (final key in _sellingKeys)
          if (key != 'vatAmount') _costRow(key),
        if (net != null)
          _row(AppLocalizations.of(context)!.v12NetSellingPrice, _money(net)),
        _costRow('vatAmount'),
        if (gross != null && gross > 0) ...[
          const SizedBox(height: 12),
          _totalHighlight(
            AppLocalizations.of(context)!.v12GrossSellingPrice,
            _money(gross),
          ),
        ],
      ],
    );
  }

  Widget _costSection({required bool wide}) {
    if (job.costBreakdown.isEmpty && job.sellingPrice == null) {
      return const SizedBox.shrink();
    }
    final hasSelling =
        _sellingKeys.any((key) => _positiveCost(key) != null) ||
        _positiveCost('netSellingPrice') != null ||
        _positiveCost('grossSellingPrice') != null ||
        (job.sellingPrice != null && job.sellingPrice! > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          Icons.receipt_long_outlined,
          AppLocalizations.of(context)!.v12CostBreakdown,
        ),
        _card(
          wide && hasSelling
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _costPanel(_productionSection())),
                    const SizedBox(width: 32),
                    Expanded(child: _costPanel(_sellingSection())),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _costPanel(_productionSection()),
                    if (hasSelling) ...[
                      const SizedBox(height: 14),
                      _costPanel(_sellingSection()),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog() async {
    final projectController = TextEditingController(text: job.projectName);
    final weightController = TextEditingController(
      text: job.weightUsed.toStringAsFixed(0),
    );
    final timeController = TextEditingController(
      text: job.printMinutes.toStringAsFixed(1),
    );
    final costController = TextEditingController(
      text: job.totalCost.toStringAsFixed(2),
    );
    DateTime selectedDate = job.date;
    bool manuallyEdited = false;
    bool canAutoCalculate = false;
    void refreshPrice() {
      final weight = double.tryParse(
        weightController.text.replaceAll(',', '.'),
      );
      final minutes = double.tryParse(timeController.text.replaceAll(',', '.'));
      if (weight == null ||
          minutes == null ||
          !weight.isFinite ||
          !minutes.isFinite ||
          weight < 0 ||
          minutes < 0) {
        return;
      }
      try {
        final computed = PrintJobCostRecalculator.recalculate(
          job,
          weight: weight,
          minutes: minutes,
        );
        canAutoCalculate = computed != null;
        if (computed != null) {
          costController.text = computed.totalCost.toStringAsFixed(2);
          manuallyEdited = false;
        }
      } on ArgumentError {
        canAutoCalculate = false;
      }
    }

    refreshPrice();

    try {
      // A popped dialog remains mounted during its exit animation.
      // Wait for the route to finish before disposing its text controllers.
      final dialogRoute = DialogRoute<PrintJob>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.v12EditPrintJob),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: projectController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.v12ProjectName,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightController,
                    onChanged: (_) => refreshPrice(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.v12WeightG,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: timeController,
                    onChanged: (_) => refreshPrice(),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.v12PrintTimeMin,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: costController,
                    onChanged: (_) => manuallyEdited = true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.v12Costs,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(_date(selectedDate)),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && dialogContext.mounted) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(AppLocalizations.of(context)!.v12Cancel),
              ),
              FilledButton(
                onPressed: () {
                  final weight = double.tryParse(
                    weightController.text.replaceAll(',', '.'),
                  );
                  final minutes = double.tryParse(
                    timeController.text.replaceAll(',', '.'),
                  );
                  final cost = double.tryParse(
                    costController.text.replaceAll(',', '.'),
                  );
                  if (weight == null ||
                      minutes == null ||
                      cost == null ||
                      !weight.isFinite ||
                      !minutes.isFinite ||
                      !cost.isFinite ||
                      weight < 0 ||
                      minutes < 0 ||
                      cost < 0) {
                    return;
                  }
                  PrintJob? recalculated;
                  try {
                    recalculated = PrintJobCostRecalculator.recalculate(
                      job,
                      weight: weight,
                      minutes: minutes,
                      manualTotal: manuallyEdited || !canAutoCalculate
                          ? cost
                          : null,
                    );
                  } on ArgumentError {
                    return;
                  }
                  if (recalculated == null) {
                    return;
                  }
                  Navigator.of(dialogContext).pop(
                    recalculated.copyWith(
                      projectName: projectController.text.trim(),
                      date: selectedDate,
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.v12Save),
              ),
            ],
          ),
        ),
      );
      final updatedJob = await Navigator.of(
        context,
        rootNavigator: true,
      ).push<PrintJob>(dialogRoute);
      await dialogRoute.completed;
      if (updatedJob == null || !mounted) {
        return;
      }
      if (!widget.onUpdateJob(updatedJob)) {
        if (!mounted) {
          return;
        }
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.insufficientFilamentStock)));
        return;
      }
      setState(() => job = updatedJob);
    } finally {
      projectController.dispose();
      weightController.dispose();
      timeController.dispose();
      costController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = job.projectName.isEmpty
        ? AppLocalizations.of(context)!.v12PrintDetails
        : job.projectName;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),
      body: Column(
        children: [
          PageHeader(title: title, showBackButton: true),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 800;
                final horizontalPadding = wide ? 28.0 : 14.0;
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    12,
                    horizontalPadding,
                    64,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _showEditDialog,
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(AppLocalizations.of(context)!.v12Edit),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _filamentSection(l10n)),
                          const SizedBox(width: 20),
                          Expanded(child: _printSection(includeDate: true)),
                        ],
                      )
                    else ...[
                      _filamentSection(l10n),
                      const SizedBox(height: 22),
                      _printSection(includeDate: false),
                    ],
                    const SizedBox(height: 22),
                    _costSection(wide: wide),
                    if (!wide) ...[
                      const SizedBox(height: 22),
                      _heading(
                        Icons.calendar_today_outlined,
                        AppLocalizations.of(context)!.v12Date,
                      ),
                      _card(
                        _row(
                          AppLocalizations.of(context)!.v12PrintedOn,
                          _date(job.date),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
