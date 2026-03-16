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
  State<AddFilamentPage> createState() => _AddFilamentPageState();
}

class _AddFilamentPageState extends State<AddFilamentPage> {

  bool catalogLoaded = false;

  String? selectedBrand;
  String? selectedMaterial;
  String? selectedVariant;
  String? selectedColor;

  double? selectedDiameter;

  int? nozzleTemp;
  int? bedTemp;

  final totalWeightController = TextEditingController();
  final remainingWeightController = TextEditingController();
  final priceController = TextEditingController();

  List<String> brands = [];
  List<String> materials = [];
  List<String> variants = [];
  List<String> colors = [];

  final diameters = [1.75, 2.85, 3.0];

  final Map<String, Map<String, int>> materialTemps = {
    "PLA": {"nozzle": 200, "bed": 60},
    "PETG": {"nozzle": 240, "bed": 80},
    "ABS": {"nozzle": 250, "bed": 100},
    "TPU": {"nozzle": 220, "bed": 50},
  };

  @override
  void initState() {
    super.initState();
    loadCatalog();
  }

  Future<void> loadCatalog() async {

    await FilamentCatalogService.loadCatalog();

    brands = FilamentCatalogService.getBrands();

    if (widget.existingFilament != null) {

      final f = widget.existingFilament!;

      selectedBrand = f.brand;
      selectedMaterial = f.material;
      selectedVariant = f.variant;
      selectedDiameter = f.diameter;

      nozzleTemp = f.nozzleTemp;
      bedTemp = f.bedTemp;

      totalWeightController.text = f.totalWeight.toString();
      remainingWeightController.text = f.remainingWeight.toString();
      priceController.text = f.price.toString();

      materials = FilamentCatalogService.getMaterials(selectedBrand!);
      variants = FilamentCatalogService.getVariants(selectedBrand!, selectedMaterial!);
      colors = FilamentCatalogService.getColors(selectedBrand!, selectedMaterial!, selectedVariant!);
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

    setState(() {});
  }

  void selectMaterial(String material) {

    selectedMaterial = material;

    variants = FilamentCatalogService.getVariants(selectedBrand!, material);

    selectedVariant = null;
    selectedColor = null;

    colors = [];

    if (materialTemps.containsKey(material)) {

      nozzleTemp = materialTemps[material]!["nozzle"];
      bedTemp = materialTemps[material]!["bed"];

    }

    setState(() {});
  }

  void selectVariant(String variant) {

    selectedVariant = variant;

    colors = FilamentCatalogService.getColors(
        selectedBrand!,
        selectedMaterial!,
        variant);

    selectedColor = null;

    setState(() {});
  }

  void saveFilament() {

    if (selectedBrand == null ||
        selectedMaterial == null ||
        selectedVariant == null ||
        selectedColor == null) {
      return;
    }

    final totalWeight =
        double.tryParse(totalWeightController.text) ?? 0;

    final remainingWeight =
        double.tryParse(remainingWeightController.text) ?? totalWeight;

    final price =
        double.tryParse(priceController.text) ?? 0;

    final colorValue = _generateColorFromName(selectedColor!);

    final filament = Filament(
      brand: selectedBrand!,
      material: selectedMaterial!,
      variant: selectedVariant!,
      diameter: selectedDiameter ?? 1.75,
      totalWeight: totalWeight,
      remainingWeight: remainingWeight,
      price: price,
      nozzleTemp: nozzleTemp ?? 0,
      bedTemp: bedTemp ?? 0,
      color: colorValue,
      colors: [colorValue],
      colorType: "single",
    );

    widget.onSave(filament);

    Navigator.pop(context);
  }

  Color _generateColorFromName(String name) {

    final n = name.trim().toLowerCase();

    if (n.contains("black") || n.contains("schwarz")) return Colors.black;
    if (n.contains("white") || n.contains("weiß") || n.contains("weiss")) return Colors.white;
    if (n.contains("red") || n.contains("rot")) return Colors.red;
    if (n.contains("blue") || n.contains("blau")) return Colors.blue;
    if (n.contains("green") || n.contains("grün")) return Colors.green;
    if (n.contains("yellow") || n.contains("gelb")) return Colors.yellow;
    if (n.contains("orange")) return Colors.orange;
    if (n.contains("purple") || n.contains("violet")) return Colors.purple;
    if (n.contains("pink")) return Colors.pink;
    if (n.contains("brown") || n.contains("braun")) return Colors.brown;
    if (n.contains("gray") || n.contains("grey") || n.contains("grau")) return Colors.grey;

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {

    if (!catalogLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Filament hinzufügen"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          DropdownButtonFormField<String>(
            value: selectedBrand,
            hint: const Text("Hersteller"),
            items: brands.map((b) =>
                DropdownMenuItem(
                  value: b,
                  child: Text(b),
                )).toList(),
            onChanged: (val) {
              if (val != null) selectBrand(val);
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedMaterial,
            hint: const Text("Material"),
            items: materials.map((m) =>
                DropdownMenuItem(
                  value: m,
                  child: Text(m),
                )).toList(),
            onChanged: (val) {
              if (val != null) selectMaterial(val);
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedVariant,
            hint: const Text("Variante"),
            items: variants.map((v) =>
                DropdownMenuItem(
                  value: v,
                  child: Text(v),
                )).toList(),
            onChanged: (val) {
              if (val != null) selectVariant(val);
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedColor,
            hint: const Text("Farbe"),
            items: colors.map((c) {

              final color = _generateColorFromName(c);

              return DropdownMenuItem(
                value: c,
                child: Row(
                  children: [

                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(right:8),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12),
                      ),
                    ),

                    Text(c),

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

          const SizedBox(height:20),

          DropdownButtonFormField<double>(
            value: selectedDiameter,
            hint: const Text("Durchmesser"),
            items: diameters.map((d) =>
                DropdownMenuItem(
                  value: d,
                  child: Text("$d mm"),
                )).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedDiameter = val;
                });
              }
            },
          ),

          const SizedBox(height:30),

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

                      Text("${nozzleTemp ?? "--"} °C"),

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

                      Text("${bedTemp ?? "--"} °C"),

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

          const SizedBox(height:30),

          TextField(
            controller: totalWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Spulengewicht (g)"),
          ),

          const SizedBox(height:16),

          TextField(
            controller: remainingWeightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Restgewicht (g)"),
          ),

          const SizedBox(height:16),

          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Preis (€)"),
          ),

          const SizedBox(height:30),

          ElevatedButton(
            onPressed: saveFilament,
            child: const Text("Speichern"),
          ),

        ],
      ),
    );
  }
}
