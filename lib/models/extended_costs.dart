enum ExtendedCostType {
  printerDepreciation,
  maintenance,
  additionalWear,
  preparation,
  postProcessing,
  packagingWork,
  failedPrint,
  supportAndWaste,
  additionalMaterials,
  packagingAndShipping,
  overhead,
  profitMarkup,
  platformFees,
  vat,
}

extension ExtendedCostTypeExtension on ExtendedCostType {
  bool get isSellingCost {
    return this == ExtendedCostType.profitMarkup ||
        this == ExtendedCostType.platformFees ||
        this == ExtendedCostType.vat;
  }
}

class ExtendedCosts {
  final bool enabled;
  final Set<ExtendedCostType> selected;
  final Map<String, double> values;

  ExtendedCosts({
    this.enabled = false,
    Set<ExtendedCostType>? selected,
    Map<String, double>? values,
  }) : selected = Set.unmodifiable(selected ?? {}),
       values = Map.unmodifiable(values ?? {});

  bool isSelected(ExtendedCostType type) {
    return enabled && selected.contains(type);
  }

  double value(String key) {
    final number = values[key] ?? 0.0;
    return number.isFinite && number >= 0 ? number : 0.0;
  }

  ExtendedCosts copyWith({
    bool? enabled,
    Set<ExtendedCostType>? selected,
    Map<String, double>? values,
  }) {
    return ExtendedCosts(
      enabled: enabled ?? this.enabled,
      selected: selected ?? this.selected,
      values: values ?? this.values,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'selected': selected.map((type) => type.name).toList(),
      'values': values,
    };
  }

  factory ExtendedCosts.fromJson(Map<String, dynamic> json) {
    final selected = <ExtendedCostType>{};

    final rawSelected = json['selected'];

    if (rawSelected is List) {
      for (final item in rawSelected) {
        for (final type in ExtendedCostType.values) {
          if (type.name == item.toString()) {
            selected.add(type);
            break;
          }
        }
      }
    }

    final values = <String, double>{};
    final rawValues = json['values'];

    if (rawValues is Map) {
      for (final entry in rawValues.entries) {
        final raw = entry.value;
        double? number;

        if (raw is num) {
          number = raw.toDouble();
        } else if (raw is String) {
          number = double.tryParse(raw.replaceAll(',', '.'));
        }

        if (number != null && number.isFinite && number >= 0) {
          values[entry.key.toString()] = number;
        }
      }
    }

    return ExtendedCosts(
      enabled: json['enabled'] == true,
      selected: selected,
      values: values,
    );
  }
}

class ExtendedCostResult {
  final double filamentCost;
  final double electricityCost;
  final Map<ExtendedCostType, double> additionalCosts;

  final double productionCost;
  final double profitMarkupAmount;
  final double platformFeeAmount;
  final double vatAmount;
  final double netSellingPrice;
  final double grossSellingPrice;
  final double actualProfit;

  final bool sellingCalculationEnabled;

  ExtendedCostResult({
    required this.filamentCost,
    required this.electricityCost,
    required Map<ExtendedCostType, double> additionalCosts,
    required this.productionCost,
    required this.profitMarkupAmount,
    required this.platformFeeAmount,
    required this.vatAmount,
    required this.netSellingPrice,
    required this.grossSellingPrice,
    required this.actualProfit,
    required this.sellingCalculationEnabled,
  }) : additionalCosts = Map.unmodifiable(additionalCosts);

  double get baseCost => filamentCost + electricityCost;

  double get additionalCostTotal {
    return additionalCosts.values.fold(0.0, (sum, value) => sum + value);
  }

  double costFor(ExtendedCostType type) {
    return additionalCosts[type] ?? 0.0;
  }
}
