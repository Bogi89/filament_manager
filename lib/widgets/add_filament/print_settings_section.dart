import 'package:flutter/material.dart';

class PrintSettingsSection extends StatelessWidget {
  const PrintSettingsSection({
    super.key,
    required this.selectedDiameter,
    required this.diameters,
    required this.nozzleTemp,
    required this.bedTemp,
    required this.onDiameterChanged,
  });

  final double? selectedDiameter;
  final List<double> diameters;
  final int? nozzleTemp;
  final int? bedTemp;
  final ValueChanged<double?> onDiameterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Druckeinstellungen",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<double>(
            initialValue: selectedDiameter,
            hint: const Text("Durchmesser"),
            items: diameters
                .map((d) => DropdownMenuItem(value: d, child: Text("$d mm")))
                .toList(),
            onChanged: onDiameterChanged,
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              "Temperaturen",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          const SizedBox(height: 12),

          const SizedBox(height: 12),

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
              child: Center(
                child: Text(
                  "Temperaturen",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
