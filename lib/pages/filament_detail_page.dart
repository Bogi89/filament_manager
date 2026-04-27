import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../models/spool.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../services/color_registry.dart';
import '../services/filament_catalog_service.dart';

class FilamentDetailPage extends StatefulWidget {
  final Filament filament;

  const FilamentDetailPage({
    super.key,
    required this.filament,
  });

  @override
  State<FilamentDetailPage> createState() => _FilamentDetailPageState();
}

class _FilamentDetailPageState extends State<FilamentDetailPage> {

  final List<String> brands = [
    "Bambu Lab",
    "Prusament",
    "Soleyin",
    "eSun",
    "Sunlu"
  ];

  final List<String> materials = [
    "PLA",
    "PETG",
    "ABS",
    "TPU"
  ];

  final List<double> diameters = [
    1.75,
    2.85,
    3.0
  ];

  final Map<String,List<String>> variantsByMaterial = {

    "PLA":[
      "Basic",
      "Standard",
      "Ultra",
      "Silk",
      "Matt",
      "Tough"
    ],

    "PETG":[
      "Basic",
      "Standard",
      "Carbon"
    ],

    "ABS":[
      "Basic",
      "Standard"
    ],

    "TPU":[
      "Flex 95A"
    ]

  };

  final Map<String,Map<String,int>> materialTemps = {

    "PLA":{"nozzle":200,"bed":60},
    "PETG":{"nozzle":240,"bed":80},
    "ABS":{"nozzle":250,"bed":100},
    "TPU":{"nozzle":220,"bed":50}

  };

  String? selectedBrand;
String? selectedMaterial;
String? selectedVariant;
String? selectedColor;
double? selectedDiameter;

List<String> colorNamesList = [];

  int? nozzleTemp;
  int? bedTemp;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {

    super.initState();

    final f = widget.filament;

print("DEBUG f.colorNames: ${f.colorNames}");

selectedColor =
    f.colorNames.isNotEmpty ? f.colorNames.first : null;

colorNamesList =
    FilamentCatalogService.getColorsForVariant(
        f.brand,
        f.material,
        f.variant,
    );

    /// 🔴 WICHTIG: Werte absichern

    /// Hersteller sicherstellen

if (!brands.contains(f.brand)) {
  brands.add(f.brand);
}

selectedBrand = f.brand;

    selectedMaterial =
        materials.contains(f.material)
            ? f.material
            : null;

    selectedDiameter =
        diameters.contains(f.diameter)
            ? f.diameter
            : null;

    selectedVariant = f.variant;

    nozzleTemp = f.nozzleTemp;
    bedTemp = f.bedTemp;

    priceController.text = f.price.toString();
    weightController.text = f.remainingWeight.toString();

    /// Variante absichern

    if(selectedMaterial != null){

      final list =
          variantsByMaterial[selectedMaterial]!;

      if(selectedVariant != null &&
          !list.contains(selectedVariant)){

        list.add(selectedVariant!);

      }

    }

  }

  void _onMaterialChanged(String material){

    setState(() {

      selectedMaterial = material;
      selectedVariant = null;

      nozzleTemp =
          materialTemps[material]!["nozzle"];

      bedTemp =
          materialTemps[material]!["bed"];

    });

  }

  Widget temperatureSelector(
      String label,
      int? value,
      Function(int) onChanged,
      int step){

    if(value == null){
      return const Text("Material auswählen");
    }

    return Column(
      children: [

        Text(label),

        Row(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [

            IconButton(
              icon: const Icon(Icons.remove),
              onPressed:
                  ()=>onChanged(value-step),
            ),

            Text(
              "$value °C",
              style: const TextStyle(
                  fontSize:18,
                  fontWeight: FontWeight.bold
              ),
            ),

            IconButton(
              icon: const Icon(Icons.add),
              onPressed:
                  ()=>onChanged(value+step),
            ),

          ],
        )

      ],
    );

  }

