import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      title: l10n.inventoryAndCost,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedSpoolWeight,
            decoration: InputDecoration(
  labelText: l10n.spoolWeight,
  suffixText: "g",
),
            items: [
              DropdownMenuItem(
                value: "custom",
                child: Text(
                  selectedSpoolWeight == "custom" &&
                          widget.totalWeightController.text.isNotEmpty
                      ? widget.totalWeightController.text
                      : l10n.custom,
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
                      title: Text(l10n.spoolWeight),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
  hintText: l10n.weightInGrams,
),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, controller.text.trim()),
                          child: Text(l10n.save),
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
            decoration: InputDecoration(
  labelText: l10n.remainingWeight,
  suffixText: "g",
),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: widget.priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
  labelText: l10n.price,
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
              label: Text(l10n.save),
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
