import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../models/print_job.dart';
import '../models/printer.dart';
import '../services/printer_service.dart';
import '../widgets/common/page_header.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CostPage extends StatefulWidget {
  final List<Filament> filaments;
  final Function(PrintJob) onSaveJob;
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

  /// 📅 NEU — Datum
  DateTime selectedDate = DateTime.now();

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

    if (spoolWeight == 0) return;

    filamentCost = (spoolPrice / spoolWeight) * objectWeight;

    electricityCost = (watt / 1000) * (printTime / 60) * electricityPrice;

    totalCost = filamentCost + electricityCost;

    setState(() {});
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
    if (selectedFilament == null) return;

    final usedWeight =
        double.tryParse(objectWeightController.text.replaceAll(',', '.')) ?? 0;

    final hours =
        double.tryParse(printTimeController.text.replaceAll(',', '.')) ?? 0;

    if (usedWeight == 0 || totalCost == 0) return;

    final job = PrintJob(
      projectName: projectController.text,
      filamentBrand: selectedFilament!.brand,
      material: selectedFilament!.material,
      variant: selectedFilament!.variant,
      color: selectedFilament!.color,
      weightUsed: usedWeight,
      printHours: hours,
      totalCost: totalCost,

      /// 📅 GEÄNDERT
      date: selectedDate,
    );

    widget.onSaveJob(job);

    if (subtractFromStock) {
      double remainingToSubtract = usedWeight;

      for (final spool in selectedFilament!.spools) {
        if (remainingToSubtract <= 0) {
          break;
        }

        if (spool.weight >= remainingToSubtract) {
          spool.weight -= remainingToSubtract;
          remainingToSubtract = 0;
        } else {
          remainingToSubtract -= spool.weight;
          spool.weight = 0;
        }
      }

      widget.onUpdateFilament(selectedFilament!);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Druck gespeichert")));

    projectController.clear();

    setState(() {});
  }

  Future<void> showAddPrinterDialog([Printer? printer]) async {
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
          title: Text(
            printer == null ? "Neuen Drucker hinzufügen" : "Drucker bearbeiten",
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPrinterNameController,
                  decoration: const InputDecoration(labelText: "Druckername"),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: newPrinterWattController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Durchschnittliche Watt",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Abbrechen"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = newPrinterNameController.text.trim();

                final watt = double.tryParse(
                  newPrinterWattController.text.replaceAll(',', '.'),
                );

                if (name.isEmpty || watt == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Bitte Druckername und Watt eingeben."),
                    ),
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

                setState(() {
                  selectedPrinter = updatedPrinter;
                  wattController.text = watt.toStringAsFixed(0);
                });

                Navigator.pop(context);
              },
              child: const Text("Speichern"),
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
    final customPrinters = printers
        .where((printer) => printer.isCustom)
        .toList();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Drucker verwalten"),
          content: SizedBox(
            width: 500,
            child: customPrinters.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Es wurden noch keine eigenen Drucker angelegt.",
                    ),
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
                                tooltip: "Bearbeiten",
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
                                tooltip: "Löschen",
                                onPressed: () async {
                                  final shouldDelete = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Drucker löschen"),
                                        content: Text(
                                          'Soll "${printer.name}" wirklich gelöscht werden?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text("Abbrechen"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text("Löschen"),
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

                                  if (!mounted) return;

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
              child: const Text("Schließen"),
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
    final formattedDate =
        "${selectedDate.day.toString().padLeft(2, '0')}."
        "${selectedDate.month.toString().padLeft(2, '0')}."
        "${selectedDate.year}";

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
              PageHeader(title: "Kosten berechnen"),

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
                    const Text(
                      "Projekt",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    field("Projektname", projectController),

                    /// 📅 NEU — Datum Feld
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: formattedDate),
                      decoration: const InputDecoration(
                        labelText: "Datum",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: pickDate,
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<Filament>(
                      decoration: const InputDecoration(
                        labelText: "Filament auswählen",
                      ),

                      items: widget.filaments.map((f) {
                        final percent =
                            (f.remainingWeight / f.totalWeight) * 100;

                        String weightText = "${f.remainingWeight.toInt()} g";

                        if (percent <= 10) {
                          weightText = "${f.remainingWeight.toInt()} g ⚠";
                        }

                        return DropdownMenuItem(
                          value: f,

                          child: Text(
                            "${f.brand} ${f.material} ${f.variant} ($weightText)",
                          ),
                        );
                      }).toList(),

                      onChanged: (val) {
                        if (val == null) return;

                        setState(() {
                          selectedFilament = val;
                        });

                        spoolWeightController.text = val.totalWeight
                            .toStringAsFixed(0);

                        spoolPriceController.text = val.price.toStringAsFixed(
                          2,
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<Printer>(
                      decoration: const InputDecoration(
                        labelText: "Drucker auswählen",
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
                    const Text(
                      "Berechnung",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    numberField("Watt", wattController),
                    numberField("Objektgewicht (g)", objectWeightController),
                    numberField("Druckzeit (Minuten)", printTimeController),
                    numberField("Spulengewicht (g)", spoolWeightController),
                    numberField("Spulenpreis (€)", spoolPriceController),
                    numberField(
                      "Stromkosten pro kWh",
                      electricityPriceController,
                    ),
                  ],
                ),
              ),

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
                  title: const Text(
                    "Vom Lager abziehen",
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
                child: const Text("Kosten berechnen"),
              ),

              const SizedBox(height: 20),

              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultCard(
                          context,
                          title: "Filamentkosten",
                          value: "${filamentCost.toStringAsFixed(2)} €",
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildResultCard(
                          context,
                          title: "Stromkosten",
                          value: "${electricityCost.toStringAsFixed(2)} €",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  _buildResultCard(
                    context,
                    title: "Gesamtkosten",
                    value: "${totalCost.toStringAsFixed(2)} €",
                    isTotal: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(onPressed: save, child: const Text("Speichern")),
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
            const PageHeader(title: "Kosten berechnen"),

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
                          const Text(
                            "Projekt",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          field("Projektname", projectController),

                          const SizedBox(height: 10),

                          TextFormField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: formattedDate,
                            ),
                            decoration: const InputDecoration(
                              labelText: "Datum",
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            onTap: pickDate,
                          ),

                          const SizedBox(height: 12),

                          DropdownButtonFormField<Filament>(
                            decoration: const InputDecoration(
                              labelText: "Filament auswählen",
                            ),
                            items: widget.filaments.map((f) {
                              final percent =
                                  (f.remainingWeight / f.totalWeight) * 100;

                              String weightText =
                                  "${f.remainingWeight.toInt()} g";

                              if (percent <= 10) {
                                weightText = "${f.remainingWeight.toInt()} g ⚠";
                              }

                              return DropdownMenuItem(
                                value: f,
                                child: Text(
                                  "${f.brand} ${f.material} ${f.variant} ($weightText)",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;

                              setState(() {
                                selectedFilament = val;
                              });

                              spoolWeightController.text = val.totalWeight
                                  .toStringAsFixed(0);

                              spoolPriceController.text = val.price
                                  .toStringAsFixed(2);
                            },
                          ),

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
                            decoratorProps: const DropDownDecoratorProps(
                              decoration: InputDecoration(
                                labelText: "Drucker auswählen",
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
                                              tooltip: "Bearbeiten",
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
                              searchFieldProps: const TextFieldProps(
                                decoration: InputDecoration(
                                  hintText: "Drucker suchen...",
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
                                          child: const Padding(
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
                                                  "Neuen Drucker hinzufügen",
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
                                          child: const Padding(
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
                                                  "Drucker verwalten",
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
                          const Text(
                            "Berechnung",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          numberField("Watt", wattController),

                          const SizedBox(height: 10),

                          numberField(
                            "Objektgewicht (g)",
                            objectWeightController,
                          ),

                          const SizedBox(height: 10),

                          numberField(
                            "Druckzeit (Minuten)",
                            printTimeController,
                          ),
                          const SizedBox(height: 10),

                          numberField(
                            "Spulengewicht (g)",
                            spoolWeightController,
                          ),
                          const SizedBox(height: 10),

                          numberField("Spulenpreis (€)", spoolPriceController),

                          const SizedBox(height: 10),

                          numberField(
                            "Stromkosten pro kWh",
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
                title: const Text(
                  "Vom Lager abziehen",
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
                child: const Text("Kosten berechnen"),
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
                        const Text(
                          "Filamentkosten",
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
                        const Text(
                          "Stromkosten",
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
                        const Text(
                          "Gesamtkosten",
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
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: save,
                child: const Text("Speichern"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
