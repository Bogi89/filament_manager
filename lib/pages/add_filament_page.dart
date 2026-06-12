import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/filament.dart';
import '../services/filament_catalog_service.dart';
import '../services/custom_color_service.dart';
import '../models/filament_color.dart';

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

  int? nozzleTemp;
  int? bedTemp;

  final totalWeightController = TextEditingController();

  final remainingWeightController = TextEditingController();

  final priceController = TextEditingController();

  String? selectedSpoolWeight;

  List<String> brands = [];
  List<String> materials = [];
  List<String> variants = [];
  List<String> colors = [];

  final diameters = [1.75, 2.85, 3.0];

  final Map<String, Map<String, int>> materialTemps = {
    "PLA": {"nozzle": 200, "bed": 60},
    "PLA+": {"nozzle": 210, "bed": 60},
    "PLA CF": {"nozzle": 210, "bed": 60},

    "PETG": {"nozzle": 240, "bed": 80},
    "PETG+": {"nozzle": 245, "bed": 80},

    "ABS": {"nozzle": 250, "bed": 100},
    "ABS+": {"nozzle": 255, "bed": 100},

    "ASA": {"nozzle": 250, "bed": 100},

    "TPU": {"nozzle": 220, "bed": 50},

    "PET": {"nozzle": 235, "bed": 70},

    "PC": {"nozzle": 270, "bed": 110},

    "PA": {"nozzle": 260, "bed": 90},
  };

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

  void selectBrand(String brand) {
    selectedBrand = brand;

    materials = FilamentCatalogService.getMaterials(brand);

    selectedMaterial = null;
    selectedVariant = null;
    selectedColor = null;

    variants = [];
    colors = [];
    preloadColorMap.clear();

    setState(() {});
  }

  Future<void> _addBrandDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Neuer Hersteller"),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Herstellername"),
            autofocus: true,
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
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },

              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      FilamentCatalogService.addCustomBrand(result["name"]);

      setState(() {
        brands = FilamentCatalogService.getBrands();

        selectedBrand = result["name"];
      });
    }
  }

  void selectMaterial(String material) {
    selectedMaterial = material;

    variants = FilamentCatalogService.getVariants(selectedBrand!, material);

    selectedVariant = null;
    selectedColor = null;

    colors = [];
    preloadColorMap.clear();

    if (materialTemps.containsKey(material)) {
      nozzleTemp = materialTemps[material]!["nozzle"];

      bedTemp = materialTemps[material]!["bed"];
    }

    setState(() {});
  }

  Future<void> _addMaterialDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text("Neues Material"),

          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Materialname"),
            autofocus: true,
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
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },

              child: const Text("Speichern"),
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

  Widget buildAlignedAddButton({required VoidCallback? onPressed}) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        splashRadius: 24,
        tooltip: "Hinzufügen",
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

        Flexible(child: Text(c, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  void saveFilament() {
    if (selectedBrand == null ||
        selectedMaterial == null ||
        selectedVariant == null ||
        selectedColor == null) {
      return;
    }

    final totalWeight = double.tryParse(totalWeightController.text) ?? 0;

    final remainingWeight =
        double.tryParse(remainingWeightController.text) ?? totalWeight;

    final price = double.tryParse(priceController.text) ?? 0;

    final List<Color> parsedColors = FilamentCatalogService.getColorsFromHex(
      selectedBrand!,
      selectedMaterial!,
      selectedVariant!,
      selectedColor!,
    );

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
      totalWeight: totalWeight,
      remainingWeight: remainingWeight,
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
          name: colorNames.isNotEmpty ? colorNames.first : "Unknown",
          hex:
              '#${parsedColors[index].toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          isCustom: false,
        ),
      ),

      colorType: parsedColors.length > 1 ? "multi" : "single",
    );

    widget.onSave(filament);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!catalogLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Filament hinzufügen")),

      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),

            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownSearch<String>(
                      items: (filter, infiniteScrollProps) => brands,
                      selectedItem: selectedBrand,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Hersteller suchen...",
                            suffixIcon: Icon(Icons.clear),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: "Hersteller",
                          border: OutlineInputBorder(),
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

                  const SizedBox(width: 8),
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
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Material suchen...",
                            suffixIcon: Icon(Icons.clear),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: "Material",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) {
                          selectMaterial(value);
                        }
                      },
                    ),
                  ),

                  buildAlignedAddButton(onPressed: _addMaterialDialog),

                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 96,
                    child: DropdownSearch<String>(
                      items: (filter, infiniteScrollProps) => variants,
                      selectedItem: selectedVariant,
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Variante suchen...",
                            suffixIcon: Icon(Icons.clear),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          hintText: "Variante",
                          border: OutlineInputBorder(),
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
                            title: const Text("Neue Variante"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Variantenname",
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
                                  Navigator.pop(
                                    context,
                                    controller.text.trim(),
                                  );
                                },
                                child: const Text("Speichern"),
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
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 96,
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
                        searchFieldProps: const TextFieldProps(
                          decoration: InputDecoration(
                            hintText: "Farbe suchen...",
                            suffixIcon: Icon(Icons.clear),
                          ),
                        ),
                      ),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: "Farbe",
                          border: OutlineInputBorder(),
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

                            final selectedCatalogColor = catalogColors
                                .where(
                                  (catalogColor) =>
                                      catalogColor.split('|').first.trim() ==
                                      val.trim(),
                                )
                                .toList();

                            if (selectedCatalogColor.isNotEmpty) {
                              final parts = selectedCatalogColor.first.split(
                                '|',
                              );

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
                            title: const Text("Neue Farbe"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: controller,
                                  decoration: const InputDecoration(
                                    hintText: "Farbname",
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
                                          alignment: WrapAlignment.center,
                                          children: [
                                            ...List.generate(
                                              pickedColors.length,
                                              (index) {
                                                final isActive =
                                                    index == activeColorIndex;

                                                return GestureDetector(
                                                  onTap: () {
                                                    setStateDialog(() {
                                                      activeColorIndex = index;
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
                                              },
                                            ),
                                            if (pickedColors.length < 4)
                                              GestureDetector(
                                                onTap: () {
                                                  setStateDialog(() {
                                                    pickedColors.add(
                                                      Colors.blue,
                                                    );
                                                    activeColorIndex =
                                                        pickedColors.length - 1;
                                                    selectedColorValue =
                                                        pickedColors[activeColorIndex];
                                                  });
                                                },
                                                child: Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.grey,
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
                                              selectedColorValue = color;
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
                                child: const Text("Abbrechen"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context, {
                                    "name": controller.text.trim(),
                                    "color": pickedColors[activeColorIndex],
                                    "colors": pickedColors,
                                  });
                                },
                                child: const Text("Speichern"),
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
                                  '#{color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                            )
                            .join('+');

                        if (colorName != null && colorName.isNotEmpty) {
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
                            colors = FilamentCatalogService.getColors(
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

                                for (int i = 0; i < splitColors.length; i++) {
                                  final colorName = splitColors[i];

                                  final key = buildColorKey(
                                    selectedBrand!,
                                    selectedMaterial!,
                                    selectedVariant!,
                                    colorName,
                                  );

                                  if (i < loadedColors.length) {
                                    preloadColorMap[key] = loadedColors[i];
                                  } else {
                                    preloadColorMap[key] = Colors.grey;
                                  }
                                }
                              } else {
                                preloadColorMap[c] = Colors.grey;
                              }
                            }

                            // 🔥 neue Farbe setzen
                            preloadColorMap[colorName] = pickedColor;

                            selectedColor = colorName;
                            selectedColorValue = pickedColor;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<double>(
                initialValue: selectedDiameter,
                hint: const Text("Durchmesser"),

                items: diameters
                    .map(
                      (d) => DropdownMenuItem(value: d, child: Text("$d mm")),
                    )
                    .toList(),

                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedDiameter = val;
                    });
                  }
                },
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Text("Nozzle"),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                nozzleTemp = (nozzleTemp ?? 0) - 1;
                              });
                            },
                          ),

                          Text(
                            "${nozzleTemp != null ? "$nozzleTemp" : "-"} °C",
                          ),

                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                nozzleTemp = (nozzleTemp ?? 0) + 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      const Text("Bed"),

                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                bedTemp = (bedTemp ?? 0) - 5;
                              });
                            },
                          ),

                          Text("${bedTemp != null ? "$bedTemp" : "-"} °C"),

                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                bedTemp = (bedTemp ?? 0) + 5;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: selectedSpoolWeight,
                decoration: const InputDecoration(
                  labelText: "Spulengewicht (g)",
                ),
                items: [
                  DropdownMenuItem(
                    value: "custom",
                    child: Text(
                      selectedSpoolWeight == "custom" &&
                              totalWeightController.text.isNotEmpty
                          ? "${totalWeightController.text} g"
                          : "Benutzerdefiniert...",
                    ),
                  ),
                  DropdownMenuItem(value: "250", child: Text("250 g")),
                  DropdownMenuItem(value: "500", child: Text("500 g")),
                  DropdownMenuItem(value: "800", child: Text("800 g")),
                  DropdownMenuItem(value: "1000", child: Text("1000 g")),
                  DropdownMenuItem(value: "2000", child: Text("2000 g")),
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
                        selectedSpoolWeight = "custom";
                        totalWeightController.text = result;
                      });
                    }
                  } else {
                    setState(() {
                      selectedSpoolWeight = value;
                      totalWeightController.text = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextField(
                controller: remainingWeightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Restgewicht (g)"),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Preis (€)"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: saveFilament,
                child: const Text("Speichern"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
