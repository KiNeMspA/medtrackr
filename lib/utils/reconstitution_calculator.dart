import 'package:flutter/material.dart';

class ReconstitutionCalculator {
  final TextEditingController quantityController;
  final TextEditingController targetDoseController;
  final String quantityUnit;
  final String targetDoseUnit;
  final String medicationName;

  ReconstitutionCalculator({
    required this.quantityController,
    required this.targetDoseController,
    required this.quantityUnit,
    required this.targetDoseUnit,
    required this.medicationName,
  });

  double _convertToIU(String unit, double value) {
    switch (unit) {
      case 'g':
        return value * 1e9; // Convert g to IU (assuming 1 IU = 1 mcg for simplicity)
      case 'mg':
        return value * 1e6; // Convert mg to IU
      case 'mcg':
        return value * 1e3; // Convert mcg to IU
      case 'IU':
        return value; // No conversion needed
      case 'Unit':
        return value; // Assume 1 Unit = 1 IU
      default:
        return value;
    }
  }

  Map<String, dynamic> calculate() {
    final quantity = double.tryParse(quantityController.text) ?? 0.0;
    final targetDose = double.tryParse(targetDoseController.text) ?? 0.0;

    // Convert quantities to IU for consistent calculation
    final quantityIU = _convertToIU(quantityUnit, quantity);
    final targetDoseIU = _convertToIU(targetDoseUnit, targetDose);

    // Generate reconstitution suggestions (0.3mL to 5mL syringe sizes)
    final suggestions = <Map<String, dynamic>>[];
    final syringeSizes = [0.3, 0.5, 1.0, 2.0, 5.0];
    for (var volume in syringeSizes) {
      if (quantityIU > 0 && volume > 0) {
        final iuPerML = quantityIU / volume;
        if (iuPerML >= 1) {
          suggestions.add({
            'volume': volume,
            'iu': quantityIU,
            'iuPerML': iuPerML,
          });
        }
      }
    }

    // Select the suggestion closest to target dose, if any
    Map<String, dynamic>? selectedReconstitution;
    if (suggestions.isNotEmpty) {
      selectedReconstitution = suggestions.reduce((a, b) {
        final aDiff = (a['iuPerML'] - (targetDoseIU / a['volume'])).abs();
        final bDiff = (b['iuPerML'] - (targetDoseIU / b['volume'])).abs();
        return aDiff < bDiff ? a : b;
      });
    }

    return {
      'suggestions': suggestions.take(4).toList(),
      'selectedReconstitution': selectedReconstitution,
      'totalAmount': quantityIU,
      'targetDose': targetDoseIU,
      'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
    };
  }
}