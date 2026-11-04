import 'package:flutter/material.dart';

import '../../models/filament.dart';

class FilamentDropdownItem extends StatelessWidget {
  final Filament filament;

  const FilamentDropdownItem({super.key, required this.filament});

  List<Color> get _displayColors {
    if (filament.colors.isNotEmpty) {
      return filament.colors;
    }

    return [filament.color];
  }

  String get _colorLabel {
    final names = filament.colorNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty && name.toLowerCase() != 'unknown')
        .toList();

    if (names.isEmpty) {
      return '';
    }

    return names.join(' + ');
  }

  String get _filamentLabel {
    final parts = [
      filament.brand.trim(),
      filament.material.trim(),
      filament.variant.trim(),
    ].where((part) => part.isNotEmpty);

    return parts.join(' ');
  }

  Widget _buildColorDots() {
    final colors = _displayColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in colors.take(4))
          Padding(
            padding: const EdgeInsets.only(right: 3),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26, width: 0.7),
              ),
            ),
          ),
        if (colors.length > 4)
          Text('+${colors.length - 4}', style: const TextStyle(fontSize: 11)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final remainingWeight = filament.remainingWeight;
    final totalWeight = filament.totalWeight;

    final percentage = totalWeight > 0
        ? (remainingWeight / totalWeight) * 100
        : 0.0;

    final isLowStock = percentage <= 10;

    final colorLabel = _colorLabel;

    final weightLabel =
        '${remainingWeight.toStringAsFixed(0)} g'
        '${isLowStock ? ' ⚠' : ''}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildColorDots(),

        const SizedBox(width: 8),

        Flexible(
          child: Text(
            [
              _filamentLabel,
              if (colorLabel.isNotEmpty) '– $colorLabel',
              '($weightLabel)',
            ].join(' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isLowStock ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ),
      ],
    );
  }
}
