import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../models/print_job.dart';
import '../models/printer.dart';
import '../services/printer_service.dart';

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

  Filament? selectedFilament;
  Printer? selectedPrinter;

  final projectController = TextEditingController();
  final wattController = TextEditingController();
  final objectWeightController = TextEditingController();
  final printTimeController = TextEditingController();
  final spoolWeightController = TextEditingController();
  final spoolPriceController = TextEditingController();
  final electricityPriceController = TextEditingController();

  final List<Printer> printers = PrinterService.getDefaultPrinters();

  double filamentCost = 0;
  double electricityCost = 0;
  double totalCost = 0;

  bool subtractFromStock = true;

  void calculate() {

    if (selectedFilament == null) return;

    final watt =
        double.tryParse(wattController.text.replaceAll(',', '.')) ?? 0;

    final objectWeight =
        double.tryParse(objectWeightController.text.replaceAll(',', '.')) ?? 0;

    final printTime =
        double.tryParse(printTimeController.text.replaceAll(',', '.')) ?? 0;

    final spoolWeight =
        double.tryParse(spoolWeightController.text.replaceAll(',', '.')) ?? 0;

    final spoolPrice =
        double.tryParse(spoolPriceController.text.replaceAll(',', '.')) ?? 0;

    final electricityPrice =
        double.tryParse(electricityPriceController.text.replaceAll(',', '.')) ?? 0;

    if (spoolWeight == 0) return;

    filamentCost = (spoolPrice / spoolWeight) * objectWeight;

    electricityCost =
        (watt / 1000) * (printTime / 60) * electricityPrice;

    totalCost = filamentCost + electricityCost;

    setState(() {});
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
      date: DateTime.now(),
    );

    widget.onSaveJob(job);

    if (subtractFromStock) {

      selectedFilament!.remainingWeight -= usedWeight;

      widget.onUpdateFilament(selectedFilament!);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Druck gespeichert")),
    );

    projectController.clear();

    setState(() {});
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kosten berechnen"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: ListView(
          children: [

            field("Projektname", projectController),

            DropdownButtonFormField<Filament>(
              decoration:
                  const InputDecoration(labelText: "Filament auswählen"),
              items: widget.filaments
                  .map((f) => DropdownMenuItem(
                        value: f,
                        child: Text(
                            "${f.brand} ${f.material} ${f.variant}"),
                      ))
                  .toList(),
              onChanged: (val) {

                if (val == null) return;

                setState(() {
                  selectedFilament = val;
                });

                // automatisch übernehmen
                spoolWeightController.text =
                    val.totalWeight.toStringAsFixed(0);

                spoolPriceController.text =
                    val.price.toStringAsFixed(2);
              },
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<Printer>(
              decoration:
                  const InputDecoration(labelText: "Drucker auswählen"),
              items: printers
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Text("${p.brand} ${p.name}"),
                      ))
                  .toList(),
              onChanged: (printer) {

                if (printer == null) return;

                setState(() {
                  selectedPrinter = printer;
                });

                wattController.text =
                    printer.averageWatt.toStringAsFixed(0);
              },
            ),

            numberField("Watt", wattController),
            numberField("Objektgewicht (g)", objectWeightController),
            numberField("Druckzeit (Minuten)", printTimeController),
            numberField("Spulengewicht (g)", spoolWeightController),
            numberField("Spulenpreis (€)", spoolPriceController),
            numberField("Stromkosten pro kWh", electricityPriceController),

            SwitchListTile(
              title: const Text("Vom Lager abziehen"),
              value: subtractFromStock,
              onChanged: (val) {
                setState(() {
                  subtractFromStock = val;
                });
              },
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: calculate,
              child: const Text("Kosten berechnen"),
            ),

            const SizedBox(height: 20),

            Text(
              "Filamentkosten: ${filamentCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "Stromkosten: ${electricityCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18),
            ),

            Text(
              "Gesamtkosten: ${totalCost.toStringAsFixed(2)} €",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text("Speichern"),
            ),
          ],
        ),
      ),
    );
  }
}