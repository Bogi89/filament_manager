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
    required this.storageLocationController,
    required this.storagePositionController,
    required this.onSave,
    required this.onSpoolWeightChanged,
  });

  final String? selectedSpoolWeight;
  final TextEditingController totalWeightController;
  final TextEditingController remainingWeightController;
  final TextEditingController priceController;
  final TextEditingController storageLocationController;
  final TextEditingController storagePositionController;
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

  Widget _buildSpoolWeightField(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: selectedSpoolWeight,
      decoration: InputDecoration(
        labelText: l10n.spoolWeight,
        suffixText: 'g',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: 'custom',
          child: Text(
            selectedSpoolWeight == 'custom' &&
                    widget.totalWeightController.text.isNotEmpty
                ? widget.totalWeightController.text
                : l10n.custom,
          ),
        ),
        const DropdownMenuItem(value: '250', child: Text('250')),
        const DropdownMenuItem(value: '500', child: Text('500')),
        const DropdownMenuItem(value: '800', child: Text('800')),
        const DropdownMenuItem(value: '1000', child: Text('1000')),
        const DropdownMenuItem(value: '2000', child: Text('2000')),
      ],
      onChanged: (value) async {
        if (value == null) {
          return;
        }

        if (value == 'custom') {
          final controller = TextEditingController();

          final result = await showDialog<String>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(l10n.spoolWeight),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(hintText: l10n.weightInGrams),
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
              selectedSpoolWeight = 'custom';
              widget.totalWeightController.text = result;
            });

            widget.onSpoolWeightChanged('custom');
          }
        } else {
          setState(() {
            selectedSpoolWeight = value;
            widget.totalWeightController.text = value;
          });

          widget.onSpoolWeightChanged(value);
        }
      },
    );
  }

  Widget _buildRemainingWeightField(AppLocalizations l10n) {
    return TextField(
      controller: widget.remainingWeightController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: l10n.remainingWeight,
        suffixText: 'g',
        isDense: true,
      ),
    );
  }

  Widget _buildPriceField(AppLocalizations l10n) {
    return TextField(
      controller: widget.priceController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: l10n.price,
        suffixText: '€',
        isDense: true,
      ),
    );
  }

  Widget _buildStorageLocationField(AppLocalizations l10n) {
    return TextField(
      controller: widget.storageLocationController,
      decoration: InputDecoration(
        labelText: l10n.storageLocation,
        suffixText: ' ',
      ),
    );
  }

  Widget _buildStoragePositionField(AppLocalizations l10n) {
    return TextField(
      controller: widget.storagePositionController,
      decoration: InputDecoration(
        labelText: l10n.storagePosition,
        suffixText: ' ',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      title: l10n.inventoryAndCost,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useTwoColumns = constraints.maxWidth >= 700;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (useTwoColumns) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildSpoolWeightField(l10n)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildStorageLocationField(l10n)),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildRemainingWeightField(l10n)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildStoragePositionField(l10n)),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPriceField(l10n)),
                    const SizedBox(width: 20),
                    const Expanded(child: SizedBox()),
                  ],
                ),
              ] else ...[
                _buildSpoolWeightField(l10n),

                const SizedBox(height: 16),

                _buildRemainingWeightField(l10n),

                const SizedBox(height: 16),

                _buildPriceField(l10n),

                const SizedBox(height: 16),

                _buildStorageLocationField(l10n),

                const SizedBox(height: 16),

                _buildStoragePositionField(l10n),
              ],

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
          );
        },
      ),
    );
  }
}
