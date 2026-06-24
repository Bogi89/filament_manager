import 'package:flutter/material.dart';

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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),

        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bestand & Kosten",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          DropdownButtonFormField<String>(
            value: this.selectedSpoolWeight,
            decoration: const InputDecoration(
              labelText: "Spulengewicht",
              suffixText: "g",
            ),
            items: [
              DropdownMenuItem(
                value: "custom",
                child: Text(
                  this.selectedSpoolWeight == "custom" &&
                          widget.totalWeightController.text.isNotEmpty
                      ? widget.totalWeightController.text
                      : "Benutzerdefiniert...",
                ),
              ),
              DropdownMenuItem(value: "250", child: Text("250")),
              DropdownMenuItem(value: "500", child: Text("500")),
              DropdownMenuItem(value: "800", child: Text("800")),
              DropdownMenuItem(value: "1000", child: Text("1000")),
              DropdownMenuItem(value: "2000", child: Text("2000")),
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
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text("Abbrechen"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, controller.text.trim());
                          },
                          child: const Text("Speichern"),
                        ),
                      ],
                    );
                  },
                );

                if (result != null && result.isNotEmpty) {
                  setState(() {
                    this.selectedSpoolWeight = "custom";
                    widget.totalWeightController.text = result;
                  });

                  widget.onSpoolWeightChanged("custom");
                }
              } else {
                setState(() {
                  this.selectedSpoolWeight = value;
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
