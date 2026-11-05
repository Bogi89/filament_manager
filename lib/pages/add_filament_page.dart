import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/filament.dart';
import '../services/filament_catalog_service.dart';
import '../models/spool.dart';
import '../services/custom_color_service.dart';
import '../services/material_temperature_service.dart';
import '../models/filament_color.dart';
import '../widgets/add_filament/sections/inventory_cost_section.dart';
import '../widgets/add_filament/sections/print_settings_section.dart';
import '../widgets/common/page_header.dart';
import '../l10n/app_localizations.dart';
import '../utils/color_name_localizer.dart';

class AddFilamentPage extends StatefulWidget {
  final Filament? existingFilament;
  final Function(Filament) onSave;

  const AddFilamentPage({
    super.key,
    this.existingFilament,
    required this.onSave,
  });

  @override
  State<AddFilamentPage> createState() => _AddFilamentPageState();
}

class _AddFilamentPageState extends State<AddFilamentPage> {
  bool catalogLoaded = false;

  String? selectedBrand;
  String? selectedMaterial;
  String? selectedVariant;
  String? selectedColor;

  List<FilamentColor> selectedFilamentColors = [];

  Color? selectedColorValue;

  final Map<String, Color> preloadColorMap = {};

  String buildColorKey(
    String brand,
    String material,
    String variant,
    String colorName,
  ) {
    return "$brand|$material|$variant|$colorName";
  }

  double? selectedDiameter;

  // Optionale Materialdichte in g/cm³.
  double? selectedDensity;

  // Verhindert das Überschreiben einer manuellen Dichteingabe.
  bool densityManuallyEdited = false;

  int? nozzleTemp;
  int? bedTemp;

  final totalWeightController = TextEditingController();

  final remainingWeightController = TextEditingController();

  final priceController = TextEditingController();

  final storageLocationController = TextEditingController();

  final storagePositionController = TextEditingController();

  final TextEditingController brandSearchController = TextEditingController();

  final TextEditingController materialSearchController =
      TextEditingController();

  final TextEditingController variantSearchController = TextEditingController();

  final TextEditingController colorSearchController = TextEditingController();

  String? selectedSpoolWeight;

  List<AdditionalSpoolInput> additionalSpools = [];

  List<String> brands = [];
  List<String> materials = [];
  List<String> variants = [];
  List<String> colors = [];

  final diameters = [1.75, 2.85, 3.0];

  @override
  void initState() {
    super.initState();
    loadCatalog();
  }

  Future<void> loadCatalog() async {
    await FilamentCatalogService.loadCatalog();

    final customColors = await CustomColorService.loadCustomColors();

    for (final color in customColors) {
      final name = color['name'].toString();

      final hex = color['hex'].toString();

      preloadColorMap[name] = Color(int.parse(hex.replaceFirst('#', '0xFF')));
    }

    brands = FilamentCatalogService.getBrands().toSet().toList();

    if (selectedBrand != null && !brands.contains(selectedBrand)) {
      selectedBrand = null;
    }

    setState(() {
      catalogLoaded = true;
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

  void selectBrand(String brand) {
    selectedBrand = brand;

    materials = FilamentCatalogService.getMaterials(brand);

    selectedMaterial = null;
    selectedVariant = null;
    selectedColor = null;

    // Automatischen Dichtewert bei Herstellerwechsel zurücksetzen.
    // Manuelle Eingaben bleiben erhalten.
    updateDensityFromCatalog();

    variants = [];
    colors = [];
    preloadColorMap.clear();

    setState(() {});
  }

  void selectMaterial(String material) {
    selectedMaterial = material;

    variants = FilamentCatalogService.getVariants(selectedBrand!, material);

    selectedVariant = null;
    selectedColor = null;

    // Automatischen Dichtewert bei Materialwechsel zurücksetzen.
    // Manuelle Eingaben bleiben erhalten.
    updateDensityFromCatalog();

    colors = [];
    selectedFilamentColors = [];
    preloadColorMap.clear();

    final temperatures = MaterialTemperatureService.getTemperatures(material);

    nozzleTemp = temperatures?.nozzle;
    bedTemp = temperatures?.bed;

    setState(() {});
  }

  Future<void> _addBrandDialog() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newManufacturer),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.manufacturerName),
            autofocus: true,
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
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );

