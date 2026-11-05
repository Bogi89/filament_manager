import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/extended_costs.dart';
import '../models/filament.dart';
import '../models/print_job.dart';
import '../models/printer.dart';
import '../services/extended_cost_calculator.dart';
import '../services/printer_service.dart';
import '../widgets/cost/extended_costs_section.dart';
import '../widgets/cost/filament_dropdown_item.dart';
import '../widgets/common/page_header.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CostPage extends StatefulWidget {
  final List<Filament> filaments;
  final bool Function(PrintJob, bool) onSaveJob;
  final Function(Filament) onUpdateFilament;

  const CostPage({
    super.key,
    required this.filaments,
    required this.onSaveJob,
    required this.onUpdateFilament,
  });

  @override
  State<CostPage> createState() => _CostPageState();
}

class _CostPageState extends State<CostPage> {
  @override
  void initState() {
    super.initState();
    loadPrinters();
  }

  Filament? selectedFilament;
  String? selectedSpoolId;
  Printer? selectedPrinter;

  final projectController = TextEditingController();
  final wattController = TextEditingController();
  final objectWeightController = TextEditingController();
  final printTimeController = TextEditingController();
  final spoolWeightController = TextEditingController();
  final spoolPriceController = TextEditingController();
  final electricityPriceController = TextEditingController();
  final newPrinterNameController = TextEditingController();
  final newPrinterWattController = TextEditingController();

  List<Printer> printers = [];

  double filamentCost = 0;
  double electricityCost = 0;
  double totalCost = 0;

  bool subtractFromStock = true;

  ExtendedCosts extendedCosts = ExtendedCosts();
  ExtendedCostResult? extendedResult;

  void _updateExtendedCosts(ExtendedCosts updated) {
    setState(() {
      extendedCosts = updated;
      extendedResult = null;
      filamentCost = 0;
      electricityCost = 0;
      totalCost = 0;
    });
  }

