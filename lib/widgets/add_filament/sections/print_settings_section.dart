import 'package:flutter/material.dart';

import '../editable_temperature.dart';
import '../section_card.dart';

class PrintSettingsSection extends StatefulWidget {
  const PrintSettingsSection({
    super.key,
    required this.selectedDiameter,
    required this.diameters,
    required this.nozzleTemp,
    required this.bedTemp,
    required this.onDiameterChanged,
    required this.onNozzleTempChanged,
    required this.onBedTempChanged,
  });

  final double? selectedDiameter;
  final List<double> diameters;
  final int? nozzleTemp;
  final int? bedTemp;
  final ValueChanged<double?> onDiameterChanged;
  final ValueChanged<int?> onNozzleTempChanged;
  final ValueChanged<int?> onBedTempChanged;

  @override
  State<PrintSettingsSection> createState() => _PrintSettingsSectionState();
}

class _PrintSettingsSectionState extends State<PrintSettingsSection> {
  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Druckeinstellungen",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<double>(
            initialValue: widget.selectedDiameter,
            hint: const Text("Durchmesser"),
            items: widget.diameters
                .map((d) => DropdownMenuItem(value: d, child: Text("$d mm")))
                .toList(),
            onChanged: widget.onDiameterChanged,
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Temperaturen",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.02)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: SizedBox(
              height: 120,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  EditableTemperature(
                    title: "Nozzle",
                    value: widget.nozzleTemp,
                    step: 10,
                    onChanged: widget.onNozzleTempChanged,
                  ),
                  EditableTemperature(
                    title: "Bed",
                    value: widget.bedTemp,
                    step: 5,
                    onChanged: widget.onBedTempChanged,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
