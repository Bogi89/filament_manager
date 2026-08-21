import 'package:flutter/material.dart';

import '../models/filament_sort_mode.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class FilamentFilterBar extends StatelessWidget {
  final TextEditingController searchController;

  final List<String> brandItems;
  final List<String> materialItems;

  final String? selectedBrand;
  final String? selectedMaterial;
  final FilamentSortMode selectedSort;

  final Function(String?) onBrandChanged;
  final Function(String?) onMaterialChanged;
  final Function(FilamentSortMode?) onSortChanged;

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
    final l10n = AppLocalizations.of(context)!;
    final brightness =
        Theme.of(context).brightness;

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
                  color: Colors.black.withValues(
                    alpha: 0.04,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
  l10n.filter,
  style: Theme.of(context).textTheme.titleMedium,
),

          SizedBox(
            height: AppSpacing.md,
          ),

          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: l10n.searchFilament,
              prefixIcon:
                  const Icon(Icons.search),
              filled: true,
              fillColor: fillColor,
              border: OutlineInputBorder(
                borderRadius:
                    AppRadius.radiusMD,
                borderSide: BorderSide.none,
              ),
            ),
          ),

          SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              Expanded(
                child:
                    DropdownButtonFormField<String>(
                  initialValue:
                      selectedBrand,
                  items: brandItems
                      .map(
                        (brand) =>
                            DropdownMenuItem(
                          value: brand,
                          child: Text(brand),
                        ),
                      )
                      .toList(),
                  decoration:
                      InputDecoration(
                    labelText: l10n.manufacturer,
                    filled: true,
                    fillColor: fillColor,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          AppRadius.radiusMD,
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                  onChanged:
                      onBrandChanged,
                ),
              ),

              SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child:
                    DropdownButtonFormField<String>(
                  initialValue:
                      selectedMaterial,
                  items: materialItems
                      .map(
                        (material) =>
                            DropdownMenuItem(
                          value: material,
                          child:
                              Text(material),
                        ),
                      )
                      .toList(),
                  decoration:
                      InputDecoration(
                    labelText: l10n.material,
                    filled: true,
                    fillColor: fillColor,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          AppRadius.radiusMD,
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                  onChanged:
                      onMaterialChanged,
                ),
              ),
            ],
          ),

          SizedBox(
            height: AppSpacing.lg,
          ),

          Row(
            children: [
              Expanded(
                child:
                    DropdownButtonFormField<
                        FilamentSortMode>(
                  initialValue:
                      selectedSort,
                  items: [
                    DropdownMenuItem(
  value: FilamentSortMode.material,
  child: Text(l10n.sortByMaterial),
),
                    DropdownMenuItem(
  value: FilamentSortMode.remainingWeight,
  child: Text(
    l10n.sortByRemainingWeight,
  ),
),
                    DropdownMenuItem(
  value: FilamentSortMode.name,
  child: Text(l10n.sortByName),
),
                  ],
                  decoration:
                      InputDecoration(
                    labelText: l10n.sort,
                    filled: true,
                    fillColor: fillColor,
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          AppRadius.radiusMD,
                      borderSide:
                          BorderSide.none,
                    ),
                  ),
                  onChanged:
                      onSortChanged,
                ),
              ),

              SizedBox(
                width: AppSpacing.md,
              ),

              Expanded(
                child: SizedBox(
                  height: 56,
                  child:
                      OutlinedButton.icon(
                    onPressed: onReset,
                    icon:
                        const Icon(Icons.refresh),
                    label: Text(
  l10n.reset,
),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          AppColors.primary,
                      side: BorderSide(
                        color:
                            AppColors.primary,
                      ),
                      shape:
                          RoundedRectangleBorder(
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