  void save() {

  final appState =
      context.read<AppState>();

  final f = widget.filament;

  /// Basisdaten speichern

  f.brand =
      selectedBrand ?? f.brand;

  f.material =
      selectedMaterial ?? f.material;

  f.variant =
      selectedVariant ?? f.variant;

  f.diameter =
      selectedDiameter ?? f.diameter;

  f.nozzleTemp =
      nozzleTemp ?? f.nozzleTemp;

  f.bedTemp =
      bedTemp ?? f.bedTemp;

  f.price =
      double.tryParse(
          priceController.text)
      ?? f.price;

  /// 🧵 Restgewicht aus Spools berechnen

  double remainingWeight =
      f.spools.fold(
          0,
          (sum, spool) =>
              sum + spool.weight);

  f.remainingWeight =
    remainingWeight;

f.colorNames =
    selectedColor != null
        ? [selectedColor!]
        : ["Unknown"];

/// Farbe neu berechnen für Punkt
final detectedColors =
    ColorRegistry.getColors(
        f.colorNames.first);

if (detectedColors.isNotEmpty) {

  f.color = detectedColors.first;

  f.colors = detectedColors;

}

/// 🔥 FILAMENT SPEICHERN
appState.updateFilament(f);

Navigator.pop(context);

}

  @override
  Widget build(BuildContext context) {

    final filament = widget.filament;

    return Scaffold(

      appBar: AppBar(
        title:
        const Text("Filament bearbeiten"),
      ),

      body: ListView(

        padding:
        const EdgeInsets.all(20),

        children: [

          Center(
            child: Container(
              width:120,
              height:120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filament.color,
              ),
              child: const Center(
                child: CircleAvatar(
                  radius:25,
                  backgroundColor:
                  Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height:30),

          DropdownButtonFormField<String>(

            value:
            brands.contains(selectedBrand)
                ? selectedBrand
                : null,

            decoration:
            const InputDecoration(
                labelText:"Hersteller"),

            items: brands
                .map((b)=>DropdownMenuItem(
              value:b,
              child: Text(b),
            ))
                .toList(),

            onChanged:(val){
              setState(
                      ()=>selectedBrand=val);
            },

          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(

            value:
            materials.contains(selectedMaterial)
                ? selectedMaterial
                : null,

            decoration:
            const InputDecoration(
                labelText:"Material"),

            items: materials
                .map((m)=>DropdownMenuItem(
              value:m,
              child: Text(m),
            ))
                .toList(),

            onChanged:(val){

              if(val!=null){

                _onMaterialChanged(val);

              }

            },

          ),

          const SizedBox(height:16),

          DropdownButtonFormField<String>(

            value:
            selectedMaterial!=null &&
                variantsByMaterial[selectedMaterial]!
                    .contains(selectedVariant)
                ? selectedVariant
                : null,

            decoration:
            const InputDecoration(
                labelText:"Variante"),

            items:
            selectedMaterial==null
                ? []
                : variantsByMaterial[selectedMaterial]!
                .map((v)=>DropdownMenuItem(
              value:v,
              child: Text(v),
            ))
                .toList(),

            onChanged:(val){
              setState(
                      ()=>selectedVariant=val);
            },

          ),

          const SizedBox(height:16),

DropdownButtonFormField<String>(
  value: colorNamesList.contains(selectedColor)
    ? selectedColor
    : null,

  decoration: const InputDecoration(
    labelText: "Farbe",
  ),

  items: colorNamesList
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

          const SizedBox(height:16),

          DropdownButtonFormField<double>(

            value:
            diameters.contains(selectedDiameter)
                ? selectedDiameter
                : null,

            decoration:
            const InputDecoration(
                labelText:"Durchmesser"),

            items: diameters
                .map((d)=>DropdownMenuItem(
              value:d,
              child: Text("$d mm"),
            ))
                .toList(),

            onChanged:(val){
              setState(
                      ()=>selectedDiameter=val);
            },

          ),

          const SizedBox(height:30),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,
            children: [

              temperatureSelector(
                  "Nozzle",
                  nozzleTemp,
                      (v)=>setState(
                          ()=>nozzleTemp=v),
                  1
              ),

              temperatureSelector(
                  "Bed",
                  bedTemp,
                      (v)=>setState(
                          ()=>bedTemp=v),
                  5
              ),

            ],
          ),

          const SizedBox(height:30),

          TextField(
            controller: priceController,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
                labelText:"Preis (€)"),
          ),

          const SizedBox(height:16),

          TextField(
            controller: weightController,
            keyboardType:
            TextInputType.number,
            decoration:
            const InputDecoration(
                labelText:"Restgewicht (g)"),
          ),

          const SizedBox(height: 30),

/// 🧵 Spulen-Bereich

Text(
  "Spulen",
  style: const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
),

const SizedBox(height: 12),

Column(
  children: widget.filament.spools
      .asMap()
      .entries
      .map((entry) {

    final index = entry.key;
    final spool = entry.value;

    return Container(
  margin: const EdgeInsets.only(
    bottom: 8,
  ),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    borderRadius:
        BorderRadius.circular(10),
    color:
        Colors.grey.shade100,
  ),
  child: Row(
    children: [

      const Icon(
        Icons.circle,
        size: 16,
      ),

      const SizedBox(width: 10),

      Text(
        "Spool ${index + 1}",
      ),

      const Spacer(),

      Text(
        "${spool.weight.toInt()} g",
        style: const TextStyle(
          fontWeight:
              FontWeight.bold,
        ),
      ),

      const SizedBox(width: 12),

      /// ✏️ Bearbeiten

      IconButton(

        icon: const Icon(
          Icons.edit,
          size: 18,
        ),

        onPressed: () async {

          final controller =
              TextEditingController(
            text:
                spool.weight
                    .toInt()
                    .toString(),
          );

          final result =
              await showDialog<double>(

            context: context,

            builder: (context) {

              return AlertDialog(

                title:
                    const Text(
                        "Spule bearbeiten"),

                content:
                    TextField(
                  controller:
                      controller,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Gewicht (g)",
                  ),
                ),

                actions: [

                  TextButton(

                    onPressed: () {

                      Navigator.pop(
                          context);
                    },

                    child:
                        const Text(
                            "Abbrechen"),

                  ),

                  ElevatedButton(

                    onPressed: () {

                      final weight =
                          double.tryParse(
                              controller.text);

                      if (weight != null &&
                          weight > 0) {

                        Navigator.pop(
                            context,
                            weight);
                      }

                    },

                    child:
                        const Text(
                            "Speichern"),

                  ),

                ],

              );

            },

          );

          if (result != null) {

  setState(() {

    spool.weight =
        result;

    /// Restgewicht neu berechnen

    double total = 0;

    for (final s
        in widget.filament.spools) {

      total += s.weight;

    }

    weightController.text =
        total.toString();

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

    final spools =
        widget.filament.spools;

    /// 🧵 Wenn letzte Spule

    if (spools.length == 1) {

      final confirm =
          await showDialog<bool>(

        context: context,

        builder: (context) {

          return AlertDialog(

            title: const Text(
              "Letzte Spule löschen",
            ),

            content: const Text(
              "Dieses Filament enthält danach "
              "keine Spulen mehr.\n\n"
              "Filament komplett löschen?",
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(
                      context,
                      false);
                },

                child:
                    const Text(
                        "Abbrechen"),

              ),

              ElevatedButton(

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),

                onPressed: () {

                  Navigator.pop(
                      context,
                      true);
                },

                child: const Text(
                  "Löschen & Filament entfernen",
                ),

              ),

            ],

          );

        },

      );

      if (confirm == true) {

        final appState =
            context.read<AppState>();

        appState.removeFilament(
            widget.filament);

        Navigator.pop(context);

      }

    }

    /// 🧵 Normales Löschen

    else {

      final confirm =
          await showDialog<bool>(

        context: context,

        builder: (context) {

          return AlertDialog(

            title:
                const Text(
                    "Spule löschen"),

            content:
                Text(
              "Spule ${index + 1} wirklich löschen?",
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(
                      context,
                      false);
                },

                child:
                    const Text(
                        "Abbrechen"),

              ),

              ElevatedButton(

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,
                ),

                onPressed: () {

                  Navigator.pop(
                      context,
                      true);
                },

                child:
                    const Text(
                        "Löschen"),

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

          weightController.text =
              total.toString();

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

    final controller =
        TextEditingController();

    final result =
        await showDialog<double>(

      context: context,

      builder: (context) {

        return AlertDialog(

          title:
              const Text(
                  "Neue Spule"),

          content:
              TextField(
            controller:
                controller,
            keyboardType:
                TextInputType.number,
            decoration:
                const InputDecoration(
              labelText:
                  "Gewicht (g)",
            ),
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(
                    context);
              },

              child:
                  const Text(
                      "Abbrechen"),

            ),

            ElevatedButton(

              onPressed: () {

                final weight =
                    double.tryParse(
                        controller.text);

                if (weight != null &&
                    weight > 0) {

                  Navigator.pop(
                      context,
                      weight);
                }

              },

              child:
                  const Text(
                      "Speichern"),

            ),

          ],

        );

      },

    );

    if (result != null) {

      setState(() {

        widget.filament.spools.add(
          Spool(
            weight: result,
          ),
        );

      });

    }

  },

  icon:
      const Icon(Icons.add),

  label:
      const Text("Spule hinzufügen"),

),

const SizedBox(height: 30),

ElevatedButton(
  onPressed: save,
  child: const Text("Speichern"),
)

        ],

      ),

    );

  }

}