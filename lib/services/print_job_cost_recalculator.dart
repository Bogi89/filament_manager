import '../models/print_job.dart';
import 'extended_cost_calculator.dart';

/// Recalculates print costs using stored inputs or documented legacy rates.
class PrintJobCostRecalculator {
  const PrintJobCostRecalculator._();

  static PrintJob? recalculate(
    PrintJob job, {
    required double weight,
    required double minutes,
    double? manualTotal,
  }) {
    if (!weight.isFinite || weight < 0 || !minutes.isFinite || minutes < 0) {
      return null;
    }
    final inputs = job.calculationInputs;
    final spoolWeight = inputs['spoolWeightGrams'];
    final spoolPrice = inputs['spoolPrice'];
    final watt = inputs['printerWatt'];
    final electricityRate = inputs['electricityPricePerKwh'];
    final complete =
        spoolWeight != null &&
        spoolWeight > 0 &&
        spoolPrice != null &&
        watt != null &&
        electricityRate != null;

    final oldFilament = job.costBreakdown['filamentCost'];
    final oldElectricity = job.costBreakdown['electricityCost'];
    final legacy =
        !complete &&
        oldFilament != null &&
        oldElectricity != null &&
        job.weightUsed > 0 &&
        (job.printMinutes > 0 || oldElectricity == 0);

    if (!complete && !legacy) {
      if (manualTotal == null) {
        return null;
      }
      final breakdown = Map<String, double>.from(job.costBreakdown);
      breakdown.clear();
      breakdown['productionCost'] = manualTotal;
      return job.copyWith(
        weightUsed: weight,
        printMinutes: minutes,
        totalCost: manualTotal,
        costBreakdown: breakdown,
        sellingPrice: null,
      );
    }

    final perGram = complete
        ? spoolPrice / spoolWeight
        : oldFilament! / job.weightUsed;
    final perMinute = complete
        ? watt / 1000 * electricityRate / 60
        : (job.printMinutes > 0 ? oldElectricity! / job.printMinutes : 0.0);
    if (!perGram.isFinite ||
        !perMinute.isFinite ||
        perGram < 0 ||
        perMinute < 0) {
      return null;
    }
    final result = ExtendedCostCalculator.calculate(
      filamentCost: perGram * weight,
      electricityCost: perMinute * minutes,
      printTimeMinutes: minutes,
      objectWeightGrams: weight,
      spoolWeightGrams: complete ? spoolWeight : 1,
      spoolPrice: complete ? spoolPrice : perGram,
      settings: job.extendedCosts,
    );
    final breakdown = <String, double>{
      'filamentCost': result.filamentCost,
      'electricityCost': result.electricityCost,
    };
    for (final entry in result.additionalCosts.entries) {
      breakdown[entry.key.name] = entry.value;
    }
    final computed = result.productionCost;
    final actual = manualTotal ?? computed;
    final adjustment = actual - computed;
    if (adjustment.abs() > 0.0000001) {
      breakdown['manualAdjustment'] = adjustment;
    }
    breakdown['productionCost'] = actual;
    double? sellingPrice;
    if (result.sellingCalculationEnabled) {
      // A manual override changes the production-cost base. Avoid stale sales figures.
      if (manualTotal == null) {
        breakdown.addAll({
          'profitMarkupAmount': result.profitMarkupAmount,
          'platformFeeAmount': result.platformFeeAmount,
          'vatAmount': result.vatAmount,
          'netSellingPrice': result.netSellingPrice,
          'grossSellingPrice': result.grossSellingPrice,
          'actualProfit': result.actualProfit,
        });
        sellingPrice = result.grossSellingPrice;
      }
    }
    return job.copyWith(
      weightUsed: weight,
      printMinutes: minutes,
      totalCost: actual,
      costBreakdown: breakdown,
      sellingPrice: sellingPrice,
    )..sellingPrice = sellingPrice;
  }
}
