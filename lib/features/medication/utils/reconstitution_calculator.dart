// In lib/core/utils/reconstitution_calculator.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
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
          'targetDose': d,
          'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
          'error': 'Please enter positive values for quantity, dose, and syringe size.',
        };
      }

      final suggestions = <Map<String, dynamic>>[];
      Map<String, dynamic>? selectedReconstitution;

      if (fixedVolume != null && fixedVolume! > 0) {
        final V = fixedVolume! * fixedVolumeUnit.toMLFactor;
        if (V > 99) {
          return {
            'suggestions': [],
            'selectedReconstitution': null,
            'totalAmount': pMg,
            'targetDose': d,
            'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
            'error': 'Fluid volume cannot exceed 99 mL.',
          };
        }
        final C = pMg / V;
        final vD = dMg / C;
        final U = vD * 100;
        final maxIU = S == 0.3 ? 30.0 : S == 0.5 ? 50.0 : S == 1.0 ? 100.0 : 300.0;
        final minIU = maxIU * 0.05; // 5% of syringe capacity

        if (vD <= S && U <= maxIU && U >= minIU) {
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
            'doseVolume': vD,
            'syringeUnits': U,
            'syringeSize': S,
            'targetDose': d,
            'targetDoseUnit': targetDoseUnit,
          });
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
            'targetDose': d,
            'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
            'error': U > maxIU
                ? 'IU (${formatNumber(U)}) exceeds syringe capacity (${formatNumber(maxIU)} IU).'
                : U < minIU
                ? 'IU (${formatNumber(U)}) below minimum (${formatNumber(minIU)} IU).'
                : 'Dose volume exceeds syringe capacity.',
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
            'targetDose': d,
            'medicationName': medicationName.isNotEmpty ? medicationName : 'Medication',
            'error': 'The minimum volume required exceeds the syringe size.',
          };
        }

        for (var V = (vMin / step).ceil() * step; V <= 99; V += step) {
          final roundedV = (V * 100).round() / 100;
          final C = pMg / roundedV;
          final vD = dMg / C;
          final U = vD * 100;
          final maxIU = S == 0.3 ? 30.0 : S == 0.5 ? 50.0 : S == 1.0 ? 100.0 : 300.0;
          final minIU = maxIU * 0.05;

          if (vD <= S && U <= maxIU && U >= minIU) {
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

      return {
        'suggestions': suggestions.take(4).toList(),
        'selectedReconstitution': selectedReconstitution,
        'totalAmount': pMg,
        'targetDose': d,
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