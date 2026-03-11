import 'package:flutter/material.dart';
import '../models/filament.dart';

Future<void> showWeightEditDialog({
  required BuildContext context,
  required Filament filament,
  required VoidCallback onSaved,
}) async {
  final controller =
      TextEditingController(text: filament.remainingWeight.toString());

  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Restgewicht ändern"),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration:
            const InputDecoration(labelText: "Restgewicht (g)"),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        IconButton(
          icon: const Icon(Icons.check, color: Colors.green),
          onPressed: () {
            filament.remainingWeight =
                double.tryParse(controller.text) ??
                    filament.remainingWeight;
            onSaved();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}