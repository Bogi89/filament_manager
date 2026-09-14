import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../../services/filament_catalog_service.dart';
import '../../../services/custom_color_service.dart';
import '../../../models/filament_color.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../l10n/app_localizations.dart';

import '../widgets/aligned_add_button.dart';

class FilamentSection extends StatefulWidget {
  const FilamentSection({
    super.key,
    required this.brands,
    required this.materials,
    required this.variants,
    required this.colors,

    required this.selectedBrand,
    required this.selectedMaterial,
    required this.selectedVariant,
    required this.selectedColor,

    required this.onBrandChanged,
    required this.onMaterialChanged,
    required this.onVariantChanged,
    required this.onColorChanged,

    this.onAddBrand,
    this.onAddMaterial,
    this.onAddVariant,
    this.onAddColor,
  });

  final List<String> brands;
  final List<String> materials;
  final List<String> variants;
  final List<String> colors;

  final String? selectedBrand;
  final String? selectedMaterial;
  final String? selectedVariant;
  final String? selectedColor;
  final ValueChanged<String> onBrandChanged;
  final ValueChanged<String> onMaterialChanged;
  final ValueChanged<String> onVariantChanged;
  final ValueChanged<String> onColorChanged;
  final VoidCallback? onAddBrand;
  final VoidCallback? onAddMaterial;
  final VoidCallback? onAddVariant;
  final VoidCallback? onAddColor;

  @override
  State<FilamentSection> createState() => _FilamentSectionState();
}

class _FilamentSectionState extends State<FilamentSection> {
  String? selectedBrand;

  List<String> brands = [];

  final TextEditingController brandSearchController = TextEditingController();

  final TextEditingController materialSearchController =
      TextEditingController();

  final TextEditingController variantSearchController = TextEditingController();

  final TextEditingController colorSearchController = TextEditingController();

  String? selectedMaterial;
  String? selectedVariant;
  String? selectedColor;

  List<FilamentColor> selectedFilamentColors = [];
  List<String> materials = [];
  List<String> variants = [];
  List<String> colors = [];

  final Map<String, Color> preloadColorMap = {};

  String buildColorKey(
    String brand,
    String material,
    String variant,
    String colorName,
  ) {
    return "$brand|$material|$variant|$colorName";
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

        Flexible(child: Text(c, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Color? selectedColorValue;

  Future<void> _addColorDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final pickedColors = <Color>[selectedColorValue ?? Colors.blue];

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
                decoration: InputDecoration(hintText: l10n.colorName),
              ),

              const SizedBox(height: 16),

              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ...List.generate(pickedColors.length, (index) {
                            final isActive = index == activeColorIndex;

                            return GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  activeColorIndex = index;
                                  selectedColorValue = pickedColors[index];
                                });
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: pickedColors[index],
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey,
                                    width: isActive ? 3 : 1,
                                  ),
                                ),
                              ),
                            );
                          }),

                          if (pickedColors.length < 4)
                            GestureDetector(
                              onTap: () {
                                setStateDialog(() {
                                  pickedColors.add(Colors.blue);

                                  activeColorIndex = pickedColors.length - 1;

                                  selectedColorValue =
                                      pickedColors[activeColorIndex];
                                });
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(Icons.add, size: 20),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      ColorPicker(
                        pickerColor: pickedColors[activeColorIndex],
                        onColorChanged: (color) {
                          setStateDialog(() {
                            selectedColorValue = color;
                            pickedColors[activeColorIndex] = color;
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
                  "color": pickedColors[activeColorIndex],
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
      final colorName = result["name"]?.toString();
      final Color pickedColor = result["color"] as Color;
      final List<Color> pickedColorList = List<Color>.from(
        result["colors"] as List,
      );

      final customHex = pickedColorList
          .map(
            (color) =>
                '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          )
          .join('+');

      if (colorName != null && colorName.isNotEmpty) {
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

        setState(() {
          colors = FilamentCatalogService.getColors(
            selectedBrand!,
            selectedMaterial!,
            selectedVariant!,
          );

          preloadColorMap.clear();

          for (var c in colors) {
            final loadedColors = FilamentCatalogService.getColorsFromHex(
              selectedBrand!,
              selectedMaterial!,
              selectedVariant!,
              c,
            );

            if (loadedColors.isNotEmpty) {
              final splitColors = c.split('+').map((e) => e.trim()).toList();

              for (int i = 0; i < splitColors.length; i++) {
                final colorEntry = splitColors[i];

                final key = buildColorKey(
                  selectedBrand!,
                  selectedMaterial!,
                  selectedVariant!,
                  colorEntry,
                );

                preloadColorMap[key] = i < loadedColors.length
                    ? loadedColors[i]
                    : Colors.grey;
              }
            } else {
              preloadColorMap[c] = Colors.grey;
            }
          }

          preloadColorMap[colorName] = pickedColor;

          selectedColor = colorName;
          selectedColorValue = pickedColor;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadBrands() async {}

  @override
  void dispose() {
    brandSearchController.dispose();
    materialSearchController.dispose();
    variantSearchController.dispose();
    colorSearchController.dispose();
    super.dispose();
  }

  void selectBrand(String brand) {
    widget.onBrandChanged(brand);

    materials = FilamentCatalogService.getMaterials(brand);

    selectedMaterial = null;
    selectedVariant = null;
    selectedColor = null;

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

    colors = [];
    preloadColorMap.clear();

    setState(() {});
  }

  Future<void> _addBrandDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

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
      setState(() {
        brands.add(result);
        brands = brands.toSet().toList();
        brands.sort();
        selectedBrand = result;
      });
    }
  }

  Future<void> _addMaterialDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

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

    setState(() {});
  }

  Future<void> _addVariantDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.newVariant),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: l10n.variantName),
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
                Navigator.pop(context, controller.text.trim());
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: Theme.of(context).brightness == Brightness.dark
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
          const Text(
            "Filament",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: DropdownSearch<String>(
                  items: (filter, infiniteScrollProps) => widget.brands,
                  selectedItem: widget.selectedBrand,
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
                      widget.onBrandChanged(value);
                    }
                  },
                ),
              ),

              AlignedAddButton(
                onPressed: widget.onAddBrand ?? _addBrandDialog,
                tooltip: l10n.add,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownSearch<String>(
                  items: (filter, infiniteScrollProps) => materials,
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
                      widget.onMaterialChanged(value);
                    }
                  },
                ),
              ),

              AlignedAddButton(
                onPressed: widget.onAddMaterial ?? _addMaterialDialog,
                tooltip: l10n.add,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownSearch<String>(
                  items: (filter, infiniteScrollProps) => variants,
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
                      widget.onVariantChanged(value);
                    }
                  },
                ),
              ),

              AlignedAddButton(
                onPressed: widget.onAddVariant ?? _addVariantDialog,
                tooltip: l10n.add,
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DropdownSearch<String>(
                  items: (filter, infiniteScrollProps) => colors,
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
                    itemBuilder: (context, item, isDisabled, isSelected) {
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
                      widget.onColorChanged(val);
                    }
                  },
                ),
              ),

              AlignedAddButton(
                onPressed: widget.onAddColor ?? _addColorDialog,
                tooltip: l10n.add,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
