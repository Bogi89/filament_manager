import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

class ColorNameLocalizer {
  const ColorNameLocalizer._();

  static String localize(BuildContext context, String colorName) {
    final l10n = AppLocalizations.of(context)!;
    final normalized = colorName.trim().toLowerCase();

    switch (normalized) {
      // Schwarz
      case 'schwarz':
      case 'black':
        return l10n.colorBlack;

      // Weiß
      case 'weiß':
      case 'weiss':
      case 'white':
        return l10n.colorWhite;

      // Grau
      case 'grau':
      case 'gray':
      case 'grey':
        return l10n.colorGray;

      // Rot
      case 'rot':
      case 'red':
        return l10n.colorRed;

      // Grün
      case 'grün':
      case 'gruen':
      case 'green':
        return l10n.colorGreen;

      // Blau
      case 'blau':
      case 'blue':
        return l10n.colorBlue;

      // Gelb
      case 'gelb':
      case 'yellow':
        return l10n.colorYellow;

      // Orange
      case 'orange':
        return l10n.colorOrange;

      // Lila / Violett
      case 'lila':
      case 'violett':
      case 'purple':
        return l10n.colorPurple;

      // Pink / Rosa
      case 'pink':
      case 'rosa':
        return l10n.colorPink;

      // Braun
      case 'braun':
      case 'brown':
        return l10n.colorBrown;

      // Türkis
      case 'türkis':
      case 'tuerkis':
      case 'turquoise':
        return l10n.colorTurquoise;

      // Gold
      case 'gold':
        return l10n.colorGold;

      // Silber
      case 'silber':
      case 'silver':
        return l10n.colorSilver;

      // Bronze
      case 'bronze':
        return l10n.colorBronze;

      // Kupfer
      case 'kupfer':
      case 'copper':
        return l10n.colorCopper;

      // Beige
      case 'beige':
        return l10n.colorBeige;

      // Creme
      case 'creme':
      case 'cream':
        return l10n.colorCream;

      // Cyan
      case 'cyan':
        return l10n.colorCyan;

      // Magenta
      case 'magenta':
        return l10n.colorMagenta;

      // Anthrazit
      case 'anthrazit':
      case 'anthrazitgrau':
      case 'anthracite':
        return l10n.colorAnthracite;

      // Graphit
      case 'graphit':
      case 'graphite':
        return l10n.colorGraphite;

      // Khaki
      case 'khaki':
        return l10n.colorKhaki;

      // Olive
      case 'olive':
      case 'oliv':
        return l10n.colorOlive;

      // Lime
      case 'lime':
      case 'limette':
        return l10n.colorLime;

      // Teal
      case 'teal':
      case 'blaugrün':
      case 'blaugruen':
        return l10n.colorTeal;

      // Burgunder
      case 'burgunderrot':
      case 'burgundy':
        return l10n.colorBurgundy;

      // Terrakotta
      case 'terrakotta':
      case 'terracotta':
        return l10n.colorTerracotta;

      // Pfirsich
      case 'pfirsich':
      case 'peach':
        return l10n.colorPeach;

      // Aprikose
      case 'aprikose':
      case 'apricot':
        return l10n.colorApricot;

      // Lavendel
      case 'lavendel':
      case 'lavender':
        return l10n.colorLavender;

      // Klar
      case 'klar':
      case 'clear':
        return l10n.colorClear;

      // Transparent
      case 'transparent':
        return l10n.colorTransparent;

      // Natur
      case 'natur':
      case 'natural':
        return l10n.colorNatural;

      // Dunkelblau
      case 'dunkelblau':
      case 'dark blue':
        return l10n.colorDarkBlue;

      // Hellblau
      case 'hellblau':
      case 'light blue':
        return l10n.colorLightBlue;

      // Dunkelgrün
      case 'dunkelgrün':
      case 'dunkelgruen':
      case 'dark green':
        return l10n.colorDarkGreen;

      // Hellgrün
      case 'hellgrün':
      case 'hellgruen':
      case 'light green':
        return l10n.colorLightGreen;

      // Dunkelrot
      case 'dunkelrot':
      case 'dark red':
        return l10n.colorDarkRed;

      // Hellrot
      case 'hellrot':
      case 'light red':
        return l10n.colorLightRed;

      // Dunkelgrau
      case 'dunkelgrau':
      case 'dark gray':
      case 'dark grey':
        return l10n.colorDarkGray;

      // Hellgrau
      case 'hellgrau':
      case 'light gray':
      case 'light grey':
        return l10n.colorLightGray;

      // Dunkelbraun
      case 'dunkelbraun':
      case 'dark brown':
        return l10n.colorDarkBrown;

      // Hellbraun
      case 'hellbraun':
      case 'light brown':
        return l10n.colorLightBrown;

      // Dunkelorange
      case 'dunkelorange':
      case 'dunklesorange':
      case 'dark orange':
        return l10n.colorDarkOrange;

      // Hellorange
      case 'hellorange':
      case 'light orange':
        return l10n.colorLightOrange;

      // Kein allgemeiner Farbname:
      // Hersteller-/Produktbezeichnung unverändert anzeigen.
      default:
        return colorName;
    }
  }
}