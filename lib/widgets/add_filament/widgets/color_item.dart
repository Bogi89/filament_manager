import 'package:flutter/material.dart';
import '../../../services/filament_catalog_service.dart';
import '../../../utils/color_name_localizer.dart';

class ColorItem extends StatelessWidget {
  const ColorItem({
    super.key,
    required this.brand,
    required this.material,
    required this.variant,
    required this.colorName,
  });

  final String brand;
  final String material;
  final String variant;
  final String colorName;

  @override
  Widget build(BuildContext context) {
    final parsedColors = FilamentCatalogService.getColorsFromHex(
      brand,
      material,
      variant,
      colorName,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...parsedColors.map(
          (color) => Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        Flexible(
  child: Text(
    ColorNameLocalizer.localize(context, colorName),
    overflow: TextOverflow.ellipsis,
  ),
),
      ],
    );
  }
}
