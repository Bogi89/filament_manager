import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/filament.dart';
import 'add_filament_page.dart';
import 'filament_detail_page.dart';
import '../widgets/filament_spool_icon.dart';
import '../services/filament_catalog_service.dart';
import '../widgets/filament_filter_bar.dart';
import '../widgets/spool_icon.dart';

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

  /// Sortiermodus (bleibt lokal, wird aber synchronisiert)

  String selectedSort = "Material";

  List<String> catalogSuggestions = [];

  Key autocompleteKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _prepareCatalogSuggestions();
  }

  void _prepareCatalogSuggestions() {

    final brands = FilamentCatalogService.getBrands();

    final Set<String> suggestions = {};

    for (final brand in brands) {

      final materials =
          FilamentCatalogService.getMaterials(brand);

      for (final material in materials) {

        final variants =
            FilamentCatalogService.getVariants(
          brand,
          material,
        );

        for (final variant in variants) {

          suggestions.add(
            "$brand $material $variant",
          );

        }
      }
    }

    catalogSuggestions = suggestions.toList();
    catalogSuggestions.sort();
  }

  /// Material normalisieren

  String _normalizeMaterial(String material){

    material = material.toLowerCase();

    if(material.contains("rifd")) return "pla";

    if(material.contains("pla")) return "pla";
    if(material.contains("petg")) return "petg";
    if(material.contains("abs")) return "abs";
    if(material.contains("asa")) return "asa";
    if(material.contains("tpu")) return "tpu";

    return material;
  }

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();

    /// 🔥 Sortierung aus Settings laden

    selectedSort = appState.sortMode;

    final warning = appState.warningPercent / 100;

    final List<Filament> filaments =
    [...appState.filaments];

    List<Filament> filtered = filaments;

    if(selectedBrand != null){
      filtered =
          filtered.where((f)=>f.brand == selectedBrand).toList();
    }

    if(selectedMaterial != null){
      filtered =
          filtered.where((f)=>f.material == selectedMaterial).toList();
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

    /// Sortierung

    for(final brand in grouped.keys){

      grouped[brand]!.sort((a,b){

        if(selectedSort == "Restgewicht"){

          final pa =
              a.remainingWeight / a.totalWeight;

          final pb =
              b.remainingWeight / b.totalWeight;

          return pa.compareTo(pb);
        }

        if(selectedSort == "Name"){

          return a.variant.compareTo(b.variant);
        }

        final matA =
            _normalizeMaterial(a.material);

        final matB =
            _normalizeMaterial(b.material);

        final matCompare =
            matA.compareTo(matB);

        if(matCompare != 0)
          return matCompare;

        return a.variant.compareTo(b.variant);

      });

    }

    final criticalCount = filaments
        .where((f)=>
    (f.remainingWeight / f.totalWeight) <= warning)
        .length;

    return Scaffold(
  backgroundColor:
    Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : const Color(0xFFE9EEF5),

      appBar: AppBar(
        title: const Text("Filamente"),
      ),

      floatingActionButton: Padding(
  padding: const EdgeInsets.only(
    bottom: 12,
    right: 8,
  ),

  child: SizedBox(
    height: 56,

    child: ElevatedButton.icon(

      onPressed: () async {

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddFilamentPage(
              onSave: (filament) {
                context.read<AppState>().addFilament(filament);
              },
            ),
          ),
        );

      },

      icon: const Icon(
        Icons.add,
        size: 26,
      ),

      label: const Text(
        "Filament",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      style: ElevatedButton.styleFrom(

  backgroundColor:
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF7B61FF) // Dark → Lila
          : const Color(0xFF3B82F6), // Light → Blau

  foregroundColor: Colors.white,

  elevation: 8,

  padding: const EdgeInsets.symmetric(
    horizontal: 18,
  ),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  ),

  shadowColor:
      (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF7B61FF)
              : const Color(0xFF3B82F6))
          .withOpacity(0.4),

),

    ),
  ),
),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                _topCard(
                  icon: const SpoolIcon(
  size: 24,
),
                  value: filaments.length.toString(),
                  label: "Filamente",
                ),

                const SizedBox(width: 24),

                _topCard(
                  icon: const Icon(Icons.warning),
                  value: criticalCount.toString(),
                  label: "Kritisch",
                  color: Colors.red,
                ),

              ],
            ),
          ),

          /// ================= FILTER (einklappbar) =================

