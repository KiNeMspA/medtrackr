import 'package:flutter/material.dart';

class ReconstitutionCalculator {
  final TextEditingController quantityController; // Peptide Quantity (p, mg)
  final TextEditingController targetDoseController; // Desired Dosage (d, mg or mcg)
  final String quantityUnit; // mg, mcg, etc.
  final String targetDoseUnit; // mg or mcg
  final String medicationName;
  final double syringeSize; // Syringe Size (S, mL)

  ReconstitutionCalculator({
    required this.quantityController,
    required this.targetDoseController,
    required this.quantityUnit,
    required this.targetDoseUnit,
    required this.medicationName,
    required this.syringeSize,
  });

  double _convertToMg(String unit, double value) {
    switch (unit.toLowerCase()) {
      case 'g':
        return value * 1000; // g to mg
      case 'mg':
        return value; // No conversion
      case 'mcg':
        return value / 1000; // mcg to mg
      case 'iu':
      case 'unit':
        return value / 1000; // Assume 1 IU = 1 mcg
      default:
        return value; // Default to mg
    }
  }

  Map<String, dynamic> calculate() {
    final p = double.tryParse(quantityController.text) ?? 0.0; // Peptide Quantity
    final d = double.tryParse(targetDoseController.text) ?? 0.0; // Desired Dosage
    final pMg = _convertToMg(quantityUnit, p); // Convert to mg
    final dMg = _convertToMg(targetDoseUnit, d); // Convert to mg
    final S = syringeSize; // Syringe Size (mL)
    const step = 0.1; // Volume increment (mL)

    // Validate inputs
    if (pMg <= 0 || dMg <= 0 || S <= 0) {
      return {
        'suggestions': [],
        'selectedReconstitution': null,
        'totalAmount': pMg,
        'targetDose': dMg,
        'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
        'error': 'Invalid input: Quantity, dose, or syringe size must be positive.',
      };
    }

    // Minimum reconstitution volume: V_min = (d * S) / p
    final V_min = (dMg * S) / pMg;
    if (V_min > S) {
      return {
        'suggestions': [],
        'selectedReconstitution': null,
        'totalAmount': pMg,
        'targetDose': dMg,
        'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
        'error': 'No feasible volumes: Minimum volume exceeds syringe size.',
      };
    }

    // Generate suggestions
    final suggestions = <Map<String, dynamic>>[];
    for (var V = (V_min / step).ceil() * step; V <= S; V += step) {
      // Round V to 2 decimal places
      final roundedV = (V * 100).round() / 100;
      // Concentration: C = p / V (mg/mL)
      final C = pMg / roundedV;
      // Dose Volume: V_d = d / C (mL)
      final V_d = dMg / C;
      // Syringe Units: U = V_d * 100 (1 mL = 100 units)
      final U = V_d * 100;

      if (V_d <= S) {
        suggestions.add({
          'volume': roundedV,
          'concentration': C,
          'doseVolume': V_d,
          'syringeUnits': U,
          'syringeSize': S,
        });
      }
    }

    // Select best suggestion
    Map<String, dynamic>? selectedReconstitution;
    if (suggestions.isNotEmpty) {
      selectedReconstitution = suggestions.reduce((a, b) {
        final aDiff = (a['doseVolume'] - dMg / (pMg / a['volume'])).abs();
        final bDiff = (b['doseVolume'] - dMg / (pMg / b['volume'])).abs();
        return aDiff < bDiff ? a : b;
      });
    }

    return {
      'suggestions': suggestions.take(4).toList(),
      'selectedReconstitution': selectedReconstitution,
      'totalAmount': pMg,
      'targetDose': dMg,
      'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
      'error': null,
    };
  }
}