  Widget _extendedCostSummary(BuildContext context) {
    final result = extendedResult;
    if (result == null || !extendedCosts.enabled) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          _buildResultCard(
            context,
            title: AppLocalizations.of(context)!.v12AdditionalProductionCosts,
            value: '${result.additionalCostTotal.toStringAsFixed(2)} €',
          ),
          if (result.sellingCalculationEnabled) ...[
            const SizedBox(height: 12),
            _buildResultCard(
              context,
              title: AppLocalizations.of(context)!.v12NetSellingPrice,
              value: '${result.netSellingPrice.toStringAsFixed(2)} €',
            ),
            const SizedBox(height: 12),
            _buildResultCard(
              context,
              title: AppLocalizations.of(context)!.v12GrossSellingPrice,
              value: '${result.grossSellingPrice.toStringAsFixed(2)} €',
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }

  /// 📅 NEU — Datum
  DateTime selectedDate = DateTime.now();

  double _readNumber(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  bool _calculationIsCurrent = false;

  void _invalidateCalculation() {
    if (!mounted) return;
    setState(() {
      _calculationIsCurrent = false;
      extendedResult = null;
      filamentCost = 0;
      electricityCost = 0;
      totalCost = 0;
    });
  }

  @override
  void dispose() {
    for (final controller in [
      projectController,
      wattController,
      objectWeightController,
      printTimeController,
      spoolWeightController,
      spoolPriceController,
      electricityPriceController,
      newPrinterNameController,
      newPrinterWattController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectFilament(Filament filament) async {
    setState(() {
      selectedFilament = filament;
      selectedSpoolId = filament.spools.length == 1
          ? filament.spools.first.id
          : null;
      _calculationIsCurrent = false;
      extendedResult = null;
    });
    _updateSelectedSpoolFields();
    if (filament.spools.length > 1) {
      await _chooseSpool();
    }
  }

  void _updateSelectedSpoolFields() {
    final filament = selectedFilament;
    if (filament == null) return;
    final matches = filament.spools.where((s) => s.id == selectedSpoolId);
    if (matches.isEmpty) {
      spoolWeightController.clear();
      spoolPriceController.clear();
      return;
    }
    final spool = matches.first;
    // The calculation uses the purchased spool's nominal weight, not the
    // remaining weight. The existing model only stores remaining weight;
    // preserve the existing calculation convention for now.
    spoolWeightController.text = spool.weight.toStringAsFixed(0);
    spoolPriceController.text = spool
        .effectivePrice(filament.price)
        .toStringAsFixed(2);
  }

  Future<void> _chooseSpool() async {
    final filament = selectedFilament;
    if (filament == null || filament.spools.isEmpty) return;
    if (filament.spools.length == 1) {
      setState(() => selectedSpoolId = filament.spools.first.id);
      _updateSelectedSpoolFields();
      return;
    }
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext)!.selectSpool),
        content: SizedBox(
          width: 440,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filament.spools.length,
            itemBuilder: (context, index) {
              final spool = filament.spools[index];
              final location = [
                spool.storageLocation,
                spool.storagePosition,
              ].where((value) => value.trim().isNotEmpty).join(' / ');
              return ListTile(
                leading: Icon(
                  selectedSpoolId == spool.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                title: Text(
                  '${AppLocalizations.of(dialogContext)!.spoolNumber(index + 1)} – '
                  '${spool.weight.toStringAsFixed(0)} g',
                ),
                subtitle: Text(
                  location.isEmpty
                      ? '${spool.effectivePrice(filament.price).toStringAsFixed(2)} €'
                      : '$location · ${spool.effectivePrice(filament.price).toStringAsFixed(2)} €',
                ),
                onTap: () => Navigator.of(dialogContext).pop(spool.id),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(dialogContext)!.cancel),
          ),
        ],
      ),
    );
    if (!mounted || selectedFilament != filament || chosen == null) return;
    setState(() {
      selectedSpoolId = chosen;
      _calculationIsCurrent = false;
      extendedResult = null;
    });
    _updateSelectedSpoolFields();
  }

  Widget _spoolSelectionControl() {
    final filament = selectedFilament;
    if (filament == null || filament.spools.length <= 1) {
      return const SizedBox.shrink();
    }
    final index = filament.spools.indexWhere((s) => s.id == selectedSpoolId);
    final label = index < 0
        ? AppLocalizations.of(context)!.selectSpoolRequired
        : '${AppLocalizations.of(context)!.spoolNumber(index + 1)} – '
              '${filament.spools[index].weight.toStringAsFixed(0)} g';
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _chooseSpool,
        icon: const Icon(Icons.inventory_2_outlined),
        label: Text(label),
      ),
    );
  }

  void calculate() {
    if (selectedFilament == null) return;

    final watt = double.tryParse(wattController.text.replaceAll(',', '.')) ?? 0;

    final objectWeight =
        double.tryParse(objectWeightController.text.replaceAll(',', '.')) ?? 0;

    final printTime =
        double.tryParse(printTimeController.text.replaceAll(',', '.')) ?? 0;

    final spoolWeight =
        double.tryParse(spoolWeightController.text.replaceAll(',', '.')) ?? 0;

    final spoolPrice =
        double.tryParse(spoolPriceController.text.replaceAll(',', '.')) ?? 0;

    final electricityPrice =
        double.tryParse(electricityPriceController.text.replaceAll(',', '.')) ??
        0;

    if (spoolWeight <= 0 ||
        !spoolWeight.isFinite ||
        !spoolPrice.isFinite ||
        spoolPrice < 0 ||
        !objectWeight.isFinite ||
        objectWeight < 0 ||
        !printTime.isFinite ||
        printTime < 0 ||
        !watt.isFinite ||
        watt < 0 ||
        !electricityPrice.isFinite ||
        electricityPrice < 0) {
      _invalidateCalculation();
      return;
    }

    filamentCost = (spoolPrice / spoolWeight) * objectWeight;

    electricityCost = (watt / 1000) * (printTime / 60) * electricityPrice;

    try {
      final result = ExtendedCostCalculator.calculate(
        filamentCost: filamentCost,
        electricityCost: electricityCost,
        printTimeMinutes: printTime,
        objectWeightGrams: objectWeight,
        spoolWeightGrams: spoolWeight,
        spoolPrice: spoolPrice,
        settings: extendedCosts,
      );

      setState(() {
        extendedResult = result;
        totalCost = result.productionCost;
        _calculationIsCurrent = true;
      });
    } on ArgumentError {
      setState(() {
        extendedResult = null;
        totalCost = 0;
        _calculationIsCurrent = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.v12InvalidSellingFees),
        ),
      );
    }
  }

