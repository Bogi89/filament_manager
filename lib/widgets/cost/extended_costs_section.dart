import 'package:flutter/material.dart';

import '../../models/extended_costs.dart';

class ExtendedCostsSection extends StatelessWidget {
  final ExtendedCosts settings;
  final ValueChanged<ExtendedCosts> onChanged;

  const ExtendedCostsSection({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  bool _isGerman(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'de';
  }

  String _text(BuildContext context, String german, String english) {
    return _isGerman(context) ? german : english;
  }

  String _title(BuildContext context, ExtendedCostType type) {
    final german = _isGerman(context);

    switch (type) {
      case ExtendedCostType.printerDepreciation:
        return german ? 'Druckerabschreibung' : 'Printer depreciation';
      case ExtendedCostType.maintenance:
        return german ? 'Wartung' : 'Maintenance';
      case ExtendedCostType.additionalWear:
        return german ? 'Zusätzlicher Verschleiß' : 'Additional wear';
      case ExtendedCostType.preparation:
        return german ? 'Vorbereitung' : 'Preparation';
      case ExtendedCostType.postProcessing:
        return german ? 'Nachbearbeitung' : 'Post-processing';
      case ExtendedCostType.packagingWork:
        return german ? 'Verpackungsarbeit' : 'Packaging labor';
      case ExtendedCostType.failedPrint:
        return german ? 'Fehldruckzuschlag' : 'Failed print allowance';
      case ExtendedCostType.supportAndWaste:
        return german ? 'Support und Ausschuss' : 'Support and waste';
      case ExtendedCostType.additionalMaterials:
        return german ? 'Zusatzmaterialien' : 'Additional materials';
      case ExtendedCostType.packagingAndShipping:
        return german ? 'Verpackung und Versand' : 'Packaging and shipping';
      case ExtendedCostType.overhead:
        return german ? 'Gemeinkosten' : 'Overhead';
      case ExtendedCostType.profitMarkup:
        return german ? 'Gewinnaufschlag' : 'Profit markup';
      case ExtendedCostType.platformFees:
        return german ? 'Plattformgebühren' : 'Platform fees';
      case ExtendedCostType.vat:
        return german ? 'Mehrwertsteuer' : 'VAT';
    }
  }

  String _description(BuildContext context, ExtendedCostType type) {
    final german = _isGerman(context);

    switch (type) {
      case ExtendedCostType.printerDepreciation:
        return german
            ? 'Verteilt den Anschaffungspreis des Druckers auf seine '
                  'voraussichtliche Nutzungsdauer. Die Druckkosten ergeben '
                  'sich anteilig aus der Druckzeit.'
            : 'Distributes the printer purchase price over its expected '
                  'operating lifetime. The print receives a proportional '
                  'share based on printing time.';

      case ExtendedCostType.maintenance:
        return german
            ? 'Berücksichtigt regelmäßige Wartungskosten pro '
                  'Betriebsstunde, beispielsweise Reinigung und Service.'
            : 'Accounts for recurring maintenance expenses per '
                  'operating hour, such as cleaning and servicing.';

      case ExtendedCostType.additionalWear:
        return german
            ? 'Zusätzliche Verschleißkosten pro Druckstunde, etwa für '
                  'Düsen, Druckbettoberflächen oder andere Ersatzteile. '
                  'Nicht zusätzlich als Wartung erfassen.'
            : 'Additional wear expenses per printing hour, such as '
                  'nozzles, build surfaces or replacement parts. '
                  'Do not also include them in maintenance.';

      case ExtendedCostType.preparation:
        return german
            ? 'Arbeitszeit für die Vorbereitung des Drucks, '
                  'beispielsweise Slicer-Einstellungen und Einrichtung.'
            : 'Labor spent preparing the print, such as slicer '
                  'configuration and printer setup.';

      case ExtendedCostType.postProcessing:
        return german
            ? 'Arbeitszeit nach dem Druck, beispielsweise Entfernen '
                  'von Stützstrukturen, Schleifen und Reinigen.'
            : 'Labor after printing, such as support removal, '
                  'sanding and cleaning.';

      case ExtendedCostType.packagingWork:
        return german
            ? 'Arbeitszeit für das Verpacken. Verpackungsmaterial '
                  'wird separat bei Verpackung und Versand erfasst.'
            : 'Labor required for packaging. Packaging materials '
                  'are accounted for separately under packaging and shipping.';

      case ExtendedCostType.failedPrint:
        return german
            ? 'Prozentualer Risikozuschlag auf die ursprünglichen '
                  'Filament- und Stromkosten für mögliche Fehldrucke.'
            : 'Percentage-based risk allowance on the original '
                  'filament and electricity costs for possible failed prints.';

      case ExtendedCostType.supportAndWaste:
        return german
            ? 'Zusätzliches Filament für Support oder Ausschuss. '
                  'Nur Mengen eintragen, die noch nicht im Objektgewicht '
                  'enthalten sind, damit nichts doppelt berechnet wird.'
            : 'Extra filament for supports or waste. Only enter '
                  'amounts not already included in the object weight '
                  'to prevent double counting.';

      case ExtendedCostType.additionalMaterials:
        return german
            ? 'Zusätzliche Verbrauchsmaterialien wie Klebstoff, '
                  'Magnete, Schrauben oder Einlegeteile.'
            : 'Additional consumables such as adhesive, magnets, '
                  'screws or inserts.';

      case ExtendedCostType.packagingAndShipping:
        return german
            ? 'Materialkosten für Kartons und Füllmaterial sowie '
                  'Versandkosten. Arbeitszeit separat erfassen.'
            : 'Costs of boxes, packing materials and shipping. '
                  'Enter packaging labor separately.';

      case ExtendedCostType.overhead:
        return german
            ? 'Sonstige anteilige Betriebskosten, die bisher '
                  'nicht berücksichtigt wurden.'
            : 'Other allocated operating expenses that have '
                  'not already been accounted for.';

      case ExtendedCostType.profitMarkup:
        return german
            ? 'Gewünschter Gewinnaufschlag auf die Produktionskosten. '
                  'Der Verkaufspreis wird getrennt von den '
                  'Herstellungskosten ausgewiesen.'
            : 'Desired profit markup on production costs. '
                  'The selling price is shown separately '
                  'from manufacturing costs.';

      case ExtendedCostType.platformFees:
        return german
            ? 'Prozentuale und feste Verkaufsgebühren, zum Beispiel '
                  'für einen Marktplatz oder Zahlungsanbieter. '
                  'Die prozentuale Gebühr wird auf den '
                  'Bruttoverkaufspreis angewendet.'
            : 'Percentage and fixed sales fees, such as marketplace '
                  'or payment processing charges. Percentage fees '
                  'are applied to the gross selling price.';

      case ExtendedCostType.vat:
        return german
            ? 'Mehrwertsteuersatz für die Verkaufspreisberechnung. '
                  'Nur verwenden, wenn die Steuer für den '
                  'jeweiligen Verkauf anzusetzen ist.'
            : 'VAT rate for calculating the selling price. '
                  'Use only when VAT applies to the sale.';
    }
  }

  List<_CostInputDefinition> _fields(
    BuildContext context,
    ExtendedCostType type,
  ) {
    String label(String german, String english) {
      return _text(context, german, english);
    }

    switch (type) {
      case ExtendedCostType.printerDepreciation:
        return [
          _CostInputDefinition(
            'printerPurchasePrice',
            label('Druckerpreis (€)', 'Printer price (€)'),
          ),
          _CostInputDefinition(
            'printerLifetimeHours',
            label('Nutzungsdauer (h)', 'Lifetime (h)'),
          ),
        ];

      case ExtendedCostType.maintenance:
        return [
          _CostInputDefinition(
            'maintenancePerHour',
            label('Wartung (€/h)', 'Maintenance (€/h)'),
          ),
        ];

      case ExtendedCostType.additionalWear:
        return [
          _CostInputDefinition(
            'additionalWearPerHour',
            label('Verschleiß (€/h)', 'Wear (€/h)'),
          ),
        ];

      case ExtendedCostType.preparation:
        return [
          _CostInputDefinition(
            'preparationMinutes',
            label('Arbeitszeit (Min.)', 'Labor time (min)'),
          ),
          _CostInputDefinition(
            'preparationHourlyRate',
            label('Stundensatz (€/h)', 'Hourly rate (€/h)'),
          ),
        ];

      case ExtendedCostType.postProcessing:
        return [
          _CostInputDefinition(
            'postProcessingMinutes',
            label('Arbeitszeit (Min.)', 'Labor time (min)'),
          ),
          _CostInputDefinition(
            'postProcessingHourlyRate',
            label('Stundensatz (€/h)', 'Hourly rate (€/h)'),
          ),
        ];

      case ExtendedCostType.packagingWork:
        return [
          _CostInputDefinition(
            'packagingWorkMinutes',
            label('Arbeitszeit (Min.)', 'Labor time (min)'),
          ),
          _CostInputDefinition(
            'packagingWorkHourlyRate',
            label('Stundensatz (€/h)', 'Hourly rate (€/h)'),
          ),
        ];

      case ExtendedCostType.failedPrint:
        return [
          _CostInputDefinition(
            'failedPrintPercent',
            label('Risikozuschlag (%)', 'Risk allowance (%)'),
          ),
        ];

      case ExtendedCostType.supportAndWaste:
        return [
          _CostInputDefinition(
            'additionalWasteGrams',
            label('Zusatzgewicht (g)', 'Extra weight (g)'),
          ),
          _CostInputDefinition(
            'additionalWastePercent',
            label('Zusätzlicher Anteil (%)', 'Additional share (%)'),
          ),
        ];

      case ExtendedCostType.additionalMaterials:
        return [
          _CostInputDefinition(
            'additionalMaterialsCost',
            label('Materialkosten (€)', 'Material cost (€)'),
          ),
        ];

      case ExtendedCostType.packagingAndShipping:
        return [
          _CostInputDefinition(
            'packagingCost',
            label('Verpackung (€)', 'Packaging (€)'),
          ),
          _CostInputDefinition(
            'shippingCost',
            label('Versand (€)', 'Shipping (€)'),
          ),
        ];

      case ExtendedCostType.overhead:
        return [
          _CostInputDefinition(
            'overheadCost',
            label('Gemeinkosten (€)', 'Overhead (€)'),
          ),
        ];

      case ExtendedCostType.profitMarkup:
        return [
          _CostInputDefinition(
            'profitMarkupPercent',
            label('Gewinnaufschlag (%)', 'Profit markup (%)'),
          ),
        ];

      case ExtendedCostType.platformFees:
        return [
          _CostInputDefinition(
            'platformFeePercent',
            label('Plattformgebühr (%)', 'Platform fee (%)'),
          ),
          _CostInputDefinition(
            'platformFixedFee',
            label('Feste Gebühr (€)', 'Fixed fee (€)'),
          ),
        ];

      case ExtendedCostType.vat:
        return [
          _CostInputDefinition(
            'vatPercent',
            label('Mehrwertsteuer (%)', 'VAT (%)'),
          ),
        ];
    }
  }

  void _toggleEnabled(bool enabled) {
    onChanged(settings.copyWith(enabled: enabled));
  }

  void _toggleType(ExtendedCostType type, bool selected) {
    final updated = Set<ExtendedCostType>.from(settings.selected);

    if (selected) {
      updated.add(type);
    } else {
      updated.remove(type);
    }

    onChanged(settings.copyWith(selected: updated));
  }

  void _updateValue(String key, double value) {
    final updated = Map<String, double>.from(settings.values);
    updated[key] = value;

    onChanged(settings.copyWith(values: updated));
  }

  void _showInfo(BuildContext context, ExtendedCostType type) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_title(context, type)),
          content: Text(_description(context, type)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(_text(context, 'Schließen', 'Close')),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInput(BuildContext context, _CostInputDefinition definition) {
    return _ExtendedCostNumberField(
      key: ValueKey(definition.key),
      label: definition.label,
      value: settings.value(definition.key),
      onChanged: (value) => _updateValue(definition.key, value),
    );
  }

  Widget _buildCostCard(BuildContext context, ExtendedCostType type) {
    final selected = settings.selected.contains(type);
    final fields = _fields(context, type);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: selected,
                onChanged: (value) {
                  _toggleType(type, value ?? false);
                },
              ),
              Expanded(
                child: InkWell(
                  onTap: () => _toggleType(type, !selected),
                  child: Text(
                    _title(context, type),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              IconButton(
                tooltip: _text(context, 'Informationen', 'Information'),
                onPressed: () => _showInfo(context, type),
                icon: const Icon(Icons.info_outline),
              ),
            ],
          ),
          if (selected) ...[
            const SizedBox(height: 10),
            for (final definition in fields) ...[
              _buildInput(context, definition),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGerman = _isGerman(context);

    final productionTypes = ExtendedCostType.values
        .where((type) => !type.isSellingCost)
        .toList();

    final sellingTypes = ExtendedCostType.values
        .where((type) => type.isSellingCost)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              isGerman
                  ? 'Erweiterte Kostenberechnung'
                  : 'Extended cost calculation',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              isGerman
                  ? 'Zusätzliche Kosten und Verkaufspreise berechnen'
                  : 'Calculate additional costs and selling prices',
            ),
            value: settings.enabled,
            onChanged: _toggleEnabled,
          ),
          if (settings.enabled) ...[
            const SizedBox(height: 20),
            Text(
              isGerman ? 'Produktionskosten' : 'Production costs',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildResponsiveGrid(context, productionTypes),
            const SizedBox(height: 24),
            Text(
              isGerman ? 'Verkauf und Gewinn' : 'Sales and profit',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isGerman
                  ? 'Diese Positionen beeinflussen den Verkaufspreis, '
                        'nicht die Produktionskosten.'
                  : 'These items affect the selling price, '
                        'not the production costs.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _buildResponsiveGrid(context, sellingTypes),
          ],
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(
    BuildContext context,
    List<ExtendedCostType> types,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 700;

        if (!twoColumns) {
          return Column(
            children: [
              for (final type in types) ...[
                _buildCostCard(context, type),
                const SizedBox(height: 12),
              ],
            ],
          );
        }

        final left = <ExtendedCostType>[];
        final right = <ExtendedCostType>[];

        for (var i = 0; i < types.length; i++) {
          if (i.isEven) {
            left.add(types[i]);
          } else {
            right.add(types[i]);
          }
        }

        Widget column(List<ExtendedCostType> items) {
          return Column(
            children: [
              for (final type in items) ...[
                _buildCostCard(context, type),
                const SizedBox(height: 12),
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: column(left)),
            const SizedBox(width: 16),
            Expanded(child: column(right)),
          ],
        );
      },
    );
  }
}

class _CostInputDefinition {
  final String key;
  final String label;

  const _CostInputDefinition(this.key, this.label);
}

class _ExtendedCostNumberField extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _ExtendedCostNumberField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_ExtendedCostNumberField> createState() =>
      _ExtendedCostNumberFieldState();
}

class _ExtendedCostNumberFieldState extends State<_ExtendedCostNumberField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.value == 0 ? '' : widget.value.toString(),
    );

    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant _ExtendedCostNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!_focusNode.hasFocus && oldWidget.value != widget.value) {
      _controller.text = widget.value == 0 ? '' : widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String text) {
    final value = double.tryParse(text.replaceAll(',', '.'));

    if (value == null || !value.isFinite || value < 0) {
      widget.onChanged(0);
      return;
    }

    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _handleChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
