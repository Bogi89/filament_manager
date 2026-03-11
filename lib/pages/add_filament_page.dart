import 'package:flutter/material.dart';
import '../models/filament.dart';

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

  final TextEditingController brandSearchController = TextEditingController();
  final TextEditingController materialSearchController = TextEditingController();
  final TextEditingController variantSearchController = TextEditingController();

  final List<String> brands = [
    "Bambu Lab",
    "Prusament",
    "eSun",
    "Sunlu",
    "Soleyin"
  ];

  final List<String> materials = [
    "PLA",
    "PETG",
    "ABS",
    "TPU"
  ];

  final Map<String, List<String>> variantsByMaterial = {
    "PLA": ["Basic","Silk","Matte","Tough"],
    "PETG": ["Basic"],
    "ABS": ["Basic"],
    "TPU": ["Flex"]
  };

  final List<double> diameters = [1.75, 2.85, 3.0];

  final Map<String, Map<String, int>> materialTemps = {
    "PLA": {"nozzle": 200, "bed": 60},
    "PETG": {"nozzle": 240, "bed": 80},
    "ABS": {"nozzle": 250, "bed": 100},
    "TPU": {"nozzle": 220, "bed": 50},
  };

  String? selectedBrand;
  String? selectedMaterial;
  String? selectedVariant;
  double? selectedDiameter;

  int? nozzleTemp;
  int? bedTemp;

  final totalWeightController = TextEditingController();
  final remainingWeightController = TextEditingController();
  final priceController = TextEditingController();

  Color? selectedColor;

  @override
  void initState() {
    super.initState();

    if (widget.existingFilament != null) {
      final f = widget.existingFilament!;
      selectedBrand = f.brand;
      selectedMaterial = f.material;
      selectedVariant = f.variant;
      selectedDiameter = f.diameter;
      nozzleTemp = f.nozzleTemp;
      bedTemp = f.bedTemp;

      totalWeightController.text = f.totalWeight.toStringAsFixed(0);
      remainingWeightController.text = f.remainingWeight.toStringAsFixed(0);
      priceController.text = f.price.toStringAsFixed(2);
      selectedColor = f.color;
    }
  }

  void _onMaterialChanged(String material) {
    setState(() {
      selectedMaterial = material;
      selectedVariant = null;

      nozzleTemp = materialTemps[material]!["nozzle"];
      bedTemp = materialTemps[material]!["bed"];
    });
  }

  void saveFilament() {

    if (selectedBrand == null ||
        selectedMaterial == null ||
        selectedVariant == null ||
        selectedDiameter == null ||
        nozzleTemp == null ||
        bedTemp == null ||
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
      diameter: selectedDiameter!,
      totalWeight: totalWeight,
      remainingWeight: remainingWeight,
      price: price,
      nozzleTemp: nozzleTemp!,
      bedTemp: bedTemp!,
      color: selectedColor!,
    );

    widget.onSave(filament);

    Navigator.pop(context);
  }

  Widget colorSpool(Color color) {

    final isSelected = selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            width: isSelected ? 3 : 1,
            color: isSelected ? Colors.black : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget temperatureSelector(
      String label,
      int? value,
      Function(int) onChanged,
      int step) {

    if (value == null) {
      return const Text("Material auswählen");
    }

    return Column(
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
    );
  }

  @override
  Widget build(BuildContext context) {

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
              setState(() {
                selectedBrand = val;
              });
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
              if (val != null) {
                _onMaterialChanged(val);
              }
            },
          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(
            value: selectedVariant,
            hint: const Text("Variante"),
            items: selectedMaterial == null
                ? []
                : variantsByMaterial[selectedMaterial]!
                .map((v) => DropdownMenuItem(
              value: v,
              child: Text(v),
            ))
                .toList(),
            onChanged: (val) {
              setState(() {
                selectedVariant = val;
              });
            },
          ),

          const SizedBox(height:16),

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
                selectedDiameter = val;
              });
            },
          ),

          const SizedBox(height:30),

          const Text(
            "Farbe auswählen",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          Wrap(
            children: [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.black,
              Colors.white,
              Colors.orange,
              Colors.purple,
              Colors.grey,
            ].map(colorSpool).toList(),
          ),

          const SizedBox(height:30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              temperatureSelector(
                  "Nozzle",
                  nozzleTemp,
                      (v) => setState(() => nozzleTemp = v),
                  1
              ),

              temperatureSelector(
                  "Bed",
                  bedTemp,
                      (v) => setState(() => bedTemp = v),
                  5
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