  /// 📅 Datum auswählen
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> loadPrinters() async {
    printers = await PrinterService.getAllPrinters();

    if (mounted) {
      setState(() {});
    }
  }

  void save() {
    final l10n = AppLocalizations.of(context)!;

    if (selectedFilament == null) return;
    if (subtractFromStock && selectedSpoolId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chooseSpoolFirst)));
      return;
    }

    final usedWeight =
        double.tryParse(objectWeightController.text.replaceAll(',', '.')) ?? 0;

    final minutes =
        double.tryParse(printTimeController.text.replaceAll(',', '.')) ?? 0;

    // Always recalculate using the latest field values before persisting.
    calculate();
    if (!_calculationIsCurrent || usedWeight <= 0 || !totalCost.isFinite) {
      return;
    }

    final result = extendedResult;
    final breakdown = <String, double>{
      'filamentCost': filamentCost,
      'electricityCost': electricityCost,
    };
    if (result != null) {
      for (final entry in result.additionalCosts.entries) {
        breakdown[entry.key.name] = entry.value;
      }
      breakdown['productionCost'] = result.productionCost;
      if (result.sellingCalculationEnabled) {
        breakdown['profitMarkupAmount'] = result.profitMarkupAmount;
        breakdown['platformFeeAmount'] = result.platformFeeAmount;
        breakdown['vatAmount'] = result.vatAmount;
        breakdown['netSellingPrice'] = result.netSellingPrice;
        breakdown['grossSellingPrice'] = result.grossSellingPrice;
        breakdown['actualProfit'] = result.actualProfit;
      }
    }

    final job = PrintJob(
      projectName: projectController.text,
      filamentId: selectedFilament!.id,
      filamentBrand: selectedFilament!.brand,
      material: selectedFilament!.material,
      variant: selectedFilament!.variant,
      color: selectedFilament!.effectiveColors.first,
      weightUsed: usedWeight,
      spoolUsage: subtractFromStock && selectedSpoolId != null
          ? {selectedSpoolId!: usedWeight}
          : <String, double>{},
      printMinutes: minutes,
      colors: selectedFilament!.effectiveColors,
      colorNames: selectedFilament!.effectiveColorNames,
      totalCost: totalCost,
      extendedCosts: extendedCosts,
      costBreakdown: breakdown,
      calculationInputs: {
        'spoolWeightGrams': _readNumber(spoolWeightController),
        'spoolPrice': _readNumber(spoolPriceController),
        'printerWatt': _readNumber(wattController),
        'electricityPricePerKwh': _readNumber(electricityPriceController),
      },
      sellingPrice:
          extendedCosts.enabled &&
              result != null &&
              result.sellingCalculationEnabled
          ? result.grossSellingPrice
          : null,

      /// 📅 GEÄNDERT
      date: selectedDate,
    );

    final saved = widget.onSaveJob(job, subtractFromStock);
    if (!saved) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.insufficientFilamentStock)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.printSaved)));

    projectController.clear();

    setState(() {});
  }

  Future<void> showAddPrinterDialog([Printer? printer]) async {
    final l10n = AppLocalizations.of(context)!;
    if (printer == null) {
      newPrinterNameController.clear();
      newPrinterWattController.clear();
    } else {
      newPrinterNameController.text = printer.name;
      newPrinterWattController.text = printer.averageWatt.toStringAsFixed(0);
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(printer == null ? l10n.addPrinter : l10n.editPrinter),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPrinterNameController,
                  decoration: InputDecoration(labelText: l10n.printerName),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: newPrinterWattController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.averageWatt),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = newPrinterNameController.text.trim();

                final watt = double.tryParse(
                  newPrinterWattController.text.replaceAll(',', '.'),
                );

                if (name.isEmpty || watt == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.enterPrinterNameAndWatt)),
                  );
                  return;
                }

                final updatedPrinter = Printer(
                  brand: "",
                  name: name,
                  averageWatt: watt,
                  isCustom: true,
                );

                if (printer != null) {
                  await PrinterService.deleteCustomPrinter(printer);
                }

                await PrinterService.saveCustomPrinter(updatedPrinter);

                await loadPrinters();

                if (!mounted || !context.mounted) return;

                setState(() {
                  selectedPrinter = updatedPrinter;
                  wattController.text = watt.toStringAsFixed(0);
                });

                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  Widget field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> showPrinterManagerDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final customPrinters = printers
        .where((printer) => printer.isCustom)
        .toList();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.managePrinters),
          content: SizedBox(
            width: 500,
            child: customPrinters.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.noCustomPrinters),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: customPrinters.length,
                    itemBuilder: (context, index) {
                      final printer = customPrinters[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            printer.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "${printer.averageWatt.toStringAsFixed(0)} Watt",
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: l10n.edit,
                                onPressed: () async {
                                  Navigator.pop(context);

                                  await Future.delayed(
                                    const Duration(milliseconds: 150),
                                  );

                                  if (!mounted) return;

                                  await showAddPrinterDialog(printer);

                                  await loadPrinters();

                                  if (mounted) {
                                    showPrinterManagerDialog();
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: l10n.delete,
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(l10n.deletePrinter),
                                        content: Text(
                                          l10n.confirmDeletePrinter(
                                            printer.name,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text(l10n.cancel),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: Text(l10n.delete),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldDelete != true) return;

                                  await PrinterService.deleteCustomPrinter(
                                    printer,
                                  );

                                  if (selectedPrinter?.name == printer.name) {
                                    setState(() {
                                      selectedPrinter = null;
                                      wattController.clear();
                                    });
                                  }

                                  await loadPrinters();

                                  if (!mounted || !context.mounted) return;

                                  Navigator.pop(context);

                                  showPrinterManagerDialog();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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

  Widget numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: (_) => _invalidateCalculation(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required String value,
    bool isTotal = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 26 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final formattedDate = MaterialLocalizations.of(
      context,
    ).formatMediumDate(selectedDate);

    final isMobile = MediaQuery.of(context).size.width < 1000;

    if (isMobile) {
      return Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.black
            : const Color(0xFFE9EEF5),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: ListView(
            children: [
              PageHeader(title: l10n.calculateCosts),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.project,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    field(l10n.projectName, projectController),

                    /// 📅 NEU — Datum Feld
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: formattedDate),
                      decoration: InputDecoration(
                        labelText: l10n.date,
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: pickDate,
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<Filament>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.selectFilament,
                      ),

                      items: widget.filaments.map((f) {
                        return DropdownMenuItem<Filament>(
                          value: f,
                          child: FilamentDropdownItem(filament: f),
                        );
                      }).toList(),

                      onChanged: (val) {
                        if (val == null) return;

                        _selectFilament(val);
                      },
                    ),
                    _spoolSelectionControl(),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<Printer>(
                      decoration: InputDecoration(
                        labelText: l10n.selectPrinter,
                      ),
                      items: printers
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text("${p.brand} ${p.name}"),
                            ),
                          )
                          .toList(),
                      onChanged: (printer) {
                        if (printer == null) return;

                        setState(() {
                          selectedPrinter = printer;
                          _calculationIsCurrent = false;
                        });

                        wattController.text = printer.averageWatt
                            .toStringAsFixed(0);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: Theme.of(context).brightness == Brightness.dark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.calculation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    numberField(l10n.watt, wattController),
                    numberField(l10n.objectWeight, objectWeightController),
                    numberField(l10n.printTimeMinutes, printTimeController),
                    numberField(l10n.spoolWeight, spoolWeightController),
                    numberField(l10n.spoolPrice, spoolPriceController),
                    numberField(
                      l10n.electricityCostPerKwh,
                      electricityPriceController,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ExtendedCostsSection(
                settings: extendedCosts,
                onChanged: _updateExtendedCosts,
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  title: Text(
                    l10n.subtractFromStock,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: subtractFromStock,
                  onChanged: (val) {
                    setState(() {
                      subtractFromStock = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: calculate,
                child: Text(l10n.calculateCosts),
              ),

              const SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultCard(
                          context,
                          title: l10n.filamentCost,
                          value: "${filamentCost.toStringAsFixed(2)} €",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildResultCard(
                          context,
                          title: l10n.electricityCost,
                          value: "${electricityCost.toStringAsFixed(2)} €",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildResultCard(
                    context,
                    title: l10n.totalCost,
                    value: "${totalCost.toStringAsFixed(2)} €",
                    isTotal: true,
                  ),
                ],
              ),

              _extendedCostSummary(context),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: save, child: Text(l10n.save)),
            ],
          ),
        ), // Padding Mobile
      );
    }
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView(
          children: [
            PageHeader(title: l10n.calculateCosts),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.project,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          field(l10n.projectName, projectController),

                          const SizedBox(height: 10),

                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: formattedDate,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.date,
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: pickDate,
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<Filament>(
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l10n.selectFilament,
                            ),
                            items: widget.filaments.map((f) {
                              return DropdownMenuItem<Filament>(
                                value: f,
                                child: FilamentDropdownItem(filament: f),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;

                              _selectFilament(val);
                            },
                          ),
                          _spoolSelectionControl(),

                          const SizedBox(height: 10),

                          DropdownSearch<Printer>(
                            selectedItem: selectedPrinter,
                            items: (filter, _) {
                              if (filter.isEmpty) {
                                return printers;
                              }

                              return printers.where((printer) {
                                final displayName = printer.brand.isEmpty
                                    ? printer.name
                                    : "${printer.brand} ${printer.name}";

                                return displayName.toLowerCase().contains(
                                  filter.toLowerCase(),
                                );
                              }).toList();
                            },
                            compareFn: (a, b) => a.name == b.name,
                            itemAsString: (printer) {
                              if (printer.brand.isEmpty) {
                                return printer.name;
                              }

                              return "${printer.brand} ${printer.name}";
                            },
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: l10n.selectPrinter,
                              ),
                            ),
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              itemBuilder:
                                  (context, printer, isDisabled, isSelected) {
                                    final displayName = printer.brand.isEmpty
                                        ? printer.name
                                        : "${printer.brand} ${printer.name}";

                                    return ListTile(
                                      title: Text(displayName),
                                      trailing: printer.isCustom
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              tooltip: l10n.edit,
                                              onPressed: () async {
                                                Navigator.pop(context);

                                                await Future.delayed(
                                                  const Duration(
                                                    milliseconds: 150,
                                                  ),
                                                );

                                                if (mounted) {
                                                  showAddPrinterDialog(printer);
                                                }
                                              },
                                            )
                                          : null,
                                    );
                                  },
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: l10n.searchPrinter,
                                ),
                              ),
                              containerBuilder: (context, popupWidget) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                            showAddPrinterDialog();
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.add_circle_outline,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  l10n.addPrinter,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            Navigator.pop(context);

                                            await Future.delayed(
                                              const Duration(milliseconds: 150),
                                            );

                                            if (mounted) {
                                              showPrinterManagerDialog();
                                            }
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.settings,
                                                  color: Colors.orange,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  l10n.managePrinters,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Flexible(child: popupWidget),
                                  ],
                                );
                              },
                            ),
                            onChanged: (printer) {
                              if (printer == null) return;

                              setState(() {
                                selectedPrinter = printer;
                                _calculationIsCurrent = false;
                              });

                              wattController.text = printer.averageWatt
                                  .toStringAsFixed(0);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.calculation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          numberField(l10n.watt, wattController),

                          const SizedBox(height: 10),

                          numberField(
                            l10n.objectWeight,
                            objectWeightController,
                          ),

                          const SizedBox(height: 10),

                          numberField(
                            l10n.printTimeMinutes,
                            printTimeController,
                          ),
                          const SizedBox(height: 10),

                          numberField(l10n.spoolWeight, spoolWeightController),
                          const SizedBox(height: 10),

                          numberField(l10n.spoolPrice, spoolPriceController),

                          const SizedBox(height: 10),

                          numberField(
                            l10n.electricityCostPerKwh,
                            electricityPriceController,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            ExtendedCostsSection(
              settings: extendedCosts,
              onChanged: _updateExtendedCosts,
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                title: Text(
                  l10n.subtractFromStock,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                value: subtractFromStock,
                onChanged: (val) {
                  setState(() {
                    subtractFromStock = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: calculate,
                child: Text(l10n.calculateCosts),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.filamentCost,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${filamentCost.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.electricityCost,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${electricityCost.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.totalCost,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${totalCost.toStringAsFixed(2)} €",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _extendedCostSummary(context),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: save, child: Text(l10n.save)),
            ),
          ],
        ),
      ),
    );
  }
}
