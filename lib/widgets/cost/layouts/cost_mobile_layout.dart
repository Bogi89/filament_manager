import 'package:flutter/material.dart';

import '../../../models/filament.dart';
import '../../../models/printer.dart';
import '../../common/page_header.dart';

class CostMobileLayout extends StatelessWidget {
  const CostMobileLayout({
    super.key,
    required this.formattedDate,
    required this.projectController,
    required this.wattController,
    required this.objectWeightController,
    required this.printTimeController,
    required this.spoolWeightController,
    required this.spoolPriceController,
    required this.electricityPriceController,
    required this.filaments,
    required this.printers,
    required this.selectedFilament,
    required this.selectedPrinter,
    required this.onPickDate,
    required this.onCalculate,
    required this.onSave,
    required this.onFilamentChanged,
    required this.onPrinterChanged,
    required this.subtractFromStock,
    required this.onSubtractChanged,
    required this.filamentCost,
    required this.electricityCost,
    required this.totalCost,
  });

  final String formattedDate;

  final TextEditingController projectController;
  final TextEditingController wattController;
  final TextEditingController objectWeightController;
  final TextEditingController printTimeController;
  final TextEditingController spoolWeightController;
  final TextEditingController spoolPriceController;
  final TextEditingController electricityPriceController;

  final List<Filament> filaments;
  final List<Printer> printers;

  final Filament? selectedFilament;
  final Printer? selectedPrinter;

  final VoidCallback onPickDate;
  final VoidCallback onCalculate;
  final VoidCallback onSave;

  final ValueChanged<Filament?> onFilamentChanged;
  final ValueChanged<Printer?> onPrinterChanged;

  final bool subtractFromStock;
  final ValueChanged<bool> onSubtractChanged;

  final double filamentCost;
  final double electricityCost;
  final double totalCost;

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ).copyWith(labelText: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const PageHeader(title: "Kosten berechnen"),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: theme.brightness == Brightness.dark
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  _field("Projektname", projectController),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Datum auswählen"),
                    subtitle: Text(formattedDate),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: onPickDate,
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<Filament>(
                    value: selectedFilament,
                    decoration: const InputDecoration(
                      labelText: "Filament auswählen",
                    ),
                    items: filaments.map((f) {
                      final percent = (f.remainingWeight / f.totalWeight) * 100;

                      String weightText = "${f.remainingWeight.toInt()} g";

                      if (percent <= 10) {
                        weightText = "${f.remainingWeight.toInt()} g ⚠";
                      }

                      return DropdownMenuItem<Filament>(
                        value: f,
                        child: Text(
                          "${f.brand} ${f.material} ${f.variant} ($weightText)",
                        ),
                      );
                    }).toList(),
                    onChanged: onFilamentChanged,
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<Printer>(
                    value: selectedPrinter,
                    decoration: const InputDecoration(
                      labelText: "Drucker auswählen",
                    ),
                    items: printers
                        .map(
                          (p) => DropdownMenuItem<Printer>(
                            value: p,
                            child: Text("${p.brand} ${p.name}"),
                          ),
                        )
                        .toList(),
                    onChanged: onPrinterChanged,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: theme.brightness == Brightness.dark
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  _numberField("Watt", wattController),

                  _numberField("Objektgewicht (g)", objectWeightController),

                  _numberField("Druckzeit (Minuten)", printTimeController),

                  _numberField("Spulengewicht (g)", spoolWeightController),

                  _numberField("Spulenpreis (€)", spoolPriceController),

                  _numberField(
                    "Stromkosten pro kWh",
                    electricityPriceController,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text("Vom Lager abziehen"),
              value: subtractFromStock,
              onChanged: onSubtractChanged,
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: onCalculate,
              child: const Text("Kosten berechnen"),
            ),

            const SizedBox(height: 20),

            Text(
              "Filamentkosten: ${filamentCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text(
              "Stromkosten: ${electricityCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 8),

            Text(
              "Gesamtkosten: ${totalCost.toStringAsFixed(2)} €",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: onSave, child: const Text("Speichern")),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
