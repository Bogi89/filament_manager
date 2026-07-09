import 'package:flutter/material.dart';

class AddFilamentDesktopLayout extends StatelessWidget {
  const AddFilamentDesktopLayout({
    super.key,
    required this.filamentSection,
    required this.printSettingsSection,
    required this.inventoryCostSection,
  });

  final Widget filamentSection;
  final Widget printSettingsSection;
  final Widget inventoryCostSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: filamentSection),

            const SizedBox(width: 24),

            Expanded(child: printSettingsSection),
          ],
        ),

        const SizedBox(height: 24),

        inventoryCostSection,
      ],
    );
  }
}
