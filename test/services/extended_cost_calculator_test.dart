import 'package:flutter_test/flutter_test.dart';

import 'package:filament_manager_v2/models/extended_costs.dart';
import 'package:filament_manager_v2/services/extended_cost_calculator.dart';

void main() {
  ExtendedCostResult calculate({
    required ExtendedCosts settings,
    double filamentCost = 5,
    double electricityCost = 1,
    double printTimeMinutes = 120,
    double objectWeightGrams = 100,
    double spoolWeightGrams = 1000,
    double spoolPrice = 20,
  }) {
    return ExtendedCostCalculator.calculate(
      filamentCost: filamentCost,
      electricityCost: electricityCost,
      printTimeMinutes: printTimeMinutes,
      objectWeightGrams: objectWeightGrams,
      spoolWeightGrams: spoolWeightGrams,
      spoolPrice: spoolPrice,
      settings: settings,
    );
  }

  group('Grundberechnung', () {
    test('Ohne Erweiterung bleiben die Grundkosten erhalten', () {
      final result = calculate(settings: ExtendedCosts());

      expect(result.filamentCost, 5);
      expect(result.electricityCost, 1);
      expect(result.baseCost, 6);
      expect(result.additionalCostTotal, 0);
      expect(result.productionCost, 6);
      expect(result.sellingCalculationEnabled, false);
    });

    test('Deaktivierte Erweiterung ignoriert ausgewählte Kosten', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: false,
          selected: {ExtendedCostType.maintenance},
          values: {'maintenancePerHour': 10},
        ),
      );

      expect(result.productionCost, 6);
      expect(result.additionalCosts, isEmpty);
    });

    test('Nicht ausgewählte Positionen werden ignoriert', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          values: {'maintenancePerHour': 50, 'additionalWearPerHour': 20},
        ),
      );

      expect(result.productionCost, 6);
      expect(result.additionalCosts, isEmpty);
    });
  });

  group('Drucker und Verschleiß', () {
    test('Druckerabschreibung verwendet Betriebsstunden', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {ExtendedCostType.printerDepreciation},
          values: {'printerPurchasePrice': 300, 'printerLifetimeHours': 3000},
        ),
      );

      expect(
        result.costFor(ExtendedCostType.printerDepreciation),
        closeTo(0.20, 0.000001),
      );

      expect(result.productionCost, closeTo(6.20, 0.000001));
    });

    test('Wartung und Verschleiß werden separat berechnet', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {
            ExtendedCostType.maintenance,
            ExtendedCostType.additionalWear,
          },
          values: {'maintenancePerHour': 0.50, 'additionalWearPerHour': 0.25},
        ),
      );

      expect(
        result.costFor(ExtendedCostType.maintenance),
        closeTo(1, 0.000001),
      );

      expect(
        result.costFor(ExtendedCostType.additionalWear),
        closeTo(0.50, 0.000001),
      );

      expect(result.productionCost, closeTo(7.50, 0.000001));
    });

    test('Lebensdauer null erzeugt keine Division durch null', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {ExtendedCostType.printerDepreciation},
          values: {'printerPurchasePrice': 300, 'printerLifetimeHours': 0},
        ),
      );

      expect(result.costFor(ExtendedCostType.printerDepreciation), 0);
    });
  });

  group('Arbeitszeit', () {
    test('Alle drei Arbeitspositionen sind unabhängig', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {
            ExtendedCostType.preparation,
            ExtendedCostType.postProcessing,
            ExtendedCostType.packagingWork,
          },
          values: {
            'preparationMinutes': 30,
            'preparationHourlyRate': 20,
            'postProcessingMinutes': 15,
            'postProcessingHourlyRate': 24,
            'packagingWorkMinutes': 10,
            'packagingWorkHourlyRate': 18,
          },
        ),
      );

      expect(
        result.costFor(ExtendedCostType.preparation),
        closeTo(10, 0.000001),
      );

      expect(
        result.costFor(ExtendedCostType.postProcessing),
        closeTo(6, 0.000001),
      );

      expect(
        result.costFor(ExtendedCostType.packagingWork),
        closeTo(3, 0.000001),
      );

      expect(result.additionalCostTotal, closeTo(19, 0.000001));
      expect(result.productionCost, closeTo(25, 0.000001));
    });
  });

  group('Risiko und Zusatzkosten', () {
    test('Fehldruckzuschlag basiert auf direkten Druckkosten', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {ExtendedCostType.failedPrint},
          values: {'failedPrintPercent': 10},
        ),
      );

      expect(
        result.costFor(ExtendedCostType.failedPrint),
        closeTo(0.60, 0.000001),
      );
    });

    test('Zusätzlicher Materialabfall wird separat berechnet', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {ExtendedCostType.supportAndWaste},
          values: {'additionalWasteGrams': 10, 'additionalWastePercent': 5},
        ),
      );

      // 10 g + 5 % von 100 g = 15 g.
      // 20 € / 1000 g = 0,02 € pro Gramm.
      expect(
        result.costFor(ExtendedCostType.supportAndWaste),
        closeTo(0.30, 0.000001),
      );
    });

    test('Materialien, Versand und Gemeinkosten bleiben getrennt', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {
            ExtendedCostType.additionalMaterials,
            ExtendedCostType.packagingAndShipping,
            ExtendedCostType.overhead,
          },
          values: {
            'additionalMaterialsCost': 2,
            'packagingCost': 1,
            'shippingCost': 4,
            'overheadCost': 0.50,
          },
        ),
      );

      expect(result.costFor(ExtendedCostType.additionalMaterials), 2);

      expect(result.costFor(ExtendedCostType.packagingAndShipping), 5);

      expect(result.costFor(ExtendedCostType.overhead), 0.50);

      expect(result.productionCost, closeTo(13.50, 0.000001));
    });
  });

  group('Verkauf und Gewinn', () {
    test('Gewinnaufschlag verändert Produktionskosten nicht', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {ExtendedCostType.profitMarkup},
          values: {'profitMarkupPercent': 25},
        ),
      );

      expect(result.productionCost, 6);
      expect(result.profitMarkupAmount, closeTo(1.50, 0.000001));
      expect(result.netSellingPrice, closeTo(7.50, 0.000001));
      expect(result.grossSellingPrice, closeTo(7.50, 0.000001));
      expect(result.actualProfit, closeTo(1.50, 0.000001));
    });

    test('Plattformgebühr auf Bruttopreis wird berücksichtigt', () {
      final result = calculate(
        settings: ExtendedCosts(
          enabled: true,
          selected: {
            ExtendedCostType.profitMarkup,
            ExtendedCostType.platformFees,
            ExtendedCostType.vat,
          },
          values: {
            'profitMarkupPercent': 25,
            'platformFeePercent': 10,
            'platformFixedFee': 0.50,
            'vatPercent': 19,
          },
        ),
      );

      expect(result.productionCost, 6);

      expect(result.netSellingPrice, closeTo(9.080590238, 0.000001));

      expect(result.grossSellingPrice, closeTo(10.805902384, 0.000001));

      expect(result.platformFeeAmount, closeTo(1.580590238, 0.000001));

      expect(result.vatAmount, closeTo(1.725312145, 0.000001));

      expect(result.actualProfit, closeTo(1.50, 0.000001));
    });

    test('Unmögliche Gebührenkonstellation wird abgelehnt', () {
      expect(
        () => calculate(
          settings: ExtendedCosts(
            enabled: true,
            selected: {ExtendedCostType.platformFees, ExtendedCostType.vat},
            values: {'platformFeePercent': 100, 'vatPercent': 19},
          ),
        ),
        throwsArgumentError,
      );
    });
  });

  group('Eingaben und Speicherung', () {
    test('Negative und ungültige Werte werden neutralisiert', () {
      final settings = ExtendedCosts(
        enabled: true,
        selected: {ExtendedCostType.maintenance},
        values: {'maintenancePerHour': -5, 'unusedValue': double.nan},
      );

      final result = calculate(
        settings: settings,
        filamentCost: -10,
        electricityCost: double.infinity,
      );

      expect(result.productionCost, 0);
      expect(settings.value('unusedValue'), 0);
    });

    test('Alle 14 Positionen besitzen eindeutige Kennungen', () {
      expect(ExtendedCostType.values.length, 14);

      final names = ExtendedCostType.values.map((type) => type.name).toSet();

      expect(names.length, 14);
    });

    test('JSON-Roundtrip erhält Auswahl und Eingabewerte', () {
      final original = ExtendedCosts(
        enabled: true,
        selected: {
          ExtendedCostType.printerDepreciation,
          ExtendedCostType.postProcessing,
          ExtendedCostType.vat,
        },
        values: {
          'printerPurchasePrice': 300,
          'printerLifetimeHours': 3000,
          'postProcessingMinutes': 20,
          'postProcessingHourlyRate': 18,
          'vatPercent': 19,
        },
      );

      final restored = ExtendedCosts.fromJson(original.toJson());

      expect(restored.enabled, true);
      expect(restored.selected, original.selected);
      expect(restored.values, original.values);
    });

    test('Fehlerhafte optionale JSON-Daten bleiben sicher', () {
      final restored = ExtendedCosts.fromJson({
        'enabled': true,
        'selected': ['maintenance', 'unknownFutureType'],
        'values': {
          'maintenancePerHour': '0,50',
          'invalid': 'not-a-number',
          'negative': -5,
        },
      });

      expect(restored.selected, {ExtendedCostType.maintenance});

      expect(restored.value('maintenancePerHour'), 0.50);
      expect(restored.values.containsKey('invalid'), false);
      expect(restored.values.containsKey('negative'), false);
    });
  });
}
