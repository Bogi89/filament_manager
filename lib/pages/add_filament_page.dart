import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/filament.dart';
import '../services/filament_catalog_service.dart';

class AddFilamentPage extends StatefulWidget {
  final Filament? existingFilament;
  final Function(Filament) onSave;

  const AddFilamentPage({
    super.key,
    this.existingFilament,
    required this.onSave,
  });

  @override
  State<AddFilamentPage> createState() =>
      _AddFilamentPageState();
}

class _AddFilamentPageState
    extends State<AddFilamentPage> {

  bool catalogLoaded = false;

  String? selectedBrand;
  String? selectedMaterial;
  String? selectedVariant;
  String? selectedColor;
Color? selectedColorValue;

  final Map<String, Color> preloadColorMap = {};

  double? selectedDiameter;

  int? nozzleTemp;
  int? bedTemp;

  final totalWeightController =
      TextEditingController();

  final remainingWeightController =
      TextEditingController();

  final priceController =
      TextEditingController();

  List<String> brands = [];
  List<String> materials = [];
  List<String> variants = [];
  List<String> colors = [];

  final diameters = [1.75, 2.85, 3.0];

  final Map<String, Map<String, int>>
      materialTemps = {

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

    await FilamentCatalogService
        .loadCatalog();

    brands =
    FilamentCatalogService
        .getBrands()
        .toSet()
        .toList();

        print("BRANDS LOADED:");
for (var b in brands) {
  print(b);
}

if (selectedBrand != null &&
    !brands.contains(selectedBrand)) {

  selectedBrand = null;

}

setState(() {
  catalogLoaded = true;
});
  }

  void selectBrand(String brand) {

    selectedBrand = brand;

    materials =
        FilamentCatalogService
            .getMaterials(brand);

    selectedMaterial = null;
    selectedVariant = null;
    selectedColor = null;

    variants = [];
    colors = [];
    preloadColorMap.clear();

    setState(() {});
  }

  Future<void> _addBrandDialog() async {

  final controller =
      TextEditingController();

  final result =
    await showDialog<Map<String, dynamic>>(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
            "Neuer Hersteller"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText:
                "Herstellername",
          ),
          autofocus: true,
        ),

        actions: [

          TextButton(

            onPressed: () {
              Navigator.pop(context);
            },

            child:
                const Text("Abbrechen"),

          ),

          ElevatedButton(

            onPressed: () {

              final value =
                  controller.text.trim();

              if (value.isNotEmpty) {

                Navigator.pop(
                  context,
                  value,
                );

              }

            },

            child:
                const Text("Speichern"),

          ),

        ],

      );

    },

  );

  if (result != null) {

  FilamentCatalogService
    .addCustomBrand(result["name"]);

  setState(() {

    brands =
        FilamentCatalogService
            .getBrands();

    selectedBrand =
    result["name"];

  });

}

}

  void selectMaterial(String material) {

    selectedMaterial = material;

    variants =
        FilamentCatalogService
            .getVariants(
      selectedBrand!,
      material,
    );

    selectedVariant = null;
    selectedColor = null;

    colors = [];
    preloadColorMap.clear();

    if (materialTemps.containsKey(material)) {

      nozzleTemp =
      materialTemps[material]!["nozzle"];

      bedTemp =
      materialTemps[material]!["bed"];
    }

    setState(() {});
  }

  Future<void> _addMaterialDialog() async {

  final controller =
      TextEditingController();

  final result =
      await showDialog<String>(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
            "Neues Material"),

        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Materialname",
          ),
          autofocus: true,
        ),

        actions: [

          TextButton(

            onPressed: () {
              Navigator.pop(context);
            },

            child:
                const Text("Abbrechen"),

          ),

          ElevatedButton(

            onPressed: () {

              final value =
                  controller.text.trim();

              if (value.isNotEmpty) {

                Navigator.pop(
                  context,
                  value,
                );

              }

            },

            child:
                const Text("Speichern"),

          ),

        ],

      );

    },

  );

  if (result != null) {

    setState(() {

      materials.add(result);

      FilamentCatalogService.addCustomMaterial(
  selectedBrand!,
  result,
);

      materials =
          materials.toSet().toList();

      materials.sort();

      selectedMaterial =
          result;

    });

  }

}

  void selectVariant(String variant) {

    selectedVariant = variant;

    final newColors =
        FilamentCatalogService.getColors(
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

    final colorsFromHex =
    FilamentCatalogService.getColorsFromHex(
        selectedBrand!,
        selectedMaterial!,
        selectedVariant!,
        c,
    );

if (colorsFromHex.isNotEmpty) {
    preloadColorMap[c] = colorsFromHex.first;
} else {
    preloadColorMap[c] = Colors.grey;
}

  } else {

    preloadColorMap[c] = Colors.grey;

  }

}

    if (colors.isNotEmpty) {

      if (!colors.contains(selectedColor)) {

        selectedColor = colors.first;

      }

    } else {

      selectedColor = null;

    }

    setState(() {});
  }

  /// 🔧 RICHTIG außerhalb platziert
  Widget buildColorItem(String c) {

  final List<Color> parsedColors =
      preloadColorMap.containsKey(c)
          ? [preloadColorMap[c]!]
          : [Colors.grey];

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [

      ...parsedColors.map(
        (color) => Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),

      Text(
        c,
        overflow: TextOverflow.ellipsis,
      ),

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

    final totalWeight =
        double.tryParse(
            totalWeightController.text)
        ?? 0;

    final remainingWeight =
        double.tryParse(
            remainingWeightController.text)
        ?? totalWeight;

    final price =
        double.tryParse(
            priceController.text)
        ?? 0;

    final parsedColors =
    (selectedColor != null &&
     preloadColorMap.containsKey(selectedColor))
        ? [preloadColorMap[selectedColor]!]
        : [Colors.grey];

final List<String> colorNames = [];

if (selectedColor != null &&
    selectedColor!.trim().isNotEmpty) {
  colorNames.add(selectedColor!.trim());
}

if (colorNames.isNotEmpty &&
    colorNames.first == "Unknown" &&
    selectedColor != null &&
    selectedColor!.trim().isNotEmpty) {

  colorNames[0] = selectedColor!.trim();
}

    // DEBUG vor dem Erstellen
print("DEBUG variant: $selectedVariant");
print("DEBUG colorNames: $colorNames");

final filament = Filament(
  brand: selectedBrand!,
  material: selectedMaterial!,

  variant:
      (selectedVariant != null &&
              selectedVariant!.isNotEmpty)
          ? selectedVariant!
          : "Standard",

  diameter: selectedDiameter ?? 1.75,
  totalWeight: totalWeight,
  remainingWeight: remainingWeight,
  price: price,

  nozzleTemp: nozzleTemp ?? 0,
  bedTemp: bedTemp ?? 0,

  color: parsedColors.first,
  colors: parsedColors,

  colorNames: colorNames,

  colorType:
      parsedColors.length > 1
          ? "multi"
          : "single",
);

print("DEBUG colorNames: $colorNames");

    widget.onSave(filament);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    if (!catalogLoaded) {

      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title:
        const Text(
            "Filament hinzufügen"),
      ),

      body: ListView(
        padding:
        const EdgeInsets.all(20),

        children: [

          Row(
  children: [

    Expanded(
      child: DropdownButtonFormField<String>(
        value: selectedBrand,
        hint: const Text("Hersteller"),

        items: brands.map(
          (b) =>
              DropdownMenuItem(
                value: b,
                child: Text(b),
              ),
        ).toList(),

        onChanged: (val) {
          if (val != null) {
            selectBrand(val);
          }
        },
      ),
    ),

    const SizedBox(width: 8),

    IconButton(
      icon: const Icon(Icons.add),
      onPressed: _addBrandDialog,
      tooltip: "Neuen Hersteller hinzufügen",
    ),

  ],
),

          const SizedBox(height: 16),

          Row(
  children: [

    Expanded(
      child: DropdownButtonFormField<String>(
        value: selectedMaterial,
        hint: const Text("Material"),

        items: materials.map(
          (m) =>
              DropdownMenuItem(
                value: m,
                child: Text(m),
              ),
        ).toList(),

        onChanged: (val) {
          if (val != null) {
            selectMaterial(val);
          }
        },
      ),
    ),

    const SizedBox(width: 8),

    IconButton(
      icon: const Icon(Icons.add),
      onPressed: _addMaterialDialog,
      tooltip: "Neues Material hinzufügen",
    ),

  ],
),

          const SizedBox(height: 16),

          Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String>(
        value: selectedVariant,
        hint: const Text("Variante"),
        items: variants.map(
          (v) =>
              DropdownMenuItem(
                value: v,
                child: Text(v),
              ),
        ).toList(),
        onChanged: (val) {
          if (val != null) {
            selectVariant(val);
          }
        },
      ),
    ),

    const SizedBox(width: 8),

    IconButton(
      icon: const Icon(Icons.add),
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

            variants =
                variants.toSet().toList();

            variants.sort();

            selectedVariant =
                result;
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
      child: DropdownButtonFormField<String>(
        value: colors.contains(selectedColor)
            ? selectedColor
            : null,
        decoration:
            const InputDecoration(
          labelText: "Farbe",
        ),
        items: colors.map(
          (c) =>
              DropdownMenuItem(
                value: c,
                child: buildColorItem(c),
              ),
        ).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              selectedColor = val;
            });
          }
        },
      ),
    ),

    const SizedBox(width: 8),

    IconButton(
      icon: const Icon(Icons.add),
      onPressed: () async {
        final controller =
            TextEditingController();

            Color pickedColor = Colors.blue;

        final result =
    await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  const Text("Neue Farbe"),
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

    // 🎨 Vorschau-Kreis
    StatefulBuilder(
      builder: (context, setStateDialog) {
        return Column(
          children: [

            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selectedColorValue ?? Colors.blue,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 16),

            ColorPicker(
  pickerColor: selectedColorValue ?? Colors.blue,
              onColorChanged: (color) {
  setStateDialog(() {
    pickedColor = color;
    selectedColorValue = color;
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
                    Navigator.pop(
                        context);
                  },
                  child: const Text(
                      "Abbrechen"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
  context,
  {
    "name": controller.text.trim(),
    "color": pickedColor,
  },
);
                  },
                  child: const Text(
                      "Speichern"),
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

  if (colorName != null &&
      colorName.isNotEmpty &&
      pickedColor != null &&
      pickedColor is Color) {

    // 🔥 Farbe im Catalog hinzufügen
FilamentCatalogService.addCustomColor(
  selectedBrand!,
  selectedMaterial!,
  selectedVariant!,
  colorName,
  pickedColor,
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
      preloadColorMap[c] = loadedColors.first;
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
            value: selectedDiameter,
            hint:
            const Text("Durchmesser"),

            items: diameters.map(
                    (d) =>
                    DropdownMenuItem(
                      value: d,
                      child:
                      Text("$d mm"),
                    )).toList(),

            onChanged: (val) {

              if (val != null) {

                setState(() {
                  selectedDiameter = val;
                });

              }
            },
          ),

          const SizedBox(height: 30),

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
                  nozzleTemp =
                      (nozzleTemp ?? 0) - 1;
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
                  nozzleTemp =
                      (nozzleTemp ?? 0) + 1;
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
                  bedTemp =
                      (bedTemp ?? 0) - 5;
                });
              },
            ),

            Text(
              "${bedTemp != null ? "$bedTemp" : "-"} °C",
            ),

            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  bedTemp =
                      (bedTemp ?? 0) + 5;
                });
              },
            ),

          ],
        ),

      ],
    ),

  ],
),

          const SizedBox(height: 30),

          TextField(
            controller: totalWeightController,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
              labelText:
              "Spulengewicht (g)",
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller:
            remainingWeightController,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
              labelText:
              "Restgewicht (g)",
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: priceController,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
              labelText:
              "Preis (€)",
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: saveFilament,
            child:
            const Text("Speichern"),
          ),

        ],
      ),

    );
  }
}