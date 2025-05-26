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

  ({List<Map<String, dynamic>> suggestions, Map<String, dynamic>? selectedReconstitution, double totalAmount, double targetDose, String medicationName}) calculate() {
    final totalAmount = int.tryParse(quantityController.text) ?? 0;
    final targetDose = int.tryParse(targetDoseController.text) ?? 0;

    if (totalAmount <= 0 || targetDose <= 0 || quantityController.text.isEmpty || targetDoseController.text.isEmpty) {
      return (
      suggestions: [],
      selectedReconstitution: null,
      totalAmount: 0,
      targetDose: 0,
      medicationName: medicationName.isNotEmpty ? medicationName : 'Medication'
      );
    }

    final totalMcg = quantityUnit == 'mg' ? totalAmount * 1000.0 : totalAmount.toDouble();
    final targetMcg = targetDoseUnit == 'mg' ? targetDose * 1000.0 : targetDose.toDouble();

    final suggestions = <Map<String, dynamic>>[];
    const volumes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    for (final volume in volumes) {
      final concentration = totalMcg / volume;
      final iuPerDose = (targetMcg / concentration) * 100;
      if (iuPerDose >= 10 && iuPerDose <= 100 && iuPerDose.isFinite) {
        suggestions.add({
          'volume': volume,
          'iu': iuPerDose.round(),
          'concentration': concentration.round(),
        });
      }
    }

    return (
    suggestions: suggestions,
    selectedReconstitution: suggestions.isNotEmpty ? suggestions.first : null,
    totalAmount: totalMcg / 1000.0,
    targetDose: targetMcg,
    medicationName: medicationName.isNotEmpty ? medicationName : 'Medication',
    );
  }
}