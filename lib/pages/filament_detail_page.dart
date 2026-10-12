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

  List<String> colorNamesList = [];

  final Map<String, Color> customColorMap = {};

  int? nozzleTemp;
  int? bedTemp;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _loadCustomColors();

    final f = widget.filament;

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

    selectedVariant = f.variant;

    nozzleTemp = f.nozzleTemp;
    bedTemp = f.bedTemp;

    priceController.text = f.price.toString();
    weightController.text = f.spools
        .fold(0.0, (sum, spool) => sum + spool.weight)
        .toString();

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

  void _onMaterialChanged(String material) {
    final temperatures = MaterialTemperatureService.getTemperatures(material);

    final variants = selectedBrand == null
        ? <String>[]
        : FilamentCatalogService.getVariants(selectedBrand!, material);

    setState(() {
      selectedMaterial = material;
      selectedVariant = null;
      selectedColor = null;

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

    f.nozzleTemp = nozzleTemp ?? f.nozzleTemp;

    f.bedTemp = bedTemp ?? f.bedTemp;

    f.price = double.tryParse(priceController.text) ?? f.price;

    /// 🧵 Restgewicht aus Spools berechnen

    double remainingWeight = f.spools.fold(
      0,
      (sum, spool) => sum + spool.weight,
    );

    f.remainingWeight = remainingWeight;

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
    appState.updateFilament(f);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final filament = widget.filament;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editFilament)),
      body: ListView(
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

          DropdownButtonFormField<String>(
            initialValue: brands.contains(selectedBrand) ? selectedBrand : null,

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
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),

            items: brands
                .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                .toList(),

            onChanged: (val) {
              if (val == null) return;

              setState(() {
                selectedBrand = val;

                materials = FilamentCatalogService.getMaterials(val);

                selectedMaterial = null;
                selectedVariant = null;
                selectedColor = null;

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
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),

            items: materials
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),

            onChanged: (val) {
              if (val != null) {
                _onMaterialChanged(val);
              }
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            key: ValueKey('variant_${selectedBrand}_$selectedMaterial'),
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
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),

            items: selectedMaterial == null
                ? []
                : variantsByMaterial[selectedMaterial]!
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),

            onChanged: (val) {
              setState(() {
                selectedVariant = val;
                selectedColor = null;

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
                borderSide: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),

            items: colorNamesList.map((c) {
              final catalogColors = FilamentCatalogService.tryGetColorsFromHex(
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
                      final hex = entry.hex.replaceAll('#', '').trim();
                      final normalized = hex.length == 6 ? 'FF$hex' : hex;
                      return Color(int.parse(normalized, radix: 16));
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<Color>()
                  .toList();

              final customColor = customColorMap[c.trim().toLowerCase()];

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

          const SizedBox(height: 16),

          PrintSettingsSection(
            selectedDiameter: selectedDiameter,
            diameters: diameters,
            nozzleTemp: nozzleTemp,
            bedTemp: bedTemp,
            onDiameterChanged: (value) {
              setState(() {
                selectedDiameter = value;
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
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.price,
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
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.remainingWeight,
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
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// 🧵 Spulen-Bereich
          Text(
            l10n.spools,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Column(
            children: widget.filament.spools.asMap().entries.map((entry) {
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
                              ].where((value) => value.isNotEmpty).join(' / '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const Spacer(),

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

                        final storageLocationController = TextEditingController(
                          text: spool.storageLocation,
                        );

                        final storagePositionController = TextEditingController(
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
                                    final weight = double.tryParse(
                                      controller.text,
                                    );

                                    if (weight != null && weight > 0) {
                                      Navigator.pop(context, {
                                        'weight': weight,
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
                            spool.storageLocation =
                                result['storageLocation'] as String;
                            spool.storagePosition =
                                result['storagePosition'] as String;

                            /// Restgewicht neu berechnen
                            double total = 0;

                            for (final s in widget.filament.spools) {
                              total += s.weight;
                            }

                            weightController.text = total.toString();
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
                        final spools = widget.filament.spools;

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

                                    child: Text(l10n.deleteAndRemoveFilament),
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

                              /// Restgewicht neu berechnen

                              double total = 0;

                              for (final s in spools) {
                                total += s.weight;
                              }

                              weightController.text = total.toString();
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

          ElevatedButton.icon(
            onPressed: () async {
              final controller = TextEditingController();

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
                          decoration: InputDecoration(labelText: l10n.weight),
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
                          final weight = double.tryParse(controller.text);

                          if (weight != null && weight > 0) {
                            Navigator.pop(context, {
                              'weight': weight,
                              'storageLocation': storageLocationController.text
                                  .trim(),
                              'storagePosition': storagePositionController.text
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

                  widget.filament.spools.add(
                    Spool(
                      weight: weight,
                      storageLocation: result['storageLocation'] as String,
                      storagePosition: result['storagePosition'] as String,
                    ),
                  );

                  double total = 0;

                  for (final s in widget.filament.spools) {
                    total += s.weight;
                  }

                  widget.filament.totalWeight += weight;

                  weightController.text = total.toString();
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
    );
  }
}
