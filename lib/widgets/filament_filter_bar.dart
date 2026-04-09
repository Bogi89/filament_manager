import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_colors.dart';

class FilamentFilterBar extends StatelessWidget {

  final TextEditingController searchController;

  final List<String> brandItems;
  final List<String> materialItems;

  final String? selectedBrand;
  final String? selectedMaterial;
  final String selectedSort;

  final Function(String?) onBrandChanged;
  final Function(String?) onMaterialChanged;
  final Function(String?) onSortChanged;

  final VoidCallback onReset;
  final Function(String) onSearchChanged;

  const FilamentFilterBar({
    super.key,
    required this.searchController,
    required this.brandItems,
    required this.materialItems,
    required this.selectedBrand,
    required this.selectedMaterial,
    required this.selectedSort,
    required this.onBrandChanged,
    required this.onMaterialChanged,
    required this.onSortChanged,
    required this.onReset,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {

    final brightness = Theme.of(context).brightness;

    final surfaceColor =
        brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight;

    final fillColor =
        brightness == Brightness.dark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight;

    return Container(

      margin: AppSpacing.horizontalLG,

      padding: AppSpacing.paddingLG,

      decoration: BoxDecoration(

        color: surfaceColor,

        borderRadius: AppRadius.radiusMD,

        boxShadow: brightness == Brightness.dark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔎 Titel

          Text(
            "Filter",
            style: Theme.of(context).textTheme.titleMedium,
          ),

          SizedBox(height: AppSpacing.md),

          /// 🔍 Suche

          TextField(

            controller: searchController,

            onChanged: onSearchChanged,

            decoration: InputDecoration(

              hintText: "Filament suchen...",

              prefixIcon: const Icon(Icons.search),

              filled: true,

              fillColor: fillColor,

              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: BorderSide.none,
              ),

            ),
          ),

          SizedBox(height: AppSpacing.lg),

          /// Reihe 1

          Row(
            children: [

              Expanded(
                child: DropdownButtonFormField<String>(

                  value: selectedBrand,

                  items: brandItems
                      .map(
                        (brand) => DropdownMenuItem(
                          value: brand,
                          child: Text(brand),
                        ),
                      )
                      .toList(),

                  decoration: InputDecoration(
                    labelText: "Hersteller",

                    filled: true,
                    fillColor: fillColor,

                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide.none,
                    ),
                  ),

                  onChanged: onBrandChanged,
                ),
              ),

              SizedBox(width: AppSpacing.md),

              Expanded(
                child: DropdownButtonFormField<String>(

                  value: selectedMaterial,

                  items: materialItems
                      .map(
                        (material) =>
                            DropdownMenuItem(
                          value: material,
                          child: Text(material),
                        ),
                      )
                      .toList(),

                  decoration: InputDecoration(
                    labelText: "Material",

                    filled: true,
                    fillColor: fillColor,

                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide.none,
                    ),
                  ),

                  onChanged: onMaterialChanged,
                ),
              ),

            ],
          ),

          SizedBox(height: AppSpacing.lg),

          /// Reihe 2

          Row(
            children: [

              Expanded(
                child: DropdownButtonFormField<String>(

                  value: selectedSort,

                  items: const [

                    DropdownMenuItem(
                      value: "Material",
                      child: Text("Nach Material"),
                    ),

                    DropdownMenuItem(
                      value: "Restgewicht",
                      child: Text("Nach Restgewicht"),
                    ),

                    DropdownMenuItem(
                      value: "Name",
                      child: Text("Nach Name"),
                    ),

                  ],

                  decoration: InputDecoration(
                    labelText: "Sortieren",

                    filled: true,
                    fillColor: fillColor,

                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusMD,
                      borderSide: BorderSide.none,
                    ),
                  ),

                  onChanged: onSortChanged,
                ),
              ),

              SizedBox(width: AppSpacing.md),

              /// Reset Button (jetzt Secondary!)

              Expanded(
                child: SizedBox(
                  height: 56,

                  child: OutlinedButton.icon(

                    onPressed: onReset,

                    icon: const Icon(Icons.refresh),

                    label: const Text("Zurücksetzen"),

                    style: OutlinedButton.styleFrom(

                      foregroundColor: AppColors.primary,

                      side: BorderSide(
                        color: AppColors.primary,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius:
                            AppRadius.radiusMD,
                      ),

                    ),
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
}