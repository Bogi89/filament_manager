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
import '../widgets/cards/filament_brand_section.dart';

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

  expandedBrands.putIfAbsent(
    brand,
    () => true,
  );

  return FilamentBrandSection(

    brand: brand,

    filaments: filaments,

    isExpanded:
        expandedBrands[brand]!,

    onToggle: () {

      setState(() {

        expandedBrands[brand] =
            !expandedBrands[brand]!;

      });

    },

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
                      blurRadius: 16,
                      offset: const Offset(0, 6),
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