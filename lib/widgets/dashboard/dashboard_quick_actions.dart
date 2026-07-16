import 'package:flutter/material.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({
    super.key,
    required this.onAddFilament,
    required this.onCalculate,
  });

  final VoidCallback onAddFilament;
  final VoidCallback onCalculate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Schnellaktionen", style: Theme.of(context).textTheme.titleMedium),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddFilament,
                icon: const Icon(Icons.add),
                label: const Text("Filament hinzufügen"),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCalculate,
                icon: const Icon(Icons.calculate),
                label: const Text("Druck berechnen"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
