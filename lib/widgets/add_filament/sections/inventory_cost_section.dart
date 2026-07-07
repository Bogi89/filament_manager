import 'package:flutter/material.dart';

import '../section_card.dart';

class InventoryCostSection extends StatefulWidget {
  const InventoryCostSection({
    super.key,
    required this.selectedSpoolWeight,
    required this.totalWeightController,
    required this.remainingWeightController,
    required this.priceController,
    required this.onSave,
    required this.onSpoolWeightChanged,
  });

  final String? selectedSpoolWeight;
  final TextEditingController totalWeightController;
  final TextEditingController remainingWeightController;
  final TextEditingController priceController;
  final VoidCallback onSave;
  final ValueChanged<String?> onSpoolWeightChanged;

  @override
  State<InventoryCostSection> createState() => _InventoryCostSectionState();
}

class _InventoryCostSectionState extends State<InventoryCostSection> {
  late String? selectedSpoolWeight;

  @override
  void initState() {
    super.initState();
    selectedSpoolWeight = widget.selectedSpoolWeight;
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: "Bestand & Kosten",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: selectedSpoolWeight,
            decoration: const InputDecoration(
              labelText: "Spulengewicht",
              suffixText: "g",
            ),
            items: [
              DropdownMenuItem(
                value: "custom",
                child: Text(
                  selectedSpoolWeight == "custom" &&
                          widget.totalWeightController.text.isNotEmpty
                      ? widget.totalWeightController.text
                      : "Benutzerdefiniert...",
                ),
              ),
              const DropdownMenuItem(value: "250", child: Text("250")),
              const DropdownMenuItem(value: "500", child: Text("500")),
              const DropdownMenuItem(value: "800", child: Text("800")),
              const DropdownMenuItem(value: "1000", child: Text("1000")),
              const DropdownMenuItem(value: "2000", child: Text("2000")),
            ],
            onChanged: (value) async {
              if (value == null) return;

              if (value == "custom") {
                final controller = TextEditingController();

                final result = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Spulengewicht"),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Gewicht in g",
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Abbrechen"),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text.trim()),
                          child: const Text("Speichern"),
                        ),
                      ],
                    );
                  },
                );

                if (result != null && result.isNotEmpty) {
                  setState(() {
                    selectedSpoolWeight = "custom";
                    widget.totalWeightController.text = result;
                  });

                  widget.onSpoolWeightChanged("custom");
                }
              } else {
                setState(() {
                  selectedSpoolWeight = value;
                  widget.totalWeightController.text = value;
                });

                widget.onSpoolWeightChanged(value);
              }
            },
          ),

          const SizedBox(height: 16),

          TextField(
            controller: widget.remainingWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Restgewicht",
              suffixText: "g",
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: widget.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: "Preis",
              suffixText: "€",
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: widget.onSave,
              icon: const Icon(Icons.save_rounded),
              label: const Text("Speichern"),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
