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
    final brightness = Theme.of(context).brightness;

    final fillColor = brightness == Brightness.dark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;

    final fieldTextStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400);

    InputDecoration fieldDecoration(String label) {
      return InputDecoration(
        labelText: label,
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMD,
          borderSide: BorderSide.none,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: fieldTextStyle,
          decoration: InputDecoration(
            hintText: l10n.searchFilament,
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.radiusMD,
              borderSide: BorderSide.none,
            ),
          ),
        ),

        SizedBox(height: AppSpacing.lg),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedBrand,
                isExpanded: true,
                style: fieldTextStyle,
                hint: Text(l10n.all, style: fieldTextStyle),
                items: brandItems
                    .map(
                      (brand) => DropdownMenuItem<String>(
                        value: brand,
                        child: Text(
                          brand,
                          style: fieldTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                decoration: fieldDecoration(l10n.manufacturer),
                onChanged: onBrandChanged,
              ),
            ),

            SizedBox(width: AppSpacing.md),

            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: selectedMaterial,
                isExpanded: true,
                style: fieldTextStyle,
                hint: Text(l10n.all, style: fieldTextStyle),
                items: materialItems
                    .map(
                      (material) => DropdownMenuItem<String>(
                        value: material,
                        child: Text(
                          material,
                          style: fieldTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                decoration: fieldDecoration(l10n.material),
                onChanged: onMaterialChanged,
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.lg),

        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<FilamentSortMode>(
                initialValue: selectedSort,
                isExpanded: true,
                style: fieldTextStyle,
                items: [
                  DropdownMenuItem(
                    value: FilamentSortMode.material,
                    child: Text(
                      l10n.sortByMaterial,
                      style: fieldTextStyle,
                      maxLines: 1,
                    ),
                  ),
                  DropdownMenuItem(
                    value: FilamentSortMode.remainingWeight,
                    child: Text(
                      l10n.sortByRemainingWeight,
                      style: fieldTextStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DropdownMenuItem(
                    value: FilamentSortMode.name,
                    child: Text(
                      l10n.sortByName,
                      style: fieldTextStyle,
                      maxLines: 1,
                    ),
                  ),
                ],
                decoration: fieldDecoration(l10n.sort),
                onChanged: onSortChanged,
              ),
            ),

            SizedBox(width: AppSpacing.md),

            Expanded(
              flex: 2,
              child: SizedBox(
                height: 56,
                child: OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.radiusMD,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.refresh, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          l10n.reset,
                          maxLines: 1,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