Container(
  margin: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  ),

  decoration: BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  ),

  child: Theme(
    data: Theme.of(context).copyWith(
      dividerColor: Colors.transparent,
    ),

    child: ExpansionTile(

      tilePadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),

      childrenPadding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 16,
      ),

      title: Row(
        children: const [
          Icon(Icons.filter_list),
          SizedBox(width: 8),
          Text(
            "Filter",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),

      children: [

        FilamentFilterBar(

          searchController: searchController,

          brandItems: filaments
              .map((f) => f.brand)
              .toSet()
              .toList(),

          materialItems: filaments
              .map((f) => f.material)
              .toSet()
              .toList(),

          selectedBrand: selectedBrand,
          selectedMaterial: selectedMaterial,
          selectedSort: selectedSort,

          onBrandChanged: (value) {

            setState(() {

              selectedBrand = value;

            });

          },

          onMaterialChanged: (value) {

            setState(() {

              selectedMaterial = value;

            });

          },

          onSortChanged: (value) {

            if (value == null) return;

            setState(() {

              selectedSort = value;

              appState.setSortMode(value);

            });

          },

          onSearchChanged: (value) {

            setState(() {

              searchText = value;

            });

          },

          onReset: () {

            setState(() {

              selectedBrand = null;
              selectedMaterial = null;

              searchText = "";
              searchController.clear();

              selectedSort = "Material";

              appState.setSortMode("Material");

            });

          },

        ),

      ],

    ),

  ),

),

          const SizedBox(height:10),

          Expanded(
  child: ListView(
    controller: _scrollController,
    padding: const EdgeInsets.only(
      bottom: 120,
    ),
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

                        final percent =
                            (f.remainingWeight / f.totalWeight) * 100;

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
  color: Theme.of(context).brightness == Brightness.dark
      ? null
      : Colors.white,

  elevation:
      Theme.of(context).brightness == Brightness.dark
          ? 0
          : 3,

  shadowColor:
      Theme.of(context).brightness == Brightness.dark
          ? Colors.transparent
          : Colors.black.withOpacity(0.08),

  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
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

                                    FilamentSpoolIcon(
                                      filament: f,
                                    ),

                                    const SizedBox(width:16),

                                    Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      /// Titelzeile
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Farbpunkte
          Wrap(
  spacing: 6,
  runSpacing: 6,
  children: f.colors.take(4).map((color) {

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(

        color: color == Colors.white
            ? const Color(0xFFE5E7EB)
            : color,

        shape: BoxShape.circle,

        border: color == Colors.white
            ? Border.all(
                color: const Color(0xFF9CA3AF),
                width: 0.5,
              )
            : null,
      ),
    );

  }).toList(), // 🔥 DIESE ZEILE FEHLT BEI DIR

),

          const SizedBox(width: 8),

          /// Material + Variante
          Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [

      Row(
  children: [

    /// Material (PLA / ABS usw.)
    Text(
      f.material,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    ),

    const SizedBox(width: 8),

    /// Farbnamen anzeigen
    if (_buildColorNames(f).isNotEmpty)
      Expanded(
        child: Text(
          _buildColorNames(f),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

  ],
),

/// Variant (z.B. Glow in the Dark)
if (f.variant.isNotEmpty)
  Text(
    f.variant,
    maxLines: 3,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: 13,
      color: Colors.grey.shade400,
      fontWeight: FontWeight.w400,
    ),
  ),

    ],
  ),
),

        ],
      ),

                                          const SizedBox(height:6),

                                          if (isEditing)
  Wrap(
    spacing: 6,
    runSpacing: 6,
    crossAxisAlignment: WrapCrossAlignment.center,
    alignment: WrapAlignment.start,
    children: [

      _weightButton("-10", () {
        _changeWeight(-10, f);
      }),

      _weightButton("-", () {
        _changeWeight(-1, f);
      }),

      SizedBox(
        width: 60, // 🔥 kleiner → Platz für +10
        child: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 4,
            ),
          ),
        ),
      ),

      _weightButton("+", () {
        _changeWeight(1, f);
      }),

      _weightButton("+10", () {
        _changeWeight(10, f);
      }),

      IconButton(
        icon: const Icon(Icons.check),
        color: Colors.green,
        onPressed: () {

          final newWeight =
              double.tryParse(weightController.text);

          if (newWeight != null) {

            f.remainingWeight = newWeight;

            context
                .read<AppState>()
                .updateFilament(f);

          }

          setState(() {

            editingFilament = null;

          });

        },
      ),

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
            BorderRadius.circular(10),
        child:
            LinearProgressIndicator(
  value: percent / 100,

  minHeight: 14,

  backgroundColor:
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade200,

  valueColor:
      AlwaysStoppedAnimation(percentColor),

  borderRadius: BorderRadius.circular(10),
),
      ),

    ],
  ),                                  
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width:16),

                                    if (!isEditing)
  Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [

      /// Prozent-Zeile
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          Icon(
            Icons.circle,
            size: 10,
            color: percentColor,
          ),

          const SizedBox(width: 4),

          Text(
            "${percent.round()}%",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: percentColor,
            ),
          ),
        ],
      ),

      const SizedBox(height: 2),

      /// Button-Zeile
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              editingFilament = f;
              weightController.text =
                  f.remainingWeight.toInt().toString();
              setState(() {});
            },
          ),

          const SizedBox(width: 6),

          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 18,
              color: Colors.red,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              appState.removeFilament(f);
            },
          ),

        ],
      ),

    ],
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

String _buildColorNames(Filament f) {

  if (f.colorNames.isEmpty) {
    return "";
  }

  /// 🔥 Nur den ersten Namen anzeigen
  final name = f.colorNames.first;

  return name;

}

Widget _topCard({
  required Widget icon,
  required String value,
  required String label,
  Color? color,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(18),

        color: Theme.of(context)
                    .brightness ==
                Brightness.dark
            ? Colors.grey.shade900
            : Colors.white,

        boxShadow:
            Theme.of(context)
                        .brightness ==
                    Brightness.dark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          /// Icon links

          Container(
            width: 44,
            height: 44,

            decoration: BoxDecoration(
              color: (color ??
                      Theme.of(context)
                          .colorScheme
                          .primary)
                  .withOpacity(0.15),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Center(
              child: icon,
            ),
          ),

          const SizedBox(width: 12),

          /// Text rechts

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(label),

            ],
          ),

        ],
      ),
    ),
  );
}
}