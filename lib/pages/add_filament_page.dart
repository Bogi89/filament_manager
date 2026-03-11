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

  String? selectedBrand;
  String? selectedMaterial;
  String? selectedVariant;
  String? selectedColor;

  double selectedDiameter = 1.75;

  int nozzleTemp = 200;
  int bedTemp = 60;

  final totalWeightController = TextEditingController();
  final remainingWeightController = TextEditingController();
  final priceController = TextEditingController();

  List<String> materials = [];
  List<String> variants = [];
  List<String> colors = [];

  final diameters = [1.75, 2.85, 3.0];

  @override
  void initState() {
    super.initState();

    if (widget.existingFilament != null) {

      final f = widget.existingFilament!;

      selectedBrand = f.brand;
      selectedMaterial = f.material;
      selectedVariant = f.variant;

      totalWeightController.text = f.totalWeight.toString();
      remainingWeightController.text = f.remainingWeight.toString();
      priceController.text = f.price.toString();

      nozzleTemp = f.nozzleTemp;
      bedTemp = f.bedTemp;
    }
  }

  void updateMaterials(String brand) {

    materials = FilamentCatalogService.getMaterials(brand);

    selectedMaterial = null;
    selectedVariant = null;
    selectedColor = null;

    variants = [];
    colors = [];

    setState(() {});
  }

  void updateVariants(String material) {

    variants = FilamentCatalogService.getVariants(
        selectedBrand!, material);

    selectedVariant = null;
    selectedColor = null;

    colors = [];

    setState(() {});
  }

  void updateColors(String variant) {

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

    final filament = Filament(
      brand: selectedBrand!,
      material: selectedMaterial!,
      variant: selectedVariant!,
      diameter: selectedDiameter,
      totalWeight: totalWeight,
      remainingWeight: remainingWeight,
      price: price,
      nozzleTemp: nozzleTemp,
      bedTemp: bedTemp,
      color: _generateColorFromName(selectedColor!),
    );

    widget.onSave(filament);

    Navigator.pop(context);
  }

  Color _generateColorFromName(String name) {

    final n = name.toLowerCase();

    if (n.contains("black") || n.contains("schwarz")) {
      return Colors.black;
    }

    if (n.contains("white") || n.contains("weiß")) {
      return Colors.white;
    }

    if (n.contains("red") || n.contains("rot")) {
      return Colors.red;
    }

    if (n.contains("blue") || n.contains("blau")) {
      return Colors.blue;
    }

    if (n.contains("green") || n.contains("grün")) {
      return Colors.green;
    }

    if (n.contains("gray") || n.contains("grey") || n.contains("grau")) {
      return Colors.grey;
    }

    if (n.contains("orange")) {
      return Colors.orange;
    }

    if (n.contains("purple") || n.contains("violet")) {
      return Colors.purple;
    }

    if (n.contains("yellow") || n.contains("gelb")) {
      return Colors.yellow;
    }

    if (n.contains("pink")) {
      return Colors.pink;
    }

    if (n.contains("brown")) {
      return Colors.brown;
    }

    if (n.contains("silver")) {
      return Colors.grey.shade400;
    }

    if (n.contains("gold")) {
      return Colors.amber;
    }

    // Fallback wenn Farbe nicht erkannt wird
    final hash = name.hashCode;

    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = (hash & 0x0000FF);

    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {

    final brands = FilamentCatalogService.getBrands();

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
            items: brands
                .map((b) => DropdownMenuItem(
              value: b,
              child: Text(b),
            ))
                .toList(),
            onChanged: (val) {

              if (val == null) return;

              selectedBrand = val;

              updateMaterials(val);
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedMaterial,
            hint: const Text("Material"),
            items: materials
                .map((m) => DropdownMenuItem(
              value: m,
              child: Text(m),
            ))
                .toList(),
            onChanged: (val) {

              if (val == null) return;

              selectedMaterial = val;

              updateVariants(val);
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedVariant,
            hint: const Text("Variante"),
            items: variants
                .map((v) => DropdownMenuItem(
              value: v,
              child: Text(v),
            ))
                .toList(),
            onChanged: (val) {

              if (val == null) return;

              selectedVariant = val;

              updateColors(val);
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedColor,
            hint: const Text("Farbe"),
            items: colors
                .map((c) => DropdownMenuItem(
              value: c,
              child: Text(c),
            ))
                .toList(),
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
            items: diameters
                .map((d) => DropdownMenuItem(
              value: d,
              child: Text("$d mm"),
            ))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedDiameter = val!;
              });
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
                        onPressed: (){
                          setState(() {
                            nozzleTemp--;
                          });
                        },
                      ),

                      Text("$nozzleTemp °C"),

                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: (){
                          setState(() {
                            nozzleTemp++;
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
                        onPressed: (){
                          setState(() {
                            bedTemp -= 5;
                          });
                        },
                      ),

                      Text("$bedTemp °C"),

                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: (){
                          setState(() {
                            bedTemp += 5;
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
            decoration:
            const InputDecoration(labelText: "Spulengewicht (g)"),
          ),

          const SizedBox(height:16),

          TextField(
            controller: remainingWeightController,
            keyboardType: TextInputType.number,
            decoration:
            const InputDecoration(labelText: "Restgewicht (g)"),
          ),

          const SizedBox(height:16),

          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            decoration:
            const InputDecoration(labelText: "Preis (€)"),
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