import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/filament.dart';
import 'add_filament_page.dart';
import 'filament_detail_page.dart';
import '../widgets/spool_widget.dart';

class FilamentPage extends StatefulWidget {
  const FilamentPage({super.key});

  @override
  State<FilamentPage> createState() => _FilamentPageState();
}

class _FilamentPageState extends State<FilamentPage> {

  final ScrollController _scrollController = ScrollController();

  final Map<String,bool> expandedBrands = {};

  Filament? editingFilament;

  final TextEditingController weightController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  String? selectedBrand;
  String? selectedMaterial;

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();
    final warning = appState.warningPercent / 100;

    final List<Filament> filaments = [...appState.filaments];

    filaments.sort((a,b){

      final pa = a.remainingWeight / a.totalWeight;
      final pb = b.remainingWeight / b.totalWeight;

      final ca = pa <= warning;
      final cb = pb <= warning;

      if(ca && !cb) return -1;
      if(!ca && cb) return 1;

      return pa.compareTo(pb);
    });

    List<Filament> filtered = filaments;

    if(selectedBrand != null){
      filtered = filtered.where((f)=>f.brand == selectedBrand).toList();
    }

    if(selectedMaterial != null){
      filtered = filtered.where((f)=>f.material == selectedMaterial).toList();
    }

    if(searchText.isNotEmpty){

      final query = searchText.toLowerCase();

      filtered = filtered.where((f){

        return f.brand.toLowerCase().contains(query) ||
            f.material.toLowerCase().contains(query) ||
            f.variant.toLowerCase().contains(query);

      }).toList();
    }

    final grouped = <String,List<Filament>>{};

    for(final filament in filtered){
      grouped.putIfAbsent(filament.brand, ()=>[]);
      grouped[filament.brand]!.add(filament);
    }

