import 'package:flutter/material.dart';
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

  Map<String, List<Color>>
      preloadedColorMap = {};

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
    preloadedColorMap.clear();

    setState(() {});
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
    preloadedColorMap.clear();

    if (materialTemps.containsKey(material)) {

      nozzleTemp =
      materialTemps[material]!["nozzle"];

      bedTemp =
      materialTemps[material]!["bed"];
    }

    setState(() {});
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
    preloadedColorMap.clear();

    for (var c in colors) {

  if (selectedBrand != null &&
      selectedMaterial != null &&
      selectedVariant != null) {

    preloadedColorMap[c] =
        FilamentCatalogService.getColorsFromHex(
      selectedBrand!,
      selectedMaterial!,
      selectedVariant!,
      c,
    );

  } else {

    preloadedColorMap[c] = [Colors.grey];

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

  final parsedColors =
      preloadedColorMap[c] ?? [Colors.grey];

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [

      ...parsedColors.take(3).map(
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
        preloadedColorMap[selectedColor!]
        ?? [Colors.grey];

    final filament = Filament(
      brand: selectedBrand!,
      material: selectedMaterial!,
      variant: selectedVariant!,
      diameter:
      selectedDiameter ?? 1.75,
      totalWeight: totalWeight,
      remainingWeight:
      remainingWeight,
      price: price,
      nozzleTemp:
      nozzleTemp ?? 0,
      bedTemp:
      bedTemp ?? 0,
      color: parsedColors.first,
      colors: parsedColors,
      colorType:
      parsedColors.length > 1
          ? "multi"
          : "single",
    );

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

          DropdownButtonFormField<String>(
            value: selectedBrand,
            hint:
            const Text("Hersteller"),

            items: brands.map(
                    (b) =>
                    DropdownMenuItem(
                      value: b,
                      child: Text(b),
                    )).toList(),

            onChanged: (val) {
              if (val != null) {
                selectBrand(val);
              }
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedMaterial,
            hint:
            const Text("Material"),

            items: materials.map(
                    (m) =>
                    DropdownMenuItem(
                      value: m,
                      child: Text(m),
                    )).toList(),

            onChanged: (val) {
              if (val != null) {
                selectMaterial(val);
              }
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedVariant,
            hint:
            const Text("Variante"),

            items: variants.map(
                    (v) =>
                    DropdownMenuItem(
                      value: v,
                      child: Text(v),
                    )).toList(),

            onChanged: (val) {
              if (val != null) {
                selectVariant(val);
              }
            },
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
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
                    )).toList(),

            onChanged: (val) {

              if (val != null) {

                setState(() {
                  selectedColor = val;
                });

              }
            },
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