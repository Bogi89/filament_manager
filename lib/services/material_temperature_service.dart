class MaterialTemperatureService {
  MaterialTemperatureService._();

  /// Allgemeine Startwerte in °C.
  /// Herstellerangaben haben immer Vorrang.
  static const Map<String, ({int nozzle, int bed})> _profiles = {
    'PLA': (nozzle: 200, bed: 60),
    'PLA+': (nozzle: 210, bed: 60),
    'PLA-CF': (nozzle: 215, bed: 60),
    'PLA-GF': (nozzle: 215, bed: 60),
    'PLA-LW': (nozzle: 230, bed: 55),
    'PLA-METAL': (nozzle: 210, bed: 60),
    'PLA-WOOD': (nozzle: 200, bed: 60),

    'PETG': (nozzle: 240, bed: 80),
    'PETG+': (nozzle: 245, bed: 80),
    'PETG-CF': (nozzle: 250, bed: 80),
    'PETG-GF': (nozzle: 250, bed: 80),
    'PCTG': (nozzle: 255, bed: 80),
    'PET': (nozzle: 235, bed: 70),

    'ABS': (nozzle: 250, bed: 100),
    'ABS+': (nozzle: 255, bed: 100),
    'ABS-CF': (nozzle: 255, bed: 100),
    'ASA': (nozzle: 250, bed: 100),
    'ASA-CF': (nozzle: 260, bed: 100),
    'ASA-GF': (nozzle: 260, bed: 100),
    'HIPS': (nozzle: 240, bed: 105),

    'TPU': (nozzle: 220, bed: 50),
    'TPE': (nozzle: 225, bed: 50),
    'TPC': (nozzle: 240, bed: 60),

    'PA': (nozzle: 260, bed: 90),
    'PA6': (nozzle: 270, bed: 90),
    'PA12': (nozzle: 260, bed: 90),
    'PA-CF': (nozzle: 280, bed: 90),
    'PA-GF': (nozzle: 280, bed: 90),

    'PC': (nozzle: 270, bed: 110),
    'PC-ABS': (nozzle: 265, bed: 110),
    'PP': (nozzle: 230, bed: 85),
    'CPE': (nozzle: 275, bed: 100),

    'PVA': (nozzle: 205, bed: 60),
    'BVOH': (nozzle: 210, bed: 60),
    'PVB': (nozzle: 215, bed: 75),
    'PMMA': (nozzle: 240, bed: 100),
  };

  static const Map<String, String> _aliases = {
    'PLA CF': 'PLA-CF',
    'PLA GF': 'PLA-GF',
    'PLA LW': 'PLA-LW',
    'PLA+/PRO': 'PLA+',
    'RPLA': 'PLA',
    'RPETG': 'PETG',
    'EPLA': 'PLA',
    'EPETG': 'PETG',
    'PETG CF': 'PETG-CF',
    'PETG GF': 'PETG-GF',
    'ABS CF': 'ABS-CF',
    'ASA CF': 'ASA-CF',
    'ASA GF': 'ASA-GF',
    'PA CF': 'PA-CF',
    'PA GF': 'PA-GF',
    'NYLON': 'PA',
    'NYLON 6': 'PA6',
    'NYLON 12': 'PA12',
    'PA NYLON': 'PA',
    'PC ABS': 'PC-ABS',
  };

  /// Bestätigte produktspezifische Startwerte.
  /// Schlüssel: MATERIAL|HERSTELLER|VARIANTE
  static const Map<String, ({int nozzle, int bed})> _productProfiles = {
    // FormFutura
    'ASA|FORMFUTURA|APOLLOX': (nozzle: 245, bed: 90),
    'EPLA|FORMFUTURA|EASYFIL': (nozzle: 210, bed: 55),
    'EPETG|FORMFUTURA|EASYFIL': (nozzle: 245, bed: 85),
    'PCL-WOOD|FORMFUTURA|BIOFIL': (nozzle: 205, bed: 55),
    'RPET|FORMFUTURA|REFORM': (nozzle: 240, bed: 70),
    'RTPU|FORMFUTURA|BASIC': (nozzle: 235, bed: 70),

    // Fiberlogy
    'PLA|FIBERLOGY|FIBERSILK': (nozzle: 220, bed: 60),
    'PLA-WOOD|FIBERLOGY|FIBERWOOD': (nozzle: 200, bed: 60),
    'PVB|FIBERLOGY|FIBERSMOOTH': (nozzle: 220, bed: 75),
    'TPU|FIBERLOGY|FIBERFLEX 30D': (nozzle: 210, bed: 60),
    'TPU|FIBERLOGY|FIBERFLEX 40D': (nozzle: 210, bed: 60),
    'TPU|FIBERLOGY|MATTFLEX 40D': (nozzle: 220, bed: 60),
    'PETG+PTFE|FIBERLOGY|BASIC': (nozzle: 230, bed: 90),

    // Spectrum
    'PLA-WOOD|SPECTRUM|BASIC': (nozzle: 205, bed: 40),
    'PETG+PTFE|SPECTRUM|BASIC': (nozzle: 240, bed: 70),
    'RPLA|SPECTRUM|BASIC': (nozzle: 200, bed: 45),
    'RPETG|SPECTRUM|BASIC': (nozzle: 240, bed: 40),

    // Bambu Lab
    'PAHT|BAMBU LAB|CF': (nozzle: 275, bed: 90),
    'PAHT|BAMBU LAB|SUPPORT': (nozzle: 275, bed: 90),
    'PPA|BAMBU LAB|CF': (nozzle: 295, bed: 110),
    'PPS|BAMBU LAB|CF': (nozzle: 325, bed: 110),

    // ELEGOO
    'PAHT|ELEGOO|CF': (nozzle: 275, bed: 100),

    // Creality
    'PPA|CREALITY|CF': (nozzle: 290, bed: 100),
    'PA612|CREALITY|CF': (nozzle: 290, bed: 80),

    // Polymaker
    'PA612|POLYMAKER|CF': (nozzle: 275, bed: 45),
    'PA612|POLYMAKER|POLYMIDE': (nozzle: 275, bed: 40),
    'COPA|POLYMAKER|POLYMIDE': (nozzle: 260, bed: 40),
    'PPS|POLYMAKER|CF': (nozzle: 330, bed: 85),
    'PPS|POLYMAKER|GF': (nozzle: 330, bed: 90),
    'HT PLA|POLYMAKER|BASIC': (nozzle: 220, bed: 55),
    'HT PLA|POLYMAKER|GF': (nozzle: 220, bed: 55),
    'HT PLA|POLYMAKER|GRADIENT': (nozzle: 220, bed: 55),
    'HT PLA|POLYMAKER|HT': (nozzle: 220, bed: 55),
    'HT PLA|POLYMAKER|PRO': (nozzle: 220, bed: 55),

    // Extrudr
    'PC PBT|EXTRUDR|CF': (nozzle: 275, bed: 105),
    'PC PBT|EXTRUDR|PRO': (nozzle: 275, bed: 110),
    'HT PLA|EXTRUDR|HT': (nozzle: 220, bed: 55),

    // ColorFabb
    'HT PLA|COLORFABB|LW': (nozzle: 220, bed: 55),
    'PLA/PHA|COLORFABB|WOOD': (nozzle: 220, bed: 55),
    'PLA/PHA|COLORFABB|OTHER': (nozzle: 200, bed: 60),

    // SUNLU und Jayo
    'APLA|SUNLU|BASIC': (nozzle: 210, bed: 55),
    'APLA|SUNLU|MATTE': (nozzle: 225, bed: 55),
    'APLA|JAYO|BASIC': (nozzle: 225, bed: 55),

    // eSUN
    'PEBA|ESUN|90A': (nozzle: 245, bed: 75),
    'ASA+|ESUN|BASIC': (nozzle: 265, bed: 105),

    // Ultimaker
    'CPE+|ULTIMAKER|BASIC': (nozzle: 260, bed: 110),
    'ABS-R|ULTIMAKER|METHOD X': (nozzle: 245, bed: 100),

    // Redline Filament
    'ASA+|REDLINE FILAMENT|OTHER': (nozzle: 250, bed: 100),
  };

  /// Ermittelt einen Temperaturvorschlag.
  ///
  /// Reihenfolge:
  /// 1. Material + Hersteller + Variante
  /// 2. Allgemeines Materialprofil
  /// 3. null bei unbekanntem Material
  static ({int nozzle, int bed})? getTemperatures(
    String material, {
    String? brand,
    String? variant,
  }) {
    final normalizedMaterial = material.trim().toUpperCase();
    final key = _aliases[normalizedMaterial] ?? normalizedMaterial;

    if (brand != null && variant != null) {
      final normalizedBrand = brand.trim().toUpperCase();
      final normalizedVariant = variant.trim().toUpperCase();

      // Zuerst das exakte Material aus dem Katalog prüfen.
      final exactProductKey =
          '$normalizedMaterial|$normalizedBrand|$normalizedVariant';

      final exactTemperatures = _productProfiles[exactProductKey];

      if (exactTemperatures != null) {
        return exactTemperatures;
      }

      // Danach gegebenenfalls den allgemeinen Material-Alias prüfen.
      if (key != normalizedMaterial) {
        final aliasProductKey = '$key|$normalizedBrand|$normalizedVariant';

        final aliasTemperatures = _productProfiles[aliasProductKey];

        if (aliasTemperatures != null) {
          return aliasTemperatures;
        }
      }
    }

    return _profiles[key];
  }
}
