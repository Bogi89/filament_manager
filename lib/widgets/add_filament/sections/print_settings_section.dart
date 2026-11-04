import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../editable_temperature.dart';
import '../section_card.dart';

class PrintSettingsSection extends StatefulWidget {
  const PrintSettingsSection({
    super.key,
    required this.selectedDiameter,
    required this.diameters,
    this.density,
    this.onDensityChanged,
    required this.nozzleTemp,
    required this.bedTemp,
    required this.onDiameterChanged,
    required this.onNozzleTempChanged,
    required this.onBedTempChanged,
  });

  final double? selectedDiameter;
  final List<double> diameters;

  /// Optionale Materialdichte in g/cm³.
  final double? density;
  final ValueChanged<double?>? onDensityChanged;

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
    final l10n = AppLocalizations.of(context)!;

    return SectionCard(
      title: l10n.printSettings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 500;

              final diameterField = DropdownButtonFormField<double>(
                initialValue: widget.selectedDiameter,
                hint: Text(l10n.diameter),
                items: widget.diameters
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text('$d mm')),
                    )
                    .toList(),
                onChanged: widget.onDiameterChanged,
              );

              final densityField = TextFormField(
                key: ValueKey(widget.density),
                initialValue: widget.density?.toString() ?? '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: l10n.materialDensity,
                  hintText: l10n.optional,
                ),
                onChanged: (text) {
                  final value = double.tryParse(
                    text.trim().replaceAll(',', '.'),
                  );

                  widget.onDensityChanged?.call(
                    value != null && value > 0 ? value : null,
                  );
                },
              );

              if (isCompact) {
                return Column(
                  children: [
                    diameterField,
                    const SizedBox(height: 16),
                    densityField,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: diameterField),
                  const SizedBox(width: 16),
                  Expanded(child: densityField),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              l10n.temperatures,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 500;

              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 8 : 20,
                  vertical: isCompact ? 12 : 16,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.02)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: SizedBox(
                  height: isCompact ? 96 : 120,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: EditableTemperature(
                            title: l10n.nozzle,
                            value: widget.nozzleTemp,
                            step: 10,
                            onChanged: widget.onNozzleTempChanged,
                            compact: isCompact,
                          ),
                        ),
                      ),

                      if (isCompact)
                        Container(
                          width: 1,
                          height: 60,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: 0.35),
                        ),

                      Expanded(
                        child: Center(
                          child: EditableTemperature(
                            title: l10n.bed,
                            value: widget.bedTemp,
                            step: 5,
                            onChanged: widget.onBedTempChanged,
                            compact: isCompact,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
