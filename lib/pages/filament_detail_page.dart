import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../models/filament_color.dart';
import '../models/spool.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/filament_catalog_service.dart';
import '../services/custom_color_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/color_name_localizer.dart';
import '../widgets/add_filament/sections/print_settings_section.dart';
import '../services/material_temperature_service.dart';

class FilamentDetailPage extends StatefulWidget {
  final Filament filament;

  const FilamentDetailPage({super.key, required this.filament});

  @override
  State<FilamentDetailPage> createState() => _FilamentDetailPageState();
}

class _FilamentDetailPageState extends State<FilamentDetailPage> {
  final List<String> brands = [
    "Bambu Lab",
    "Prusament",
    "Soleyin",
    "eSun",
    "Sunlu",
  ];

  List<String> materials = [];

  final List<double> diameters = [1.75, 2.85, 3.0];

  final Map<String, List<String>> variantsByMaterial = {
    "PLA": ["Basic", "Standard", "Ultra", "Silk", "Matt", "Tough"],

    "PETG": ["Basic", "Standard", "Carbon"],

    "ABS": ["Basic", "Standard"],

    "TPU": ["Flex 95A"],
  };

  String? selectedBrand;
  String? selectedMaterial;
  String? selectedVariant;
  String? selectedColor;
  double? selectedDiameter;

  // Optionale Materialdichte in g/cm³.
  double? selectedDensity;

  // Schützt gespeicherte und manuell geänderte Dichtewerte.
  bool densityManuallyEdited = false;

  List<String> colorNamesList = [];

  final Map<String, Color> customColorMap = {};

  int? nozzleTemp;
  int? bedTemp;

  late final List<Spool> _editingSpools;
  late final Set<String> _originalSpoolIds;
  double _addedSpoolWeight = 0;

  double get _remainingSpoolWeight =>
      _editingSpools.fold(0.0, (sum, spool) => sum + spool.weight);

  double get _totalSpoolPrice => _editingSpools.fold(
    0.0,
    (sum, spool) => sum + spool.effectivePrice(widget.filament.price),
  );

  String _formatWeight(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);

