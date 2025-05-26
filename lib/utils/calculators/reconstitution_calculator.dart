import 'package:flutter/material.dart';
import 'package:medtrackr/utils/helpers/logger.dart';

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
    try {
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
          Logger.logError('Unknown unit: $unit, defaulting to mg');
          return value; // Default to mg
      }
    } catch (e, stackTrace) {
      Logger.logError('Unit conversion failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Map<String, dynamic> calculate() {
    try {
      final p = double.tryParse(quantityController.text) ?? 0.0; // Peptide Quantity
      final d = double.tryParse(targetDoseController.text) ?? 0.0; // Desired Dosage
      final pMg = _convertToMg(quantityUnit, p); // Convert to mg
      final dMg = _convertToMg(targetDoseUnit, d); // Convert to mg
      final S = syringeSize; // Syringe Size (mL)
      const step = 0.1; // Volume increment (mL)

      // Validate inputs
      if (pMg <= 0 || dMg <= 0 || S <= 0) {
        Logger.logError('Invalid input: pMg=$pMg, dMg=$dMg, S=$S');
        return {
          'suggestions': [],
          'selectedReconstitution': null,
          'totalAmount': pMg,
          'targetDose': dMg,
          'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
          'error': 'Please enter positive values for quantity, dose, and syringe size.',
        };
      }

      // Minimum reconstitution volume: V_min = (d * S) / p
      final V_min = (dMg * S) / pMg;
      if (V_min > S) {
        Logger.logError('Minimum volume $V_min exceeds syringe size $S');
        return {
          'suggestions': [],
          'selectedReconstitution': null,
          'totalAmount': pMg,
          'targetDose': dMg,
          'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
          'error': 'The minimum volume required exceeds the syringe size.',
        };
      }

      // Generate suggestions
      final suggestions = <Map<String, dynamic>>[];
      for (var V = (V_min / step).ceil() * step; V <= S; V += step) {
        final roundedV = (V * 100).round() / 100;
        final C = pMg / roundedV; // Concentration: C = p / V (mg/mL)
        final V_d = dMg / C; // Dose Volume: V_d = d / C (mL)
        final U = V_d * 100; // Syringe Units: U = V_d * 100 (1 mL = 100 units)

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
    } catch (e, stackTrace) {
      Logger.logError('Calculation failed', error: e, stackTrace: stackTrace);
      return {
        'suggestions': [],
        'selectedReconstitution': null,
        'totalAmount': 0.0,
        'targetDose': 0.0,
        'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
        'error': 'Calculation error: ${e.toString()}',
      };
    }
  }
}