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
        return value / 1000; // Assume 1 IU = 1 mcg for simplicity
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

    // Minimum reconstitution volume: V_min = (d * S) / p
    final V_min = (dMg * S) / pMg;

    // Initialize suggestions
    final suggestions = <Map<String, dynamic>>[];
    if (pMg <= 0 || dMg <= 0 || S <= 0 || V_min > S) {
      return {
        'suggestions': suggestions,
        'selectedReconstitution': null,
        'totalAmount': pMg,
        'targetDose': dMg,
        'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
        'error': V_min > S ? 'No feasible volumes: minimum volume exceeds syringe size.' : 'Invalid input values.',
      };
    }

    // Iterate feasible volumes from V_min to S
    for (var V = (V_min / step).ceil() * step; V <= S; V += step) {
      // Concentration: C = p / V (mg/mL)
      final C = pMg / V;
      // Dose Volume: V_d = d / C (mL)
      final V_d = dMg / C;
      // Syringe Units: U = V_d * 100 (assuming 1 mL = 100 units)
      final U = V_d * 100;

      if (V_d <= S) {
        suggestions.add({
          'volume': V,
          'concentration': C,
          'doseVolume': V_d,
          'syringeUnits': U,
        });
      }
    }

    // Select suggestion closest to target dose
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