  String _formatPrice(double value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');

  double? _parseAmount(String input) =>
      double.tryParse(input.trim().replaceAll(',', '.'));

  @override
  void initState() {
    super.initState();

    _loadCustomColors();

    final f = widget.filament;
    _originalSpoolIds = f.spools.map((spool) => spool.id).toSet();
    _editingSpools = f.spools
        .map(
          (spool) => Spool(
            id: spool.id,
            weight: spool.weight,
            price: spool.price,
            storageLocation: spool.storageLocation,
            storagePosition: spool.storagePosition,
          ),
        )
        .toList();

    selectedColor = f.colorNames.isNotEmpty ? f.colorNames.join(' + ') : null;

    colorNamesList = FilamentCatalogService.getColors(
      f.brand,
      f.material,
      f.variant,
    );

    if (selectedColor != null && !colorNamesList.contains(selectedColor)) {
      colorNamesList.add(selectedColor!);
    }

    /// 🔴 WICHTIG: Werte absichern

    /// Hersteller sicherstellen

    if (!brands.contains(f.brand)) {
      brands.add(f.brand);
    }

    selectedBrand = f.brand;

    materials = FilamentCatalogService.getMaterials(f.brand);

    if (!materials.contains(f.material)) {
      materials.add(f.material);
    }

    selectedMaterial = f.material;

    if (!materials.contains(f.material)) {
      materials.add(f.material);
    }

    selectedDiameter = diameters.contains(f.diameter) ? f.diameter : null;

    // Bereits gespeicherte Materialdichte übernehmen.
    selectedDensity = f.density;

    // Gespeicherte Werte vor automatischen Vorschlägen schützen.
    densityManuallyEdited = f.density != null;

    selectedVariant = f.variant;

    nozzleTemp = f.nozzleTemp;
    bedTemp = f.bedTemp;

    /// Varianten aus dem Katalog laden.
    /// Bereits gespeicherte Varianten bleiben erhalten.

    if (selectedMaterial != null && selectedBrand != null) {
      final variants = FilamentCatalogService.getVariants(
        selectedBrand!,
        selectedMaterial!,
      );

      if (selectedVariant != null && !variants.contains(selectedVariant)) {
        variants.add(selectedVariant!);
      }

      variantsByMaterial[selectedMaterial!] = variants;
    }
  }

  Future<void> _loadCustomColors() async {
    final customColors = await CustomColorService.loadCustomColors();

    if (!mounted) return;

    final loadedColors = <String, Color>{};

    for (final entry in customColors) {
      final name = entry['name']?.toString().trim();
      final hex = entry['hex']?.toString().replaceAll('#', '').trim();

      if (name == null || name.isEmpty || hex == null) {
        continue;
      }

      if (hex.length != 6 && hex.length != 8) {
        continue;
      }

      try {
        final normalized = hex.length == 6 ? 'FF$hex' : hex;

        loadedColors[name.toLowerCase()] = Color(
          int.parse(normalized, radix: 16),
        );
      } catch (_) {
        // Ungültige HEX-Werte nicht übernehmen.
      }
    }

    setState(() {
      customColorMap
        ..clear()
        ..addAll(loadedColors);
    });
  }

  void updateDensityFromCatalog() {
    if (densityManuallyEdited) return;

    final brand = selectedBrand;
    final material = selectedMaterial;
    final variant = selectedVariant;

    if (brand == null || material == null || variant == null) {
      selectedDensity = null;
      return;
    }

    selectedDensity = FilamentCatalogService.getDensity(
      brand,
      material,
      variant,
    );
  }

  void _onMaterialChanged(String material) {
    final temperatures = MaterialTemperatureService.getTemperatures(material);

    final variants = selectedBrand == null
        ? <String>[]
        : FilamentCatalogService.getVariants(selectedBrand!, material);

    setState(() {
      selectedMaterial = material;
      selectedVariant = null;
      selectedColor = null;

      // Automatische Dichte bei Materialwechsel aktualisieren.
      // Gespeicherte und manuelle Werte bleiben geschützt.
      updateDensityFromCatalog();

      variantsByMaterial[material] = variants;
      colorNamesList = [];

      nozzleTemp = temperatures?.nozzle;
      bedTemp = temperatures?.bed;
    });
  }

  Widget temperatureSelector(
    String label,
    int? value,
    Function(int) onChanged,
    int step,
  ) {
    if (value == null) {
      return Text(AppLocalizations.of(context)!.selectMaterial);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(label),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => onChanged(value - step),
              ),

              Text(
                "$value °C",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => onChanged(value + step),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void save() {
    final appState = context.read<AppState>();

    final f = widget.filament;

    /// Basisdaten speichern

    f.brand = selectedBrand ?? f.brand;

    f.material = selectedMaterial ?? f.material;

    f.variant = selectedVariant ?? f.variant;

    f.diameter = selectedDiameter ?? f.diameter;

    // Optionale Materialdichte speichern.
    // Auch das Entfernen eines vorhandenen Wertes ist erlaubt.
    f.density = selectedDensity;

    f.nozzleTemp = nozzleTemp ?? f.nozzleTemp;

    f.bedTemp = bedTemp ?? f.bedTemp;

    // Die Spulen werden erst beim abschließenden Speichern übernommen.
    f.spools = List<Spool>.from(_editingSpools);
    f.totalWeight += _addedSpoolWeight;
    f.remainingWeight = _remainingSpoolWeight;
    // Vorhandene Gesamtgewichte nicht beim Bearbeiten verkleinern.
    if (f.totalWeight < f.remainingWeight) {
      f.totalWeight = f.remainingWeight;
    }

    if (selectedColor != null &&
        selectedColor != widget.filament.colorNames.join(' + ') &&
        selectedBrand != null &&
        selectedMaterial != null &&
        selectedVariant != null) {
      final colorName = selectedColor!.trim();

      final catalogColors = FilamentCatalogService.tryGetColorsFromHex(
        selectedBrand!,
        selectedMaterial!,
        selectedVariant!,
        colorName,
      );

      final customColor = customColorMap[colorName.toLowerCase()];

      final List<Color> resolvedColors =
          catalogColors ??
          (customColor != null ? <Color>[customColor] : <Color>[]);

      if (resolvedColors.isNotEmpty) {
        f.colorNames = [colorName];
        f.colors = resolvedColors;
        f.color = resolvedColors.first;
        f.colorType = resolvedColors.length > 1 ? 'multi' : 'single';

        f.filamentColors = resolvedColors.map((color) {
          final hex = color.toARGB32().toRadixString(16).padLeft(8, '0');

          return FilamentColor(
            name: colorName,
            hex: '#${hex.substring(2).toUpperCase()}',
            isCustom: catalogColors == null,
          );
        }).toList();
      }
    }

    /// 🔥 FILAMENT SPEICHERN
    appState.updateFilament(f, previousSpoolIds: _originalSpoolIds);

    Navigator.pop(context);
  }

  Widget _summaryTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final filament = widget.filament;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editFilament)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),

            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filament.color,
                      ),
                      child: const Center(
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (filament.colors.isNotEmpty)
                                Wrap(
                                  spacing: 4,
                                  children: filament.colors.map((color) {
                                    return Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }).toList(),
                                ),

                              const SizedBox(width: 8),

                              Text(
                                filament.brand,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "${filament.material} ${filament.variant}",
                            style: const TextStyle(fontSize: 18),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            l10n.remainingWeightOfTotal(
                              filament.remainingWeight.toInt(),
                              filament.totalWeight.toInt(),
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 900;
                  final filamentFields = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: brands.contains(selectedBrand)
                            ? selectedBrand
                            : null,

                        decoration: InputDecoration(
                          labelText: l10n.manufacturer,

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),

                          filled: true,
                          fillColor: Theme.of(context).cardColor,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),

                        items: brands
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),

                        onChanged: (val) {
                          if (val == null) return;

                          setState(() {
                            selectedBrand = val;

                            materials = FilamentCatalogService.getMaterials(
                              val,
                            );

                            selectedMaterial = null;
                            selectedVariant = null;
                            selectedColor = null;

                            // Automatische Dichte bei Herstellerwechsel zurücksetzen.
                            // Gespeicherte und manuelle Werte bleiben erhalten.
                            updateDensityFromCatalog();

                            colorNamesList = [];
                            variantsByMaterial.clear();
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        key: ValueKey('material_$selectedBrand'),
                        initialValue: materials.contains(selectedMaterial)
                            ? selectedMaterial
                            : null,

                        decoration: InputDecoration(
                          labelText: l10n.material,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),

                        items: materials
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),

                        onChanged: (val) {
                          if (val != null) {
                            _onMaterialChanged(val);
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'variant_${selectedBrand}_$selectedMaterial',
                        ),
                        initialValue:
                            selectedMaterial != null &&
                                variantsByMaterial[selectedMaterial]!.contains(
                                  selectedVariant,
                                )
                            ? selectedVariant
                            : null,

                        decoration: InputDecoration(
                          labelText: l10n.variant,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),

                        items: selectedMaterial == null
                            ? []
                            : variantsByMaterial[selectedMaterial]!
                                  .map(
                                    (v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    ),
                                  )
                                  .toList(),

                        onChanged: (val) {
                          setState(() {
                            selectedVariant = val;
                            selectedColor = null;

                            // Eindeutige Materialdichte aus dem Katalog übernehmen.
                            // Gespeicherte und manuelle Werte bleiben geschützt.
                            updateDensityFromCatalog();

                            if (selectedBrand != null &&
                                selectedMaterial != null &&
                                val != null) {
                              colorNamesList = FilamentCatalogService.getColors(
                                selectedBrand!,
                                selectedMaterial!,
                                val,
                              );
                            } else {
                              colorNamesList = [];
                            }
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          'color_${selectedBrand}_${selectedMaterial}_$selectedVariant',
                        ),
                        initialValue: colorNamesList.contains(selectedColor)
                            ? selectedColor
                            : null,

                        decoration: InputDecoration(
                          labelText: l10n.color,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                        ),

                        items: colorNamesList.map((c) {
                          final catalogColors =
                              FilamentCatalogService.tryGetColorsFromHex(
                                selectedBrand ?? '',
                                selectedMaterial ?? '',
                                selectedVariant ?? '',
                                c,
                              );

                          final savedColors = widget.filament.filamentColors
                              .where(
                                (entry) =>
                                    entry.name.trim().toLowerCase() ==
                                    c.trim().toLowerCase(),
                              )
                              .map((entry) {
                                try {
                                  final hex = entry.hex
                                      .replaceAll('#', '')
                                      .trim();
                                  final normalized = hex.length == 6
                                      ? 'FF$hex'
                                      : hex;
                                  return Color(
                                    int.parse(normalized, radix: 16),
                                  );
                                } catch (_) {
                                  return null;
                                }
                              })
                              .whereType<Color>()
                              .toList();

                          final customColor =
                              customColorMap[c.trim().toLowerCase()];

                          final previewColors =
                              catalogColors ??
                              (customColor != null
                                  ? <Color>[customColor]
                                  : savedColors.isNotEmpty
                                  ? savedColors
                                  : c == widget.filament.colorNames.join(' + ')
                                  ? widget.filament.colors
                                  : <Color>[]);

                          return DropdownMenuItem<String>(
                            value: c,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: previewColors.map((color) {
                                    return Container(
                                      width: 14,
                                      height: 14,
                                      margin: const EdgeInsets.only(right: 3),
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).dividerColor,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    ColorNameLocalizer.localize(context, c),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        onChanged: (val) {
                          setState(() {
                            selectedColor = val;
                          });
                        },
                      ),
                    ],
                  );
                  final settings = PrintSettingsSection(
                    selectedDiameter: selectedDiameter,
                    diameters: diameters,
                    density: selectedDensity,
                    nozzleTemp: nozzleTemp,
                    bedTemp: bedTemp,
                    onDiameterChanged: (value) {
                      setState(() {
                        selectedDiameter = value;
                      });
                    },
                    onDensityChanged: (value) {
                      setState(() {
                        selectedDensity = value;
                        densityManuallyEdited = true;
                      });
                    },
                    onNozzleTempChanged: (value) {
                      setState(() {
                        nozzleTemp = value;
                      });
                    },
                    onBedTempChanged: (value) {
                      setState(() {
                        bedTemp = value;
                      });
                    },
                  );
                  if (!wide) {
                    return Column(
                      children: [
                        filamentFields,
                        const SizedBox(height: 16),
                        settings,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: filamentFields),
                      const SizedBox(width: 20),
                      Expanded(child: settings),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              /// 🧵 Spulen-Bereich
              Text(
                l10n.spools,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Column(
                children: _editingSpools.asMap().entries.map((entry) {
                  final index = entry.key;
                  final spool = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.album, size: 16),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.spoolNumber(index + 1)),
                              if (spool.storageLocation.trim().isNotEmpty ||
                                  spool.storagePosition.trim().isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  [
                                        spool.storageLocation.trim(),
                                        spool.storagePosition.trim(),
                                      ]
                                      .where((value) => value.isNotEmpty)
                                      .join(' / '),
                                  softWrap: true,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          '${_formatPrice(spool.effectivePrice(widget.filament.price))} €',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),

                        const SizedBox(width: 18),

                        Text(
                          "${spool.weight.toInt()} g",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(width: 12),

                        /// ✏️ Bearbeiten
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),

                          onPressed: () async {
                            final controller = TextEditingController(
                              text: spool.weight.toInt().toString(),
                            );

                            final spoolPriceController = TextEditingController(
                              text: _formatPrice(
                                spool.effectivePrice(widget.filament.price),
                              ),
                            );
                            final storageLocationController =
                                TextEditingController(
                                  text: spool.storageLocation,
                                );

                            final storagePositionController =
                                TextEditingController(
                                  text: spool.storagePosition,
                                );

                            final result = await showDialog<Map<String, dynamic>>(
                              context: context,

                              builder: (context) {
                                return AlertDialog(
                                  title: Text(l10n.editSpool),

                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: controller,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: l10n.weight,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: spoolPriceController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        decoration: InputDecoration(
                                          labelText: l10n.price,
                                          suffixText: '€',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: storageLocationController,
                                        decoration: InputDecoration(
                                          labelText: l10n.storageLocation,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: storagePositionController,
                                        decoration: InputDecoration(
                                          labelText: l10n.storagePosition,
                                        ),
                                      ),
                                    ],
                                  ),

                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },

                                      child: Text(l10n.cancel),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
                                        final weight = _parseAmount(
                                          controller.text,
                                        );
                                        final price = _parseAmount(
                                          spoolPriceController.text,
                                        );

                                        if (weight != null &&
                                            weight >= 0 &&
                                            price != null &&
                                            price >= 0 &&
                                            price.isFinite &&
                                            weight.isFinite) {
                                          Navigator.pop(context, {
                                            'weight': weight,
                                            'price': price,
                                            'storageLocation':
                                                storageLocationController.text
                                                    .trim(),
                                            'storagePosition':
                                                storagePositionController.text
                                                    .trim(),
                                          });
                                        }
                                      },

                                      child: Text(l10n.save),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result != null) {
                              setState(() {
                                spool.weight = result['weight'] as double;
                                spool.price = result['price'] as double;
                                spool.storageLocation =
                                    result['storageLocation'] as String;
                                spool.storagePosition =
                                    result['storagePosition'] as String;
                              });
                            }
                          },
                        ),

                        /// 🗑 Löschen
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),

                          onPressed: () async {
                            final spools = _editingSpools;

                            /// 🧵 Wenn letzte Spule

                            if (spools.length == 1) {
                              final confirm = await showDialog<bool>(
                                context: context,

                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(l10n.deleteLastSpool),

                                    content: Text(l10n.deleteLastSpoolWarning),

                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },

                                        child: Text(l10n.cancel),
                                      ),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),

                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },

                                        child: Text(
                                          l10n.deleteAndRemoveFilament,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              final appState = context.read<AppState>();

                              if (confirm != true) return;

                              if (!mounted) return;

                              appState.removeFilament(widget.filament);

                              if (!mounted) return;

                              Navigator.of(context).pop();
                            }
                            /// 🧵 Normales Löschen
                            else {
                              final confirm = await showDialog<bool>(
                                context: context,

                                builder: (dialogContext) {
                                  return AlertDialog(
                                    title: Text(l10n.deleteSpool),

                                    content: Text(
                                      l10n.deleteSpoolConfirmation(index + 1),
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },

                                        child: Text(l10n.cancel),
                                      ),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),

                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },

                                        child: Text(l10n.delete),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirm == true) {
                                setState(() {
                                  spools.removeAt(index);
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraints) {
                  final totalWeight = _formatWeight(_remainingSpoolWeight);
                  final totalPrice = _formatPrice(_totalSpoolPrice);
                  final weightTile = _summaryTile(
                    l10n.overallRemainingSpoolWeight,
                    '$totalWeight g',
                  );
                  final priceTile = _summaryTile(
                    l10n.overallSpoolPurchasePrice,
                    '$totalPrice €',
                  );
                  if (constraints.maxWidth < 500) {
                    return Column(
                      children: [
                        priceTile,
                        const SizedBox(height: 8),
                        weightTile,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: priceTile),
                      const SizedBox(width: 12),
                      Expanded(child: weightTile),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  final controller = TextEditingController();
                  final spoolPriceController = TextEditingController(
                    text: _formatPrice(widget.filament.price),
                  );

                  final storageLocationController = TextEditingController();
                  final storagePositionController = TextEditingController();

                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,

                    builder: (context) {
                      return AlertDialog(
                        title: Text(l10n.newSpool),

                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.weight,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: spoolPriceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.price,
                                suffixText: '€',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: storageLocationController,
                              decoration: InputDecoration(
                                labelText: l10n.storageLocation,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: storagePositionController,
                              decoration: InputDecoration(
                                labelText: l10n.storagePosition,
                              ),
                            ),
                          ],
                        ),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            child: Text(l10n.cancel),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              final weight = _parseAmount(controller.text);
                              final price = _parseAmount(
                                spoolPriceController.text,
                              );

                              if (weight != null &&
                                  weight >= 0 &&
                                  weight.isFinite &&
                                  price != null &&
                                  price >= 0 &&
                                  price.isFinite) {
                                Navigator.pop(context, {
                                  'weight': weight,
                                  'price': price,
                                  'storageLocation': storageLocationController
                                      .text
                                      .trim(),
                                  'storagePosition': storagePositionController
                                      .text
                                      .trim(),
                                });
                              }
                            },

                            child: Text(l10n.save),
                          ),
                        ],
                      );
                    },
                  );

                  if (result != null) {
                    setState(() {
                      final weight = result['weight'] as double;

                      _editingSpools.add(
                        Spool(
                          weight: weight,
                          price: result['price'] as double,
                          storageLocation: result['storageLocation'] as String,
                          storagePosition: result['storagePosition'] as String,
                        ),
                      );
                      _addedSpoolWeight += weight;
                    });
                  }
                },
                icon: const Icon(Icons.add),

                label: Text(l10n.addSpool),
              ),

              const SizedBox(height: 30),

              ElevatedButton(onPressed: save, child: Text(l10n.save)),
            ],
          ),
        ),
      ),
    );
  }
}
