import '../models/extended_costs.dart';

class ExtendedCostCalculator {
  const ExtendedCostCalculator._();

  static ExtendedCostResult calculate({
    required double filamentCost,
    required double electricityCost,
    required double printTimeMinutes,
    required double objectWeightGrams,
    required double spoolWeightGrams,
    required double spoolPrice,
    required ExtendedCosts settings,
  }) {
    final safeFilamentCost = _safe(filamentCost);
    final safeElectricityCost = _safe(electricityCost);
    final minutes = _safe(printTimeMinutes);
    final hours = minutes / 60.0;
    final weight = _safe(objectWeightGrams);
    final spoolWeight = _safe(spoolWeightGrams);
    final price = _safe(spoolPrice);

    final materialPricePerGram = spoolWeight > 0 ? price / spoolWeight : 0.0;

    final additional = <ExtendedCostType, double>{};

    double input(String key) => settings.value(key);

    void add(ExtendedCostType type, double amount) {
      if (settings.isSelected(type)) {
        additional[type] = _safe(amount);
      }
    }

    // 1. Druckerabschreibung:
    // Kaufpreis / Lebensdauer in Betriebsstunden.
    final printerPrice = input('printerPurchasePrice');
    final printerLifetime = input('printerLifetimeHours');

    add(
      ExtendedCostType.printerDepreciation,
      printerLifetime > 0 ? printerPrice / printerLifetime * hours : 0,
    );

    // 2. Wartung und Ersatzteile.
    add(ExtendedCostType.maintenance, input('maintenancePerHour') * hours);

    // 3. Zusätzlicher Verschleiß.
    add(
      ExtendedCostType.additionalWear,
      input('additionalWearPerHour') * hours,
    );

    // 4. Druckvorbereitung.
    add(
      ExtendedCostType.preparation,
      input('preparationMinutes') / 60.0 * input('preparationHourlyRate'),
    );

    // 5. Nachbearbeitung.
    add(
      ExtendedCostType.postProcessing,
      input('postProcessingMinutes') / 60.0 * input('postProcessingHourlyRate'),
    );

    // 6. Verpackungsarbeit.
    add(
      ExtendedCostType.packagingWork,
      input('packagingWorkMinutes') / 60.0 * input('packagingWorkHourlyRate'),
    );

    // 7. Fehldruckzuschlag:
    // Prozentualer Zuschlag auf die direkten Druckkosten.
    final failureBase = safeFilamentCost + safeElectricityCost;

    add(
      ExtendedCostType.failedPrint,
      failureBase * input('failedPrintPercent') / 100.0,
    );

    // 8. Support und Materialabfall:
    // Nur zusätzliches, noch nicht erfasstes Material.
    final extraWasteGrams = input('additionalWasteGrams');
    final extraWastePercent = input('additionalWastePercent');

    final wasteGrams = extraWasteGrams + weight * extraWastePercent / 100.0;

    add(ExtendedCostType.supportAndWaste, wasteGrams * materialPricePerGram);

    // 9. Zusätzliche Materialien.
    add(ExtendedCostType.additionalMaterials, input('additionalMaterialsCost'));

    // 10. Verpackung und Versand.
    add(
      ExtendedCostType.packagingAndShipping,
      input('packagingCost') + input('shippingCost'),
    );

    // 11. Sonstige Gemeinkosten.
    add(ExtendedCostType.overhead, input('overheadCost'));

    final additionalTotal = additional.values.fold<double>(
      0.0,
      (sum, amount) => sum + amount,
    );

    final productionCost =
        safeFilamentCost + safeElectricityCost + additionalTotal;

    // 12-14. Verkauf und Gewinn werden getrennt
    // von den Produktionskosten berechnet.
    final sellingEnabled =
        settings.enabled &&
        (settings.selected.contains(ExtendedCostType.profitMarkup) ||
            settings.selected.contains(ExtendedCostType.platformFees) ||
            settings.selected.contains(ExtendedCostType.vat));

    final markupPercent = settings.isSelected(ExtendedCostType.profitMarkup)
        ? input('profitMarkupPercent')
        : 0.0;

    final feePercent = settings.isSelected(ExtendedCostType.platformFees)
        ? input('platformFeePercent')
        : 0.0;

    final fixedFee = settings.isSelected(ExtendedCostType.platformFees)
        ? input('platformFixedFee')
        : 0.0;

    final vatPercent = settings.isSelected(ExtendedCostType.vat)
        ? input('vatPercent')
        : 0.0;

    final desiredProfit = productionCost * markupPercent / 100.0;

    final desiredNetRevenue = productionCost + desiredProfit;

    final vatFactor = 1.0 + vatPercent / 100.0;
    final feeFactor = feePercent / 100.0;

    // Plattformgebühren beziehen sich auf den
    // Bruttoverkaufspreis.
    //
    // Nettoerlös nach Gebühren soll mindestens
    // Produktionskosten + gewünschten Gewinn ergeben.
    //
    // netPrice - feePercent * grossPrice
    //          - fixedFee = desiredNetRevenue
    //
    // grossPrice = netPrice * vatFactor

    final denominator = 1.0 - feeFactor * vatFactor;

    double netSellingPrice = 0.0;
    double grossSellingPrice = 0.0;
    double platformFeeAmount = 0.0;
    double vatAmount = 0.0;
    double actualProfit = 0.0;

    if (sellingEnabled) {
      if (denominator <= 0) {
        throw ArgumentError(
          'Die Verkaufsplattformgebühren sind '
          'für diese Berechnung zu hoch.',
        );
      }

      netSellingPrice = (desiredNetRevenue + fixedFee) / denominator;

      grossSellingPrice = netSellingPrice * vatFactor;

      vatAmount = grossSellingPrice - netSellingPrice;

      platformFeeAmount = grossSellingPrice * feeFactor + fixedFee;

      actualProfit = netSellingPrice - platformFeeAmount - productionCost;
    }

    return ExtendedCostResult(
      filamentCost: safeFilamentCost,
      electricityCost: safeElectricityCost,
      additionalCosts: additional,
      productionCost: productionCost,
      profitMarkupAmount: desiredProfit,
      platformFeeAmount: platformFeeAmount,
      vatAmount: vatAmount,
      netSellingPrice: netSellingPrice,
      grossSellingPrice: grossSellingPrice,
      actualProfit: actualProfit,
      sellingCalculationEnabled: sellingEnabled,
    );
  }

  static double _safe(double value) {
    if (!value.isFinite || value < 0) {
      return 0.0;
    }

    return value;
  }
}
