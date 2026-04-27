import 'package:flutter/material.dart';

class ColorRegistry {

  static String _normalize(String value) {
  return value
      .toLowerCase()
      .trim()
      .replaceAll("ä", "a")
      .replaceAll("ö", "o")
      .replaceAll("ü", "u")
      .replaceAll("-", " ")
      .replaceAll("_", " ")
      .replaceAll(RegExp(r'\s+'), " ");
}

  static Color _detectSingleColor(String name) {

    final normalized = _normalize(name);

    print("COLOR DEBUG → name: $name | normalized: $normalized");

    /// =========================
    /// BASIC COLORS (DE + EN)
    /// =========================

    if (normalized.contains("schwarz") || normalized.contains("black")) {
      return const Color(0xFF000000);
    }

    if (normalized.contains("weiss") || normalized.contains("weiß") || normalized.contains("white")) {
      return const Color(0xFFFFFFFF);
    }

    if (normalized.contains("grau") || normalized.contains("grey") || normalized.contains("gray")) {
      return const Color(0xFF9E9E9E);
    }

    if (normalized.contains("rot") || normalized.contains("red")) {
      return const Color(0xFFE53935);
    }

    // ===== SPEZIELLE BLAUTÖNE =====

if (normalized.contains("pastellblau")) {
  return const Color(0xFF64B5F6);
}

if (normalized.contains("hellblau")) {
  return const Color(0xFF42A5F5);
}

if (normalized.contains("dunkelblau")) {
  return const Color(0xFF1565C0);
}

if (normalized.contains("baby blau")) {
  return const Color(0xFF81D4FA);
}

if (normalized.contains("neon blau")) {
  return const Color(0xFF00E5FF);
}

if (normalized.contains("pastellpink")) {
  return const Color(0xFFF8BBD0);
}

if (normalized.contains("pastellgrun")) {
  return const Color(0xFFA5D6A7);
}

    if (normalized.contains("blau") || normalized.contains("blue")) {
      return const Color(0xFF1E88E5);
    }

    if (normalized.contains("grun") || normalized.contains("grün") || normalized.contains("green")) {
      return const Color(0xFF43A047);
    }

    if (normalized.contains("gelb") || normalized.contains("yellow")) {
      return const Color(0xFFFDD835);
    }

    if (normalized.contains("orange")) {
      return const Color(0xFFFB8C00);
    }

    if (normalized.contains("lila") ||
        normalized.contains("violett") ||
        normalized.contains("purple")) {
      return const Color(0xFF8E24AA);
    }

    if (normalized.contains("rosa") || normalized.contains("pink")) {
      return const Color(0xFFFF66CC);
    }

    if (normalized.contains("braun") || normalized.contains("brown")) {
      return const Color(0xFF6D4C41);
    }

    /// =========================
    /// METALLIC
    /// =========================

    if (normalized.contains("gold")) {
      return const Color(0xFFD4AF37);
    }

    if (normalized.contains("silver") || normalized.contains("silber")) {
      return const Color(0xFFC0C0C0);
    }

    if (normalized.contains("bronze")) {
      return const Color(0xFFCD7F32);
    }

    /// =========================
    /// SPECIAL COLORS
    /// =========================

    if (normalized.contains("mint")) {
      return const Color(0xFF3EB489);
    }

    if (normalized.contains("sky")) {
      return const Color(0xFF87CEEB);
    }

    if (normalized.contains("ocean")) {
      return const Color(0xFF1B4F72);
    }

    if (normalized.contains("lime")) {
      return const Color(0xFFCDDC39);
    }

    if (normalized.contains("cream")) {
      return const Color(0xFFFFFDD0);
    }

    if (normalized.contains("skin")) {
      return const Color(0xFFFFCC99);
    }

    if (normalized.contains("chocolate")) {
      return const Color(0xFF5D4037);
    }

    if (normalized.contains("jade")) {
      return const Color(0xFF00A86B);
    }

    if (normalized.contains("cyan")) {
      return const Color(0xFF00BCD4);
    }

    if (normalized.contains("magenta")) {
      return const Color(0xFFE040FB);
    }

    if (normalized.contains("beige")) {
      return const Color(0xFFF5F5DC);
    }

    if (normalized.contains("transparent")) {
      return Colors.grey.shade300;
    }

    /// =========================
    /// FALLBACK
    /// =========================

    return Colors.grey;
  }

  static List<Color> getColors(String colorName) {

    final normalized = _normalize(colorName);

    /// =========================
    /// MULTICOLOR (Trennung)
    /// =========================

    final separators = ["+", "/", "&", ","];

    for (final sep in separators) {
      if (normalized.contains(sep)) {
        final parts = normalized.split(sep);

        return parts
            .map((c) => _detectSingleColor(c))
            .toList();
      }
    }

    /// =========================
    /// SPEZIELLE FILAMENT NAMEN
    /// =========================

    if (normalized.contains("fluorite")) {
      return [
        const Color(0xFF69F793), // grün
        const Color(0xFF6DC1FD), // blau
        const Color(0xFFE290F9), // pink
      ];
    }

    if (normalized.contains("moonstone")) {
      return [
        const Color(0xFFDC8ADD), // rosa
        const Color(0xFF99C1F1), // blau
      ];
    }

    if (normalized.contains("rainbow")) {
      return [
        const Color(0xFFE53935),
        const Color(0xFFFB8C00),
        const Color(0xFFFDD835),
        const Color(0xFF43A047),
        const Color(0xFF1E88E5),
        const Color(0xFF8E24AA),
      ];
    }

    /// =========================
    /// STANDARD
    /// =========================

    return [_detectSingleColor(colorName)];
  }
}