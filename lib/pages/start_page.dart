import 'package:flutter/material.dart';
import '../models/filament.dart';
import '../models/print_job.dart';

class StartPage extends StatelessWidget {
  final List<Filament> filaments;
  final List<PrintJob> jobs;
  final Function(Filament) onEdit;
  final Function(int) onDelete;

  const StartPage({
    super.key,
    required this.filaments,
    required this.jobs,
    required this.onEdit,
    required this.onDelete,
  });

  static const double warningThreshold = 200;

  @override
  Widget build(BuildContext context) {
    final totalWeight =
        filaments.fold<double>(0, (sum, f) => sum + f.remainingWeight);

    final totalValue =
        filaments.fold<double>(0, (sum, f) => sum + (f.price));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _infoCard(
                  icon: Icons.inventory_2,
                  title: "Gesamtbestand",
                  value: "${totalWeight.toStringAsFixed(0)} g",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoCard(
                  icon: Icons.euro,
                  title: "Lagerwert",
                  value: "${totalValue.toStringAsFixed(2)} €",
                ),
              ),
            ],
          ),
        ),
        const Text(
          "Filamente",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: filaments.isEmpty
              ? const Center(child: Text("Keine Filamente vorhanden"))
              : ListView.builder(
                  itemCount: filaments.length,
                  itemBuilder: (context, index) {
                    final filament = filaments[index];
                    final isLowStock =
                        filament.remainingWeight <= warningThreshold;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isLowStock
                            ? const BorderSide(
                                color: Colors.red, width: 1.5)
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: filament.color,
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${filament.material} ${filament.variant}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (isLowStock)
                              const Icon(Icons.warning,
                                  color: Colors.red, size: 20),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(filament.brand),
                            Text(
                              "Rest: ${filament.remainingWeight.toStringAsFixed(0)} g",
                              style: TextStyle(
                                color: isLowStock
                                    ? Colors.red
                                    : Colors.black54,
                                fontWeight: isLowStock
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => onEdit(filament),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => onDelete(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(title),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}