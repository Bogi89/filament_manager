import 'package:flutter/material.dart';

class AlignedAddButton extends StatelessWidget {
  const AlignedAddButton({
    super.key,
    required this.onPressed,
    this.tooltip = "Hinzufügen",
  });

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 56,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: const Icon(Icons.add),
      ),
    );
  }
}
