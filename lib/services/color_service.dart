import 'package:flutter/material.dart';
import '../models/filament_color.dart';
import '../tools/hex_color.dart';

class ColorService {
  static Color resolveColor({
    required String? name,
    required String? hex,
    required List<FilamentColor> catalogColors,
  }) {
    if (hex != null && hex.isNotEmpty) {
      return HexColor.fromHex(hex);
    }

    if (name != null && name.isNotEmpty) {
      try {
        final match = catalogColors.firstWhere(
          (c) => c.name.toLowerCase() == name.toLowerCase(),
        );
        return HexColor.fromHex(match.hex);
      } catch (_) {}
    }

    return Colors.grey;
  }
}