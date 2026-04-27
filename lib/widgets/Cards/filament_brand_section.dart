import 'package:flutter/material.dart';

import '../../models/filament.dart';
import 'filament_card.dart';

class FilamentBrandSection extends StatelessWidget {

  final String brand;
  final List<Filament> filaments;

  final bool isExpanded;
  final VoidCallback onToggle;

  const FilamentBrandSection({
    super.key,
    required this.brand,
    required this.filaments,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        /// BRAND HEADER

        ListTile(

          title: Text(
            brand,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          trailing: Icon(
            isExpanded
                ? Icons.expand_less
                : Icons.expand_more,
          ),

          onTap: onToggle,
        ),

        /// FILAMENT LIST

        if (isExpanded)

          ...filaments.map(
            (f) => FilamentCard(
              filament: f,
            ),
          ),

      ],
    );
  }
}