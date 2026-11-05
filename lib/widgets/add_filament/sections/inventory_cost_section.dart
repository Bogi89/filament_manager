import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../section_card.dart';

/// Unsaved input for one additional physical spool.
class AdditionalSpoolInput {
  const AdditionalSpoolInput({
    required this.totalWeight,
    required this.remainingWeight,
    required this.price,
    required this.storageLocation,
    required this.storagePosition,
  });

  final String totalWeight;
  final String remainingWeight;
  final String price;
  final String storageLocation;
  final String storagePosition;
}

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
    required this.onAdditionalSpoolsChanged,
  });

  final String? selectedSpoolWeight;
  final TextEditingController totalWeightController;
  final TextEditingController remainingWeightController;
  final TextEditingController priceController;
  final TextEditingController storageLocationController;
  final TextEditingController storagePositionController;
  final VoidCallback onSave;
  final ValueChanged<String?> onSpoolWeightChanged;
  final ValueChanged<List<AdditionalSpoolInput>> onAdditionalSpoolsChanged;

  @override
  State<InventoryCostSection> createState() => _InventoryCostSectionState();
}

class _AdditionalSpoolControllers {
  final total = TextEditingController();
  final remaining = TextEditingController();
  final price = TextEditingController();
  final location = TextEditingController();
  final position = TextEditingController();

  void dispose() {
    total.dispose();
    remaining.dispose();
    price.dispose();
    location.dispose();
    position.dispose();
  }

  AdditionalSpoolInput get value => AdditionalSpoolInput(
    totalWeight: total.text,
    remainingWeight: remaining.text,
    price: price.text,
    storageLocation: location.text,
    storagePosition: position.text,
  );
}

class _InventoryCostSectionState extends State<InventoryCostSection> {
  late String? selectedSpoolWeight;
  bool multipleSpools = false;
  final List<_AdditionalSpoolControllers> additional = [];

  @override
  void initState() {
    super.initState();
    selectedSpoolWeight = widget.selectedSpoolWeight;
  }

  @override
  void didUpdateWidget(covariant InventoryCostSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSpoolWeight != widget.selectedSpoolWeight) {
      selectedSpoolWeight = widget.selectedSpoolWeight;
    }
  }

  @override
  void dispose() {
    for (final spool in additional) {
      spool.dispose();
    }
    super.dispose();
  }

  void _notify() {
    widget.onAdditionalSpoolsChanged(
      additional.map((spool) => spool.value).toList(growable: false),
    );
  }

  void _addSpool() {
    final spool = _AdditionalSpoolControllers();
    for (final controller in [
      spool.total,
      spool.remaining,
      spool.price,
      spool.location,
      spool.position,
    ]) {
      controller.addListener(_notify);
    }
    setState(() => additional.add(spool));
    _notify();
  }

  void _removeSpool(int index) {
    final spool = additional[index];
    setState(() => additional.removeAt(index));
    for (final controller in [
      spool.total,
      spool.remaining,
      spool.price,
      spool.location,
      spool.position,
    ]) {
      controller.removeListener(_notify);
    }
    spool.dispose();
    _notify();
  }

  void _toggleMultiple(bool enabled) {
    setState(() => multipleSpools = enabled);
    if (enabled && additional.isEmpty) {
      _addSpool();
    } else if (!enabled) {
      while (additional.isNotEmpty) {
        _removeSpool(additional.length - 1);
      }
      _notify();
    }
  }

  String _label(BuildContext context, String de, String en) =>
      Localizations.localeOf(context).languageCode == 'de' ? de : en;

  Widget _weightField(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      key: ValueKey(selectedSpoolWeight),
      initialValue: selectedSpoolWeight,
      decoration: InputDecoration(
        labelText: l10n.spoolWeight,
        suffixText: 'g',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: [
        DropdownMenuItem(
          value: 'custom',
          child: Text(selectedSpoolWeight == 'custom' &&
                  widget.totalWeightController.text.isNotEmpty
              ? widget.totalWeightController.text
              : l10n.custom),
        ),
        for (final value in ['250', '500', '800', '1000', '2000'])
          DropdownMenuItem(value: value, child: Text(value)),
      ],
      onChanged: (value) async {
        if (value == null) return;
        if (value == 'custom') {
          final controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.spoolWeight),
              content: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(hintText: l10n.weightInGrams),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
                  child: Text(l10n.save),
                ),
              ],
            ),
          );
          controller.dispose();
          if (!mounted || result == null || result.isEmpty) return;
          final number = double.tryParse(result.replaceAll(',', '.'));
          if (number == null || !number.isFinite || number <= 0) return;
          setState(() {
            selectedSpoolWeight = 'custom';
            widget.totalWeightController.text = result;
          });
          widget.onSpoolWeightChanged('custom');
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

  Widget _field(TextEditingController controller, String label, {
    String? suffix,
    bool numeric = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(labelText: label, suffixText: suffix, isDense: true),
    );
  }

  Widget _additionalSpoolCard(int index) {
    final spool = additional[index];
    return Card(
      key: ObjectKey(spool),
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_label(context, 'Spule', 'Spool')} ${index + 2}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: _label(context, 'Spule entfernen', 'Remove spool'),
                  onPressed: () => _removeSpool(index),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              final fields = [
                _field(spool.total, _label(context, 'Spulengewicht', 'Spool weight'),
                    suffix: 'g', numeric: true),
                _field(spool.remaining, _label(context, 'Restgewicht', 'Remaining weight'),
                    suffix: 'g', numeric: true),
                _field(spool.price, _label(context, 'Eigener Preis (optional)', 'Own price (optional)'),
                    suffix: '€', numeric: true),
                _field(spool.location, _label(context, 'Lagerort', 'Storage location')),
                _field(spool.position, _label(context, 'Lagerposition', 'Storage position')),
              ];
              if (constraints.maxWidth < 550) {
                return Column(children: [
                  for (final field in fields) ...[field, const SizedBox(height: 12)],
                ]);
              }
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final field in fields)
                    SizedBox(width: (constraints.maxWidth - 12) / 2, child: field),
                ],
              );
            }),
            const SizedBox(height: 4),
            Text(
              _label(context,
                  'Ohne eigenen Preis gilt der Preis der ersten Spule.',
                  'If empty, the first spool price applies.'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SectionCard(
      title: l10n.inventoryAndCost,
      child: LayoutBuilder(builder: (context, constraints) {
        final wide = constraints.maxWidth >= 700;
        final fields = <Widget>[
          _weightField(l10n),
          _field(widget.remainingWeightController, l10n.remainingWeight,
              suffix: 'g', numeric: true),
          _field(widget.priceController, l10n.price, suffix: '€', numeric: true),
          _field(widget.storageLocationController, l10n.storageLocation),
          _field(widget.storagePositionController, l10n.storagePosition),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (wide)
              Wrap(
                spacing: 20,
                runSpacing: 16,
                children: [
                  for (final field in fields)
                    SizedBox(width: (constraints.maxWidth - 20) / 2, child: field),
                ],
              )
            else
              for (final field in fields) ...[
                field,
                const SizedBox(height: 16),
              ],
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(_label(context, 'Mehrere Spulen anlegen', 'Add multiple spools')),
              value: multipleSpools,
              onChanged: (value) => _toggleMultiple(value ?? false),
            ),
            if (multipleSpools) ...[
              for (var i = 0; i < additional.length; i++) _additionalSpoolCard(i),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addSpool,
                icon: const Icon(Icons.add),
                label: Text(_label(context, 'Weitere Spule hinzufügen', 'Add another spool')),
              ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
