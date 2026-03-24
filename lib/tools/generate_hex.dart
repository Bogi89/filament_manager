import 'dart:io';

void main() {

  final inputFile = File('assets/data/filament_catalog.csv');
  final outputFile = File('assets/data/filament_catalog_with_hex.csv');

  final lines = inputFile.readAsLinesSync();

  final List<String> output = [];

  // Header erweitern
  output.add("${lines.first},hex");

  for (int i = 1; i < lines.length; i++) {

  final row = lines[i];

  if (row.trim().isEmpty) continue;

  final parts = row.split(';');

  if (parts.length < 4) continue;

  final colorName = parts[3].toLowerCase();

  final hex = detectColor(colorName);

  output.add("$row;$hex");
}

  outputFile.writeAsStringSync(output.join("\n"));

  print("✅ Fertig! Neue Datei: filament_catalog_with_hex.csv");
}

String detectColor(String name) {

  name = name.toLowerCase();

  if (name.contains("black") || name.contains("schwarz")) return "#000000";
  if (name.contains("white") || name.contains("weiß") || name.contains("weiss")) return "#FFFFFF";

  if (name.contains("red") || name.contains("rot")) return "#E53935";
  if (name.contains("blue") || name.contains("blau")) return "#1E88E5";
  if (name.contains("green") || name.contains("grün")) return "#43A047";
  if (name.contains("yellow") || name.contains("gelb")) return "#FDD835";
  if (name.contains("orange")) return "#FB8C00";

  if (name.contains("purple") || name.contains("lila")) return "#8E24AA";
  if (name.contains("pink") || name.contains("rosa")) return "#FF66CC";

  if (name.contains("brown") || name.contains("braun")) return "#6D4C41";
  if (name.contains("grey") || name.contains("gray") || name.contains("grau")) return "#9E9E9E";

  if (name.contains("gold")) return "#D4AF37";
  if (name.contains("silver")) return "#C0C0C0";
  if (name.contains("beige")) return "#F5F5DC";

  // nicht erkannte Farben leer lassen
  return "";
}