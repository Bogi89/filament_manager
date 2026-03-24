import 'package:flutter/material.dart';
import '../models/filament.dart';

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
  double? selectedDiameter;

  int? nozzleTemp;
  int? bedTemp;

  final TextEditingController priceController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  @override
  void initState() {

    super.initState();

    final f = widget.filament;

    /// 🔴 WICHTIG: Werte absichern

    selectedBrand =
        brands.contains(f.brand)
            ? f.brand
            : null;

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

  void save(){

    final f = widget.filament;

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

    f.remainingWeight =
        double.tryParse(
            weightController.text)
            ?? f.remainingWeight;

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

          const SizedBox(height:30),

          ElevatedButton(
            onPressed: save,
            child: const Text("Speichern"),
          )

        ],

      ),

    );

  }

}