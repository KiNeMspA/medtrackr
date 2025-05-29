// lib/features/medication/utils/reconstitution_calculator.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';

class ReconstitutionCalculator {
  final TextEditingController quantityController;
  final TextEditingController targetDoseController;
  final String quantityUnit;
  final TargetDoseUnit targetDoseUnit;
  final double fluidAmount;

  ReconstitutionCalculator({
    required this.quantityController,
    required this.targetDoseController,
    required this.quantityUnit,
    required this.targetDoseUnit,
    required this.fluidAmount,
  });

  List<Map<String, dynamic>> calculateReconstitutions() {
    final quantity = double.tryParse(quantityController.text) ?? 0.0;
    final targetDose = double.tryParse(targetDoseController.text) ?? 0.0;

    if (quantity <= 0 || targetDose <= 0 || fluidAmount <= 0) return [];

    double quantityInMg = _convertToMg(quantity, quantityUnit);
    double targetDoseInMcg = _convertTargetDoseToMcg(targetDose, targetDoseUnit);

    if (quantityInMg <= 0 || targetDoseInMcg <= 0) return [];

    final List<Map<String, dynamic>> suggestions = [];
    final concentration = (quantityInMg / fluidAmount) * 100; // IU per mL

    for (var syringeSize in SyringeSize.values) {
      final maxIU = syringeSize.maxIU;
      double volume = targetDoseInMcg / concentration;
      double syringeUnits = (volume / syringeSize.maxVolume) * maxIU;

      if (syringeUnits <= maxIU && syringeUnits >= maxIU * 0.05) {
        suggestions.add({
          'syringeSize': syringeSize.value,
          'syringeUnits': syringeUnits,
          'volume': volume,
          'targetDose': targetDose,
          'targetDoseUnit': targetDoseUnit.displayName,
          'concentration': concentration,
        });
      }
    }

    return suggestions;
  }

  double _convertToMg(double quantity, String unit) {
    switch (unit) {
      case 'mg':
        return quantity;
      case 'g':
        return quantity * 1000;
      case 'mcg':
        return quantity / 1000;
      default:
        return quantity;
    }
  }

  double _convertTargetDoseToMcg(double dose, TargetDoseUnit unit) {
    switch (unit) {
      case TargetDoseUnit.mcg:
        return dose;
      case TargetDoseUnit.mg:
        return dose * 1000;
      case TargetDoseUnit.g:
        return dose * 1000000;
      default:
        return dose;
    }
  }
}