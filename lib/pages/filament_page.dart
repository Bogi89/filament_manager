import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/filament.dart';
import 'add_filament_page.dart';
import 'filament_detail_page.dart';
import '../widgets/filament_spool_icon.dart';

enum FilamentSortOption {
  lowFirst,
  highFirst,
  materialAZ,
  variantAZ,
}

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

  /// ⭐ Autocomplete Controller merken
  TextEditingController? _autoController;

  String searchText = "";

  String? selectedBrand;
  String? selectedMaterial;

  FilamentSortOption selectedSort =
      FilamentSortOption.lowFirst;

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();
    final warning = appState.warningPercent / 100;

    final List<Filament> filaments =
        [...appState.filaments];

    /// Warnsortierung
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
      filtered = filtered
          .where((f)=>f.brand == selectedBrand)
          .toList();
    }

    if(selectedMaterial != null){
      filtered = filtered
          .where((f)=>f.material == selectedMaterial)
          .toList();
    }

    if(searchText.isNotEmpty){

      final query = searchText.toLowerCase();

      filtered = filtered.where((f){

        final fullText =
            "${f.brand} ${f.material} ${f.variant}"
                .toLowerCase();

        return fullText.contains(query);

      }).toList();
    }

    final grouped =
    <String,List<Filament>>{};

    for(final filament in filtered){
      grouped.putIfAbsent(
          filament.brand, ()=>[]);
      grouped[filament.brand]!
          .add(filament);
    }

    grouped.forEach((brand, list){

      switch(selectedSort){

        case FilamentSortOption.lowFirst:
          list.sort((a,b)=>
              (a.remainingWeight /
                  a.totalWeight)
                  .compareTo(
                  b.remainingWeight /
                      b.totalWeight));
          break;

        case FilamentSortOption.highFirst:
          list.sort((a,b)=>
              (b.remainingWeight /
                  b.totalWeight)
                  .compareTo(
                  a.remainingWeight /
                      a.totalWeight));
          break;

        case FilamentSortOption.materialAZ:
          list.sort((a,b)=>
              a.material
                  .compareTo(b.material));
          break;

        case FilamentSortOption.variantAZ:
          list.sort((a,b)=>
              a.variant
                  .compareTo(b.variant));
          break;

      }

    });

    final criticalCount = filaments
    .where((f) =>
        (f.remainingWeight /
            f.totalWeight) *
            100 <=
        appState.warningPercent)
    .length;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Filamente"),
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddFilamentPage(
                    onSave: (filament){
                      appState
                          .addFilament(filament);
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
            padding:
            const EdgeInsets.all(16),
            child: Row(

    /// NORMAL MODE
        children: [

                _topCard(
                  icon: Icons.inventory,
                  value: filaments.length
                      .toString(),
                  label: "Filamente",
                ),

                const SizedBox(width:16),

                _topCard(
                  icon: Icons.warning,
                  value: criticalCount
                      .toString(),
                  label: "Kritisch",
                  color: Colors.red,
                ),

              ],
            ),
          ),

          Padding(
            padding:
            const EdgeInsets.symmetric(
                horizontal:16),
            child:
            DropdownButton<FilamentSortOption>(
              isExpanded: true,
              value: selectedSort,
              items: const [

                DropdownMenuItem(
                  value:
                  FilamentSortOption
                      .lowFirst,
                  child: Text(
                      "Niedrigster Bestand zuerst"),
                ),

                DropdownMenuItem(
                  value:
                  FilamentSortOption
                      .highFirst,
                  child: Text(
                      "Höchster Bestand zuerst"),
                ),

                DropdownMenuItem(
                  value:
                  FilamentSortOption
                      .materialAZ,
                  child:
                  Text("Material A–Z"),
                ),

                DropdownMenuItem(
                  value:
                  FilamentSortOption
                      .variantAZ,
                  child:
                  Text("Variante A–Z"),
                ),

              ],
              onChanged: (value){
                if(value != null){
                  setState(() {
                    selectedSort = value;
                  });
                }
              },
            ),
          ),

          const SizedBox(height:10),

          Padding(
            padding:
            const EdgeInsets.symmetric(
                horizontal:16),
            child: Autocomplete<String>(
              optionsBuilder:
                  (TextEditingValue
              textEditingValue) {

                if (textEditingValue
                    .text
                    .isEmpty) {
                  return const Iterable
                      .empty();
                }

                final query =
                textEditingValue.text
                    .toLowerCase();

                final suggestions =
                filaments.map((f) =>
                "${f.brand} ${f.material} ${f.variant}")
                    .toSet();

                return suggestions
                    .where((option) {

                  return option
                      .toLowerCase()
                      .contains(query);

                });
              },

              onSelected: (selection) {

                setState(() {
                  searchText =
                      selection;
                });

              },

              fieldViewBuilder:
                  (context,
                  controller,
                  focusNode,
                  onFieldSubmitted) {

                /// ⭐ Controller merken
                _autoController = controller;

                return TextField(
                  controller:
                  controller,
                  focusNode: focusNode,
                  decoration:
                  const InputDecoration(
                    prefixIcon:
                    Icon(Icons.search),
                    hintText:
                    "Filament suchen...",
                    border:
                    OutlineInputBorder(),
                  ),
                  onChanged: (value){

                    setState(() {
                      searchText =
                          value;
                    });

                  },
                );
              },
            ),
          ),

          const SizedBox(height:10),

          Padding(
            padding:
            const EdgeInsets.symmetric(
                horizontal:16),
            child: Row(
              children: [

                Expanded(
                  child:
                  DropdownButton<String>(
                    hint: const Text(
                        "Hersteller"),
                    isExpanded: true,
                    value: selectedBrand,
                    items: filaments
                        .map((f)=>f.brand)
                        .toSet()
                        .map((brand){
                      return DropdownMenuItem(
                        value: brand,
                        child:
                        Text(brand),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        selectedBrand =
                            value;
                      });
                    },
                  ),
                ),

                const SizedBox(width:10),

                Expanded(
                  child:
                  DropdownButton<String>(
                    hint: const Text(
                        "Material"),
                    isExpanded: true,
                    value:
                    selectedMaterial,
                    items: filaments
                        .map((f)=>f.material)
                        .toSet()
                        .map((mat){
                      return DropdownMenuItem(
                        value: mat,
                        child:
                        Text(mat),
                      );
                    }).toList(),
                    onChanged: (value){
                      setState(() {
                        selectedMaterial =
                            value;
                      });
                    },
                  ),
                ),

                const SizedBox(width:10),

                IconButton(
                  icon:
                  const Icon(Icons.refresh),
                  onPressed: (){

                    setState(() {

                      selectedBrand = null;
                      selectedMaterial = null;

                      searchText = "";

                      /// ⭐ RESET FIX
                      _autoController?.clear();

                    });

                  },
                ),

              ],
            ),
          ),

          const SizedBox(height:10),

          Expanded(
            child: ListView(
              controller:
              _scrollController,
              children:
              grouped.entries.map((entry){

                final brand = entry.key;
                final filaments =
                    entry.value;

                expandedBrands
                    .putIfAbsent(
                    brand, ()=>true);

                return Column(
                  children: [

                    ListTile(
                      title: Text(
                        brand,
                        style:
                        const TextStyle(
                          fontSize:18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        expandedBrands[
                        brand]!
                            ? Icons
                            .expand_less
                            : Icons
                            .expand_more,
                      ),
                      onTap: (){
                        setState(() {
                          expandedBrands[
                          brand] =
                          !expandedBrands[
                          brand]!;
                        });
                      },
                    ),

                    if(expandedBrands[
                    brand]!)

                      ...filaments.map((f){

                        final percent =
                            (f.remainingWeight /
                                f.totalWeight) *
                                100;

                        Color percentColor;

                        if(percent <=
                            appState
                                .warningPercent){
                          percentColor =
                              Colors.red;
                        }else if(percent <=
                            50){
                          percentColor =
                              Colors.orange;
                        }else{
                          percentColor =
                              Colors.green;
                        }

                        final isEditing =
                            editingFilament == f;

                        return Column(
  children: [

    isEditing
        ? Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: Card(
              child: Row(
                children: [

                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      f.remainingWeight =
                          (f.remainingWeight - 10)
                              .clamp(
                                  0,
                                  f.totalWeight);

                      weightController.text =
                          f.remainingWeight
                              .toInt()
                              .toString();

                      setState(() {});
                    },
                  ),

                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType:
                          TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      f.remainingWeight =
                          (f.remainingWeight + 10)
                              .clamp(
                                  0,
                                  f.totalWeight);

                      weightController.text =
                          f.remainingWeight
                              .toInt()
                              .toString();

                      setState(() {});
                    },
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.green,
                    ),
                    onPressed: () {

                      final value =
                          double.tryParse(
                                  weightController.text)
                              ?? f.remainingWeight;

                      f.remainingWeight = value;

                      editingFilament = null;

                      context
                          .read<AppState>()
                          .saveData();

                      setState(() {});
                    },
                  ),

                ],
              ),
            ),
          )

        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 6,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(16),
                onTap: () {

                  if (isEditing) return;

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
                  padding:
                      const EdgeInsets.all(16),

                  child: Row(
                    children: [

                      FilamentSpoolIcon(
                        filament: f,
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Row(
                              children: [

                                ...f.colors
                                    .map((color) {

                                  return Container(
                                    width: 10,
                                    height: 10,
                                    margin:
                                        const EdgeInsets
                                            .only(right: 6),
                                    decoration:
                                        BoxDecoration(
                                      color: color,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                  );

                                }).toList(),

                                Expanded(
                                  child: Text(
                                    "${f.material} ${f.variant}",
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),

                              ],
                            ),

                            const SizedBox(height: 6),

                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "${f.remainingWeight.toInt()} g von ${f.totalWeight.toInt()} g",
                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  child:
                                      LinearProgressIndicator(
                                    value:
                                        percent / 100,
                                    minHeight: 8,
                                    backgroundColor:
                                        Colors.grey
                                            .shade300,
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

                    ],
                  ),
                ),
              ),
            ),
          ),

  ],

                      }).toList(),

  ],
);

  Widget _topCard({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }){

    return Expanded(
      child: Container(
        padding:
        const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(16),
          color:
(color != null)
    ? color.withOpacity(0.15)
    : Colors.grey.shade100,
        ),
        child: Column(
          children: [

            Icon(
  icon,
  color: color ?? Colors.blue,
  size: 28,
),

            const SizedBox(height:8),

            Text(
              value,
              style:
              const TextStyle(
                fontSize:18,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            Text(label),

          ],
        ),
      ),
    );
  }
}