    if (result != null) {
      FilamentCatalogService.addCustomBrand(result);

      setState(() {
        brands = FilamentCatalogService.getBrands();
        selectedBrand = result;
      });
    }
  }

  Future<void> _addMaterialDialog() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newMaterial),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: l10n.materialName),
            autofocus: true,
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
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
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
        materials.add(result);

        FilamentCatalogService.addCustomMaterial(selectedBrand!, result);

        materials = materials.toSet().toList();
        materials.sort();

        selectedMaterial = result;
      });
    }
  }

  void selectVariant(String variant) {
    selectedVariant = variant;

    // Dichte automatisch aus dem Katalog übernehmen,
    // sofern sie nicht manuell geändert wurde.
    updateDensityFromCatalog();

    final newColors = FilamentCatalogService.getColors(
      selectedBrand!,
      selectedMaterial!,
      variant,
    );

    colors = newColors;

    /// Farben vorberechnen
    preloadColorMap.clear();

    for (var c in colors) {
      if (selectedBrand != null &&
          selectedMaterial != null &&
          selectedVariant != null) {
        final colorsFromHex = FilamentCatalogService.getColorsFromHex(
          selectedBrand!,
          selectedMaterial!,
          selectedVariant!,
          c,
        );

        final splitColors = c.split('+').map((e) => e.trim()).toList();

        for (int i = 0; i < splitColors.length; i++) {
          final colorName = splitColors[i];

          if (i < colorsFromHex.length) {
            final key = buildColorKey(
              selectedBrand!,
              selectedMaterial!,
              selectedVariant!,
              colorName,
            );

            preloadColorMap[key] = colorsFromHex[i];
          } else {
            final key = buildColorKey(
              selectedBrand!,
              selectedMaterial!,
              selectedVariant!,
              colorName,
            );

            preloadColorMap[key] = Colors.grey;
          }
        }
      } else {
        preloadColorMap[c] = Colors.grey;
      }
    }

    selectedColor = null;
    selectedFilamentColors = [];

    // Temperatur anhand von Material, Hersteller und Variante bestimmen.
    if (selectedMaterial != null && selectedBrand != null) {
      final temperatures = MaterialTemperatureService.getTemperatures(
        selectedMaterial!,
        brand: selectedBrand,
        variant: selectedVariant,
      );

      nozzleTemp = temperatures?.nozzle;
      bedTemp = temperatures?.bed;
    }

    setState(() {});
  }

  Widget buildAlignedAddButton({required VoidCallback? onPressed}) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 48,
      height: 56,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        tooltip: l10n.add,
      ),
    );
  }

  Widget buildColorItem(String c) {
    final parsedColors = FilamentCatalogService.getColorsFromHex(
      selectedBrand!,
      selectedMaterial!,
      selectedVariant!,
      c,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...parsedColors.map(
          (color) => Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),

        Flexible(
          child: Text(
            ColorNameLocalizer.localize(context, c),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void saveFilament() {
    final l10n = AppLocalizations.of(context)!;

    final totalWeight = double.tryParse(
      totalWeightController.text.trim().replaceAll(',', '.'),
    );

    final remainingWeight = double.tryParse(
      remainingWeightController.text.trim().replaceAll(',', '.'),
    );

    final price = double.tryParse(
      priceController.text.trim().replaceAll(',', '.'),
    );

    final hasMissingFields =
        selectedBrand == null ||
        selectedMaterial == null ||
        selectedVariant == null ||
        selectedColor == null ||
        selectedDiameter == null ||
        selectedSpoolWeight == null ||
        totalWeight == null ||
        remainingWeight == null ||
        price == null ||
        nozzleTemp == null ||
        bedTemp == null;

    if (hasMissingFields) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillAllRequiredFields)));

      return;
    }

    // Validate the first physical spool and all additional spools before saving.
    if (!totalWeight.isFinite ||
        totalWeight <= 0 ||
        !remainingWeight.isFinite ||
        remainingWeight < 0 ||
        remainingWeight > totalWeight ||
        !price.isFinite ||
        price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Gewicht, Restgewicht und Preis prüfen.'),
        ),
      );
      return;
    }

    final newSpools = <Spool>[
      Spool(
        weight: remainingWeight,
        price: price,
        storageLocation: storageLocationController.text.trim(),
        storagePosition: storagePositionController.text.trim(),
      ),
    ];
    var combinedTotalWeight = totalWeight;
    var combinedRemainingWeight = remainingWeight;
    for (final input in additionalSpools) {
      double? parse(String value) =>
          double.tryParse(value.trim().replaceAll(',', '.'));
      final nominal = parse(input.totalWeight);
      final remaining = parse(input.remainingWeight);
      final individualPrice = input.price.trim().isEmpty
          ? price
          : parse(input.price);
      if (nominal == null ||
          !nominal.isFinite ||
          nominal <= 0 ||
          remaining == null ||
          !remaining.isFinite ||
          remaining < 0 ||
          remaining > nominal ||
          individualPrice == null ||
          !individualPrice.isFinite ||
          individualPrice < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.checkAllSpoolDetails),
          ),
        );
        return;
      }
      newSpools.add(
        Spool(
          weight: remaining,
          price: individualPrice,
          storageLocation: input.storageLocation.trim(),
          storagePosition: input.storagePosition.trim(),
        ),
      );
      combinedTotalWeight += nominal;
      combinedRemainingWeight += remaining;
    }

    final catalogColors = FilamentCatalogService.getColorsFromHex(
      selectedBrand!,
      selectedMaterial!,
      selectedVariant!,
      selectedColor!,
    );
    final selectedHexColors = selectedFilamentColors
        .map((entry) {
          final hex = entry.hex.trim().replaceFirst('#', '');
          if (!RegExp(r'^(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$').hasMatch(hex)) {
            return null;
          }
          final value = int.tryParse(hex, radix: 16);
          if (value == null) return null;
          return Color(hex.length == 6 ? 0xFF000000 | value : value);
        })
        .whereType<Color>()
        .toList();
    final List<Color> parsedColors =
        selectedHexColors.isNotEmpty &&
            (selectedHexColors.length >= catalogColors.length ||
                catalogColors.isEmpty)
        ? selectedHexColors
        : catalogColors;

    final List<String> colorNames = selectedFilamentColors.isNotEmpty
        ? selectedFilamentColors
              .map((f) => f.name.trim())
              .where(
                (name) => name.isNotEmpty && name.toLowerCase() != "unknown",
              )
              .toList()
        : selectedColor != null &&
              selectedColor!.trim().isNotEmpty &&
              selectedColor!.trim().toLowerCase() != "unknown"
        ? selectedColor!
              .split('+')
              .map((name) => name.trim())
              .where((name) => name.isNotEmpty)
              .toList()
        : ["Unknown"];

    // DEBUG vor dem Erstellen
    final filament = Filament(
      brand: selectedBrand!,
      material: selectedMaterial!,

      variant: (selectedVariant != null && selectedVariant!.isNotEmpty)
          ? selectedVariant!
          : "Standard",

      diameter: selectedDiameter ?? 1.75,
      density: selectedDensity,
      totalWeight: combinedTotalWeight,
      remainingWeight: combinedRemainingWeight,
      price: price,

      nozzleTemp: nozzleTemp ?? 0,
      bedTemp: bedTemp ?? 0,

      color: parsedColors.isNotEmpty ? parsedColors.first : Colors.grey,

      colors: parsedColors.isNotEmpty ? parsedColors : [Colors.grey],

      colorNames: colorNames.isNotEmpty
          ? colorNames
          : selectedColor != null &&
                selectedColor!.trim().isNotEmpty &&
                selectedColor!.trim().toLowerCase() != "unknown"
          ? selectedColor!
                .split('+')
                .map((name) => name.trim())
                .where((name) => name.isNotEmpty)
                .toList()
          : ["Unknown"],
      filamentColors: List.generate(
        parsedColors.length,
        (index) => FilamentColor(
          name: colorNames.length == parsedColors.length
              ? colorNames[index]
              : (colorNames.isNotEmpty ? colorNames.first : "Unknown"),
          hex:
              '#${parsedColors[index].toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          isCustom: false,
        ),
      ),

      colorType: parsedColors.length > 1 ? "multi" : "single",

      spools: newSpools,
    );

    widget.onSave(filament);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    debugPrint('AddFilamentPage rebuild');

    if (!catalogLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isMobile = MediaQuery.of(context).size.width < 1000;
    final isDesktop = !isMobile;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : const Color(0xFFE9EEF5),

      appBar: AppBar(title: Text(l10n.addFilament)),

      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1400),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 32,
                  vertical: 20,
                ),

                children: [
                  PageHeader(title: l10n.addFilament),

                  const SizedBox(height: 24),

                  if (isDesktop) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                              boxShadow:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.03,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.filament,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<String>(
                                        items: (filter, infiniteScrollProps) =>
                                            brands,
                                        selectedItem: selectedBrand,
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            controller: brandSearchController,
                                            decoration: InputDecoration(
                                              hintText: l10n.searchManufacturer,
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  brandSearchController.clear();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        decoratorProps: DropDownDecoratorProps(
                                          decoration: InputDecoration(
                                            hintText: l10n.manufacturer,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            selectBrand(value);
                                          }
                                        },
                                      ),
                                    ),

                                    buildAlignedAddButton(
                                      onPressed: _addBrandDialog,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<String>(
                                        items: (filter, infiniteScrollProps) =>
                                            materials,
                                        selectedItem: selectedMaterial,
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            controller:
                                                materialSearchController,
                                            decoration: InputDecoration(
                                              hintText: l10n.searchMaterial,
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  materialSearchController
                                                      .clear();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        decoratorProps: DropDownDecoratorProps(
                                          decoration: InputDecoration(
                                            hintText: l10n.material,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            selectMaterial(value);
                                          }
                                        },
                                      ),
                                    ),

                                    buildAlignedAddButton(
                                      onPressed: _addMaterialDialog,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<String>(
                                        items: (filter, infiniteScrollProps) =>
                                            variants,
                                        selectedItem: selectedVariant,
                                        popupProps: PopupProps.menu(
                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            controller: variantSearchController,
                                            decoration: InputDecoration(
                                              hintText: l10n.searchVariant,
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  variantSearchController
                                                      .clear();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        decoratorProps: DropDownDecoratorProps(
                                          decoration: InputDecoration(
                                            hintText: l10n.variant,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value != null) {
                                            selectVariant(value);
                                          }
                                        },
                                      ),
                                    ),

                                    buildAlignedAddButton(
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController();

                                        final result = await showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(l10n.newVariant),
                                              content: TextField(
                                                controller: controller,
                                                decoration: InputDecoration(
                                                  hintText: l10n.variantName,
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(l10n.cancel),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      controller.text.trim(),
                                                    );
                                                  },
                                                  child: Text(l10n.save),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (result != null &&
                                            result.isNotEmpty &&
                                            selectedBrand != null &&
                                            selectedMaterial != null) {
                                          setState(() {
                                            variants.add(result);

                                            FilamentCatalogService.addCustomVariant(
                                              selectedBrand!,
                                              selectedMaterial!,
                                              result,
                                            );

                                            variants = variants
                                                .toSet()
                                                .toList();
                                            variants.sort();
                                            selectedVariant = result;

                                            // Dichte für die neue Variante prüfen.
                                            updateDensityFromCatalog();
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownSearch<String>(
                                        items: (filter, infiniteScrollProps) =>
                                            colors,
                                        selectedItem:
                                            colors.contains(selectedColor)
                                            ? selectedColor
                                            : null,

                                        dropdownBuilder: (context, item) {
                                          if (item == null) {
                                            return const Text('');
                                          }
                                          return buildColorItem(item);
                                        },

                                        popupProps: PopupProps.menu(
                                          itemBuilder:
                                              (
                                                context,
                                                item,
                                                isDisabled,
                                                isSelected,
                                              ) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 10,
                                                      ),
                                                  child: buildColorItem(item),
                                                );
                                              },

                                          showSearchBox: true,
                                          searchFieldProps: TextFieldProps(
                                            controller: colorSearchController,
                                            decoration: InputDecoration(
                                              hintText: l10n.searchColor,
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  colorSearchController.clear();
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                        decoratorProps: DropDownDecoratorProps(
                                          decoration: InputDecoration(
                                            labelText: l10n.color,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(() {
                                              selectedColor = val;

                                              selectedFilamentColors = [];

                                              final catalogColors =
                                                  FilamentCatalogService.getColors(
                                                    selectedBrand!,
                                                    selectedMaterial!,
                                                    selectedVariant!,
                                                  );

                                              final selectedCatalogColor =
                                                  catalogColors
                                                      .where(
                                                        (catalogColor) =>
                                                            catalogColor
                                                                .split('|')
                                                                .first
                                                                .trim() ==
                                                            val.trim(),
                                                      )
                                                      .toList();

                                              if (selectedCatalogColor
                                                  .isNotEmpty) {
                                                final parts =
                                                    selectedCatalogColor.first
                                                        .split('|');

                                                if (parts.length > 1) {
                                                  final hexParts = parts[1]
                                                      .split('+')
                                                      .map((hex) => hex.trim())
                                                      .where(
                                                        (hex) => hex.isNotEmpty,
                                                      )
                                                      .toList();

                                                  selectedFilamentColors =
                                                      hexParts
                                                          .map(
                                                            (
                                                              hex,
                                                            ) => FilamentColor(
                                                              name: val.trim(),
                                                              hex:
                                                                  hex.startsWith(
                                                                    '#',
                                                                  )
                                                                  ? hex
                                                                  : '#$hex',
                                                              isCustom: false,
                                                            ),
                                                          )
                                                          .toList();
                                                }
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ),

                                    buildAlignedAddButton(
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController();

                                        final pickedColors = <Color>[
                                          selectedColorValue ?? Colors.blue,
                                        ];

                                        int activeColorIndex = 0;

                                        final result = await showDialog<Map<String, dynamic>>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(l10n.newColor),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: controller,
                                                    decoration: InputDecoration(
                                                      hintText: l10n.colorName,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 16),

                                                  // 🎨 Farbauswahl
                                                  StatefulBuilder(
                                                    builder: (context, setStateDialog) {
                                                      return Column(
                                                        children: [
                                                          Wrap(
                                                            spacing: 8,
                                                            runSpacing: 8,
                                                            alignment:
                                                                WrapAlignment
                                                                    .center,
                                                            children: [
                                                              ...List.generate(
                                                                pickedColors
                                                                    .length,
                                                                (index) {
                                                                  final isActive =
                                                                      index ==
                                                                      activeColorIndex;

                                                                  return GestureDetector(
                                                                    onTap: () {
                                                                      setStateDialog(() {
                                                                        activeColorIndex =
                                                                            index;
                                                                        selectedColorValue =
                                                                            pickedColors[index];
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      width: 34,
                                                                      height:
                                                                          34,
                                                                      decoration: BoxDecoration(
                                                                        color:
                                                                            pickedColors[index],
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        border: Border.all(
                                                                          color:
                                                                              isActive
                                                                              ? Colors.white
                                                                              : Colors.grey,
                                                                          width:
                                                                              isActive
                                                                              ? 3
                                                                              : 1,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                              if (pickedColors
                                                                      .length <
                                                                  4)
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setStateDialog(() {
                                                                      pickedColors.add(
                                                                        Colors
                                                                            .blue,
                                                                      );
                                                                      activeColorIndex =
                                                                          pickedColors
                                                                              .length -
                                                                          1;
                                                                      selectedColorValue =
                                                                          pickedColors[activeColorIndex];
                                                                    });
                                                                  },
                                                                  child: Container(
                                                                    width: 34,
                                                                    height: 34,
                                                                    decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      border: Border.all(
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                    ),
                                                                    child: const Icon(
                                                                      Icons.add,
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),

                                                          const SizedBox(
                                                            height: 16,
                                                          ),

                                                          ColorPicker(
                                                            pickerColor:
                                                                pickedColors[activeColorIndex],
                                                            onColorChanged: (color) {
                                                              setStateDialog(() {
                                                                selectedColorValue =
                                                                    color;
                                                                pickedColors[activeColorIndex] =
                                                                    color;
                                                              });
                                                            },
                                                            enableAlpha: false,
                                                            displayThumbColor:
                                                                true,
                                                          ),
                                                        ],
                                                      );
                                                    },
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
                                                    Navigator.pop(context, {
                                                      "name": controller.text
                                                          .trim(),
                                                      "color":
                                                          pickedColors[activeColorIndex],
                                                      "colors": pickedColors,
                                                    });
                                                  },
                                                  child: Text(l10n.save),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (result != null &&
                                            selectedBrand != null &&
                                            selectedMaterial != null &&
                                            selectedVariant != null) {
                                          final colorName = result["name"]
                                              ?.toString();
                                          final Color pickedColor =
                                              result["color"] as Color;
                                          final List<Color> pickedColorList =
                                              List<Color>.from(
                                                result["colors"] as List,
                                              );

                                          final customHex = pickedColorList
                                              .map(
                                                (color) =>
                                                    '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                              )
                                              .join('+');

                                          if (colorName != null &&
                                              colorName.isNotEmpty) {
                                            // 🔥 Farbe im Catalog hinzufügen
                                            FilamentCatalogService.addCustomColor(
                                              selectedBrand!,
                                              selectedMaterial!,
                                              selectedVariant!,
                                              colorName,
                                              customHex,
                                            );

                                            await CustomColorService.saveCustomColor(
                                              name: colorName,
                                              hex: customHex,
                                            );

                                            await FilamentCatalogService.saveCustomColors();

                                            // 🔥 Danach UI aktualisieren
                                            setState(() {
                                              // 🔥 Farben neu laden
                                              colors =
                                                  FilamentCatalogService.getColors(
                                                    selectedBrand!,
                                                    selectedMaterial!,
                                                    selectedVariant!,
                                                  );

                                              // 🔥 preloadColorMap komplett neu aufbauen
                                              preloadColorMap.clear();

                                              for (var c in colors) {
                                                final loadedColors =
                                                    FilamentCatalogService.getColorsFromHex(
                                                      selectedBrand!,
                                                      selectedMaterial!,
                                                      selectedVariant!,
                                                      c,
                                                    );

                                                if (loadedColors.isNotEmpty) {
                                                  final splitColors = c
                                                      .split('+')
                                                      .map((e) => e.trim())
                                                      .toList();

                                                  for (
                                                    int i = 0;
                                                    i < splitColors.length;
                                                    i++
                                                  ) {
                                                    final colorName =
                                                        splitColors[i];

                                                    final key = buildColorKey(
                                                      selectedBrand!,
                                                      selectedMaterial!,
                                                      selectedVariant!,
                                                      colorName,
                                                    );

                                                    if (i <
                                                        loadedColors.length) {
                                                      preloadColorMap[key] =
                                                          loadedColors[i];
                                                    } else {
                                                      preloadColorMap[key] =
                                                          Colors.grey;
                                                    }
                                                  }
                                                } else {
                                                  preloadColorMap[c] =
                                                      Colors.grey;
                                                }
                                              }

                                              // 🔥 neue Farbe setzen
                                              preloadColorMap[colorName] =
                                                  pickedColor;

                                              selectedColor = colorName;
                                              selectedColorValue = pickedColor;
                                            });
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 24),

                        Expanded(
                          child: PrintSettingsSection(
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                  if (isMobile)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow:
                            Theme.of(context).brightness == Brightness.dark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.filament,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownSearch<String>(
                                  items: (filter, infiniteScrollProps) =>
                                      brands,
                                  selectedItem: selectedBrand,
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      controller: brandSearchController,
                                      decoration: InputDecoration(
                                        hintText: l10n.searchManufacturer,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            brandSearchController.clear();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText: l10n.manufacturer,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectBrand(value);
                                    }
                                  },
                                ),
                              ),
                              buildAlignedAddButton(onPressed: _addBrandDialog),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownSearch<String>(
                                  items: (filter, infiniteScrollProps) =>
                                      materials,
                                  selectedItem: selectedMaterial,
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      controller: materialSearchController,
                                      decoration: InputDecoration(
                                        hintText: l10n.searchMaterial,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            materialSearchController.clear();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText: l10n.material,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectMaterial(value);
                                    }
                                  },
                                ),
                              ),

                              buildAlignedAddButton(
                                onPressed: _addMaterialDialog,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownSearch<String>(
                                  items: (filter, infiniteScrollProps) =>
                                      variants,
                                  selectedItem: selectedVariant,
                                  popupProps: PopupProps.menu(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      controller: variantSearchController,
                                      decoration: InputDecoration(
                                        hintText: l10n.searchVariant,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            variantSearchController.clear();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      hintText: l10n.variant,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      selectVariant(value);
                                    }
                                  },
                                ),
                              ),

                              buildAlignedAddButton(
                                onPressed: () async {
                                  final controller = TextEditingController();

                                  final result = await showDialog<String>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(l10n.newVariant),
                                        content: TextField(
                                          controller: controller,
                                          decoration: InputDecoration(
                                            hintText: l10n.variantName,
                                          ),
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
                                              Navigator.pop(
                                                context,
                                                controller.text.trim(),
                                              );
                                            },
                                            child: Text(l10n.save),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (result != null &&
                                      result.isNotEmpty &&
                                      selectedBrand != null &&
                                      selectedMaterial != null) {
                                    setState(() {
                                      variants.add(result);

                                      FilamentCatalogService.addCustomVariant(
                                        selectedBrand!,
                                        selectedMaterial!,
                                        result,
                                      );

                                      variants = variants.toSet().toList();

                                      variants.sort();

                                      selectedVariant = result;

                                      // Dichte für die neue Variante prüfen.
                                      updateDensityFromCatalog();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownSearch<String>(
                                  items: (filter, infiniteScrollProps) =>
                                      colors,
                                  selectedItem: colors.contains(selectedColor)
                                      ? selectedColor
                                      : null,

                                  dropdownBuilder: (context, item) {
                                    if (item == null) {
                                      return const Text('');
                                    }
                                    return buildColorItem(item);
                                  },

                                  popupProps: PopupProps.menu(
                                    itemBuilder:
                                        (
                                          context,
                                          item,
                                          isDisabled,
                                          isSelected,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                            child: buildColorItem(item),
                                          );
                                        },

                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                      controller: colorSearchController,
                                      decoration: InputDecoration(
                                        hintText: l10n.searchColor,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            colorSearchController.clear();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  decoratorProps: DropDownDecoratorProps(
                                    decoration: InputDecoration(
                                      labelText: l10n.color,
                                      border: const OutlineInputBorder(),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() {
                                        selectedColor = val;

                                        selectedFilamentColors = [];

                                        final catalogColors =
                                            FilamentCatalogService.getColors(
                                              selectedBrand!,
                                              selectedMaterial!,
                                              selectedVariant!,
                                            );

                                        final selectedCatalogColor =
                                            catalogColors
                                                .where(
                                                  (catalogColor) =>
                                                      catalogColor
                                                          .split('|')
                                                          .first
                                                          .trim() ==
                                                      val.trim(),
                                                )
                                                .toList();

                                        if (selectedCatalogColor.isNotEmpty) {
                                          final parts = selectedCatalogColor
                                              .first
                                              .split('|');

                                          if (parts.length > 1) {
                                            final hexParts = parts[1]
                                                .split('+')
                                                .map((hex) => hex.trim())
                                                .where((hex) => hex.isNotEmpty)
                                                .toList();

                                            selectedFilamentColors = hexParts
                                                .map(
                                                  (hex) => FilamentColor(
                                                    name: val.trim(),
                                                    hex: hex.startsWith('#')
                                                        ? hex
                                                        : '#$hex',
                                                    isCustom: false,
                                                  ),
                                                )
                                                .toList();
                                          }
                                        }
                                      });
                                    }
                                  },
                                ),
                              ),

                              buildAlignedAddButton(
                                onPressed: () async {
                                  final controller = TextEditingController();

                                  final pickedColors = <Color>[
                                    selectedColorValue ?? Colors.blue,
                                  ];

                                  int activeColorIndex = 0;

                                  final result = await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(l10n.newColor),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextField(
                                              controller: controller,
                                              decoration: InputDecoration(
                                                hintText: l10n.colorName,
                                              ),
                                            ),

                                            const SizedBox(height: 16),

                                            // 🎨 Farbauswahl
                                            StatefulBuilder(
                                              builder: (context, setStateDialog) {
                                                return Column(
                                                  children: [
                                                    Wrap(
                                                      spacing: 8,
                                                      runSpacing: 8,
                                                      alignment:
                                                          WrapAlignment.center,
                                                      children: [
                                                        ...List.generate(pickedColors.length, (
                                                          index,
                                                        ) {
                                                          final isActive =
                                                              index ==
                                                              activeColorIndex;

                                                          return GestureDetector(
                                                            onTap: () {
                                                              setStateDialog(() {
                                                                activeColorIndex =
                                                                    index;
                                                                selectedColorValue =
                                                                    pickedColors[index];
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 34,
                                                              height: 34,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    pickedColors[index],
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                  color:
                                                                      isActive
                                                                      ? Colors
                                                                            .white
                                                                      : Colors
                                                                            .grey,
                                                                  width:
                                                                      isActive
                                                                      ? 3
                                                                      : 1,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        if (pickedColors
                                                                .length <
                                                            4)
                                                          GestureDetector(
                                                            onTap: () {
                                                              setStateDialog(() {
                                                                pickedColors
                                                                    .add(
                                                                      Colors
                                                                          .blue,
                                                                    );
                                                                activeColorIndex =
                                                                    pickedColors
                                                                        .length -
                                                                    1;
                                                                selectedColorValue =
                                                                    pickedColors[activeColorIndex];
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 34,
                                                              height: 34,
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              ),
                                                              child: const Icon(
                                                                Icons.add,
                                                                size: 20,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),

                                                    const SizedBox(height: 16),

                                                    ColorPicker(
                                                      pickerColor:
                                                          pickedColors[activeColorIndex],
                                                      onColorChanged: (color) {
                                                        setStateDialog(() {
                                                          selectedColorValue =
                                                              color;
                                                          pickedColors[activeColorIndex] =
                                                              color;
                                                        });
                                                      },
                                                      enableAlpha: false,
                                                      displayThumbColor: true,
                                                    ),
                                                  ],
                                                );
                                              },
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
                                              Navigator.pop(context, {
                                                "name": controller.text.trim(),
                                                "color":
                                                    pickedColors[activeColorIndex],
                                                "colors": pickedColors,
                                              });
                                            },
                                            child: Text(l10n.save),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (result != null &&
                                      selectedBrand != null &&
                                      selectedMaterial != null &&
                                      selectedVariant != null) {
                                    final colorName = result["name"]
                                        ?.toString();
                                    final Color pickedColor =
                                        result["color"] as Color;
                                    final List<Color> pickedColorList =
                                        List<Color>.from(
                                          result["colors"] as List,
                                        );

                                    final customHex = pickedColorList
                                        .map(
                                          (color) =>
                                              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                        )
                                        .join('+');

                                    if (colorName != null &&
                                        colorName.isNotEmpty) {
                                      // 🔥 Farbe im Catalog hinzufügen
                                      FilamentCatalogService.addCustomColor(
                                        selectedBrand!,
                                        selectedMaterial!,
                                        selectedVariant!,
                                        colorName,
                                        customHex,
                                      );

                                      await CustomColorService.saveCustomColor(
                                        name: colorName,
                                        hex: customHex,
                                      );

                                      await FilamentCatalogService.saveCustomColors();

                                      // 🔥 Danach UI aktualisieren
                                      setState(() {
                                        // 🔥 Farben neu laden
                                        colors =
                                            FilamentCatalogService.getColors(
                                              selectedBrand!,
                                              selectedMaterial!,
                                              selectedVariant!,
                                            );

                                        // 🔥 preloadColorMap komplett neu aufbauen
                                        preloadColorMap.clear();

                                        for (var c in colors) {
                                          final loadedColors =
                                              FilamentCatalogService.getColorsFromHex(
                                                selectedBrand!,
                                                selectedMaterial!,
                                                selectedVariant!,
                                                c,
                                              );

                                          if (loadedColors.isNotEmpty) {
                                            final splitColors = c
                                                .split('+')
                                                .map((e) => e.trim())
                                                .toList();

                                            for (
                                              int i = 0;
                                              i < splitColors.length;
                                              i++
                                            ) {
                                              final colorName = splitColors[i];

                                              final key = buildColorKey(
                                                selectedBrand!,
                                                selectedMaterial!,
                                                selectedVariant!,
                                                colorName,
                                              );

                                              if (i < loadedColors.length) {
                                                preloadColorMap[key] =
                                                    loadedColors[i];
                                              } else {
                                                preloadColorMap[key] =
                                                    Colors.grey;
                                              }
                                            }
                                          } else {
                                            preloadColorMap[c] = Colors.grey;
                                          }
                                        }

                                        // 🔥 neue Farbe setzen
                                        preloadColorMap[colorName] =
                                            pickedColor;

                                        selectedColor = colorName;
                                        selectedColorValue = pickedColor;
                                      });
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  if (isMobile) ...[
                    const SizedBox(height: 24),

                    PrintSettingsSection(
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
                    ),

                    const SizedBox(height: 24),
                  ],

                  InventoryCostSection(
                    selectedSpoolWeight: selectedSpoolWeight,
                    totalWeightController: totalWeightController,
                    remainingWeightController: remainingWeightController,
                    priceController: priceController,
                    storageLocationController: storageLocationController,
                    storagePositionController: storagePositionController,

                    onSpoolWeightChanged: (value) {
                      setState(() {
                        selectedSpoolWeight = value;
                      });
                    },

                    onAdditionalSpoolsChanged: (values) {
                      additionalSpools = values;
                    },
                    onSave: saveFilament,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
