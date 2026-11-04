import '../models/filament.dart';
import 'filament_catalog_service.dart';

/// Ergänzt fehlende Materialdichten aus dem Filamentkatalog.
///
/// Bereits gespeicherte Dichtewerte werden niemals überschrieben.
/// Nicht eindeutig zuordenbare Werte bleiben unverändert.
class FilamentDensityMigrationService {
  FilamentDensityMigrationService._();

  /// Gibt die Anzahl der ergänzten Dichtewerte zurück.
  ///
  /// Die übergebene Liste wird direkt aktualisiert.
  /// Das dauerhafte Speichern übernimmt der AppState.
  static int migrate(List<Filament> filaments) {
    var updatedCount = 0;

    for (final filament in filaments) {
      // Manuell oder zuvor gespeicherte Dichten erhalten.
      if (filament.density != null) {
        continue;
      }

      // Hersteller, Material und Variante abgleichen.
      // Bei widersprüchlichen Dichten werden zusätzlich
      // die gespeicherten Farbnamen berücksichtigt.
      final density = FilamentCatalogService.getDensity(
        filament.brand,
        filament.material,
        filament.variant,
        colorNames: filament.colorNames,
      );

      // Keine ungültigen oder unklaren Werte übernehmen.
      if (density == null || !density.isFinite || density <= 0) {
        continue;
      }

      filament.density = density;
      updatedCount++;
    }

    return updatedCount;
  }
}