    final criticalCount = filaments
        .where((f)=> (f.remainingWeight / f.totalWeight) <= warning)
        .length;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Filamente"),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddFilamentPage(
                onSave: (filament){
                  appState.addFilament(filament);
                },
              ),
            ),
          );

        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                _topCard(
                  icon: Icons.inventory,
                  value: filaments.length.toString(),
                  label: "Filamente",
                ),

                const SizedBox(width:16),

                _topCard(
                  icon: Icons.warning,
                  value: criticalCount.toString(),
                  label: "Kritisch",
                  color: Colors.red,
                ),

              ],
            ),
          ),

          /// AUTOCOMPLETE SUCHFELD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {

                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }

                final query = textEditingValue.text.toLowerCase();

                final suggestions = filaments.map((f) =>
                "${f.brand} ${f.material} ${f.variant}").toSet();

                return suggestions.where((option) {
                  return option.toLowerCase().contains(query);
                });
              },

              onSelected: (selection) {

                searchController.text = selection;

                setState(() {
                  searchText = selection;
                });
              },

              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {

                searchController.text = controller.text;

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Filament suchen...",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value){
                    setState(() {
                      searchText = value;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height:10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal:16),
            child: Row(
              children: [

                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text("Hersteller"),
                    isExpanded: true,
                    value: selectedBrand,
                    items: filaments
                        .map((f)=>f.brand)
                        .toSet()
                        .map((brand){
                      return DropdownMenuItem(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        selectedBrand = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width:10),

                Expanded(
                  child: DropdownButton<String>(
                    hint: const Text("Material"),
                    isExpanded: true,
                    value: selectedMaterial,
                    items: filaments
                        .map((f)=>f.material)
                        .toSet()
                        .map((mat){
                      return DropdownMenuItem(
                        value: mat,
                        child: Text(mat),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        selectedMaterial = value;
                      });
                    },
                  ),
                ),

                const SizedBox(width:10),

                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: (){
                    setState(() {
                      selectedBrand = null;
                      selectedMaterial = null;
                      searchText = "";
                      searchController.clear();
                    });
                  },
                ),

              ],
            ),
          ),

          const SizedBox(height:10),

          Expanded(
            child: ListView(
              controller: _scrollController,
              children: grouped.entries.map((entry){

                final brand = entry.key;
                final filaments = entry.value;

                expandedBrands.putIfAbsent(brand, ()=>true);

                return Column(
                  children: [

                    ListTile(
                      title: Text(
                        brand,
                        style: const TextStyle(
                          fontSize:18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        expandedBrands[brand]!
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      onTap: (){
                        setState(() {
                          expandedBrands[brand] =
                          !expandedBrands[brand]!;
                        });
                      },
                    ),

                    if(expandedBrands[brand]!)

                      ...filaments.map((f){

                        final percent = (f.remainingWeight / f.totalWeight) * 100;

                        Color percentColor;

                        if(percent <= appState.warningPercent){
                          percentColor = Colors.red;
                        }else if(percent <= 50){
                          percentColor = Colors.orange;
                        }else{
                          percentColor = Colors.green;
                        }

                        final isEditing = editingFilament == f;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:16, vertical:6),

                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: InkWell(

                              borderRadius: BorderRadius.circular(16),

                              onTap: (){

                                if(isEditing) return;

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        FilamentDetailPage(
                                          filament: f,
                                        ),
                                  ),
                                );
                              },

                              child: Padding(
                                padding: const EdgeInsets.all(16),

                                child: Row(
                                  children: [

                                    SpoolWidget(
                                      material: f.material,
                                    ),

                                    const SizedBox(width:16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                        children: [

                                          Row(
                                            children: [

                                              Container(
                                                width:10,
                                                height:10,
                                                margin: const EdgeInsets.only(right:8),
                                                decoration: BoxDecoration(
                                                  color: f.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),

                                              Expanded(
                                                child: Text(
                                                  "${f.material} ${f.variant}",
                                                  style: const TextStyle(
                                                    fontSize:16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),

                                            ],
                                          ),

                                          const SizedBox(height:6),

                                          if(isEditing)

                                            Row(
                                              children: [

                                                _weightButton("-10", (){
                                                  _changeWeight(-10,f);
                                                }),

                                                _weightButton("-", (){
                                                  _changeWeight(-1,f);
                                                }),

                                                SizedBox(
                                                  width:70,
                                                  child: TextField(
                                                    controller: weightController,
                                                    keyboardType:
                                                    TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),

                                                _weightButton("+", (){
                                                  _changeWeight(1,f);
                                                }),

                                                _weightButton("+10", (){
                                                  _changeWeight(10,f);
                                                }),

                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                  ),
                                                  onPressed: (){

                                                    final value =
                                                        double.tryParse(
                                                            weightController.text)
                                                            ?? f.remainingWeight;

                                                    f.remainingWeight = value;

                                                    editingFilament = null;

                                                    appState.saveData();

                                                    setState((){});
                                                  },
                                                )
                                              ],
                                            )

                                          else

                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [

                                                Text(
                                                  "${f.remainingWeight.toInt()} g von ${f.totalWeight.toInt()} g",
                                                  style: const TextStyle(
                                                    fontSize:13,
                                                    color: Colors.grey,
                                                  ),
                                                ),

                                                const SizedBox(height:6),

                                                ClipRRect(
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                  child:
                                                  LinearProgressIndicator(
                                                    value: percent / 100,
                                                    minHeight:8,
                                                    backgroundColor:
                                                    Colors.grey.shade300,
                                                    valueColor:
                                                    AlwaysStoppedAnimation(
                                                        percentColor),
                                                  ),
                                                ),
                                              ],
                                            ),

                                        ],
                                      ),
                                    ),

                                    const SizedBox(width:16),

                                    if(!isEditing)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            size: 14,
                                            color: percentColor,
                                          ),
                                          const SizedBox(width:6),
                                          Text(
                                            "${percent.round()}%",
                                            style: TextStyle(
                                              fontSize:20,
                                              fontWeight: FontWeight.bold,
                                              color: percentColor,
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(width:8),

                                    if(!isEditing)

                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: (){
                                          editingFilament = f;
                                          weightController.text =
                                              f.remainingWeight
                                                  .toInt()
                                                  .toString();
                                          setState((){});
                                        },
                                      ),

                                    if(!isEditing)

                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: (){
                                          appState.removeFilament(f);
                                        },
                                      ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                        );

                      })

                  ],
                );

              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _changeWeight(int change, Filament filament){

    final current =
        double.tryParse(weightController.text)
            ?? filament.remainingWeight;

    double newValue = current + change;

    if(newValue < 0) newValue = 0;

    if(newValue > filament.totalWeight){
      newValue = filament.totalWeight;
    }

    weightController.text = newValue.toInt().toString();

    setState((){});
  }

  Widget _weightButton(String text, VoidCallback onPressed){

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:2),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  Widget _topCard({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }){

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
        ),
        child: Column(
          children: [
            Icon(icon,color: color ?? Colors.blue),
            const SizedBox(height:8),
            Text(
              value,
              style: const TextStyle(
                fontSize:18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}