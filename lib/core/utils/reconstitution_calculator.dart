// In lib/core/utils/reconstitution_calculator.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/core/utils/logger.dart';
import 'package:medtrackr/app/enums.dart';

class ReconstitutionCalculator {
  final TextEditingController quantityController;
  final TextEditingController targetDoseController;
  final String quantityUnit;
  final String targetDoseUnit;
  final String medicationName;
  final double syringeSize;
  final double? fixedVolume;
  final FluidUnit fixedVolumeUnit;

  ReconstitutionCalculator({
    required this.quantityController,
    required this.targetDoseController,
    required this.quantityUnit,
    required this.targetDoseUnit,
    required this.medicationName,
    required this.syringeSize,
    this.fixedVolume,
    this.fixedVolumeUnit = FluidUnit.mL,
  });

  String _formatNumber(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

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
      final p = double.tryParse(quantityController.text) ?? 0.0;
      final d = double.tryParse(targetDoseController.text) ?? 0.0;
      final pMg = _convertToMg(quantityUnit, p);
      final dMg = _convertToMg(targetDoseUnit, d);
      final S = syringeSize;
      const step = 0.1;

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

      final suggestions = <Map<String, dynamic>>[];
      Map<String, dynamic>? selectedReconstitution;

      if (fixedVolume != null && fixedVolume! > 0) {
        final V = fixedVolume! * fixedVolumeUnit.toMLFactor;
        final C = pMg / V;
        final vD = dMg / C;
        final U = vD * 100;
        final maxIU = S == 0.3 ? 30 : S == 0.5 ? 50 : S == 1.0 ? 100 : 300;

        if (vD <= S && U <= maxIU) {
          selectedReconstitution = {
            'volume': V,
            'concentration': C,
            'doseVolume': vD,
            'syringeUnits': U,
            'syringeSize': S,
            'targetDose': d,
            'targetDoseUnit': targetDoseUnit,
          };
          suggestions.add(selectedReconstitution);
          suggestions.add({
            'volume': V,
            'concentration': C,
            'doseVolume': vD * 0.5,
            'syringeUnits': U * 0.5,
            'syringeSize': S,
            'targetDose': d * 0.5,
            'targetDoseUnit': targetDoseUnit,
          });
          suggestions.add({
            'volume': V,
            'concentration': C,
            'doseVolume': vD * 1.5,
            'syringeUnits': U * 1.5,
            'syringeSize': S,
            'targetDose': d * 1.5,
            'targetDoseUnit': targetDoseUnit,
          });
        } else {
          return {
            'suggestions': [],
            'selectedReconstitution': null,
            'totalAmount': pMg,
            'targetDose': dMg,
            'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
            'error': 'Dose volume or IU (${_formatNumber(U)}) exceeds syringe capacity (${_formatNumber(maxIU.toDouble())} IU).',
          };
        }
      } else {
        final vMin = (dMg * S) / pMg;
        if (vMin > S) {
          Logger.logError('Minimum volume $vMin exceeds syringe size $S');
          return {
            'suggestions': [],
            'selectedReconstitution': null,
            'totalAmount': pMg,
            'targetDose': dMg,
            'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
            'error': 'The minimum volume required exceeds the syringe size.',
          };
        }

        for (var V = (vMin / step).ceil() * step; V <= S; V += step) {
          final roundedV = (V * 100).round() / 100;
          final C = pMg / roundedV;
          final vD = dMg / C;
          final U = vD * 100;
          final maxIU = S == 0.3 ? 30 : S == 0.5 ? 50 : S == 1.0 ? 100 : 300;

          if (vD <= S && U <= maxIU) {
            suggestions.add({
              'volume': roundedV,
              'concentration': C,
              'doseVolume': vD,
              'syringeUnits': U,
              'syringeSize': S,
              'targetDose': d,
              'targetDoseUnit': targetDoseUnit,
            });
          }
        }

        if (suggestions.isNotEmpty) {
          selectedReconstitution = suggestions.reduce((a, b) {
            final aDiff = (a['doseVolume'] - dMg / (pMg / a['volume'])).abs();
            final bDiff = (b['doseVolume'] - dMg / (pMg / b['volume'])).abs();
            return aDiff < bDiff ? a : b;
          });
        }
      }

      String? warning;
      if (selectedReconstitution != null) {
        final concentration = selectedReconstitution['concentration'] as double;
        final syringeUnits = selectedReconstitution['syringeUnits'] as double;
        final maxIU = S == 0.3 ? 30 : S == 0.5 ? 50 : S == 1.0 ? 100 : 300;
        if (syringeUnits < 5) {
          warning = 'Warning: IU (${_formatNumber(syringeUnits)}) is too low. Increase fluid amount.';
        } else if (syringeUnits > maxIU) {
          warning = 'Warning: IU (${_formatNumber(syringeUnits)}) exceeds syringe capacity (${_formatNumber(maxIU.toDouble())} IU).';
        } else if (concentration < 0.1) {
          warning = 'Warning: Concentration is ${_formatNumber(concentration)} mg/mL, too low.';
        } else if (concentration > 10) {
          warning = 'Warning: Concentration is ${_formatNumber(concentration)} mg/mL, too high.';
        }
      }

      return {
        'suggestions': suggestions.take(4).toList(),
        'selectedReconstitution': selectedReconstitution,
        'totalAmount': pMg,
        'targetDose': d,
        'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
        'error': warning,
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