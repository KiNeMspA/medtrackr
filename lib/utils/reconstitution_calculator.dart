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

    if (totalAmount <= 0 || targetDose <= 0) {
      return (
      suggestions: [],
      selectedReconstitution: null,
      totalAmount: 0,
      targetDose: 0,
      medicationName: medicationName.isNotEmpty ? medicationName : 'Medication'
      );
    }

    final totalMcg = quantityUnit == 'mg' ? totalAmount * 1000 : totalAmount;
    final targetMcg = targetDoseUnit == 'mg' ? targetDose * 1000 : targetDose;

    final suggestions = <Map<String, dynamic>>[];
    const volumes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    for (final volume in volumes) {
      final concentration = totalMcg / volume;
      final iuPerDose = (targetMcg / concentration) * 100;
      if (iuPerDose >= 10 && iuPerDose <= 100) {
        suggestions.add({
          'volume': volume,
          'iu': iuPerDose.round(),
          'concentration': concentration.round(),
        });
      }
    }

    return (
    suggestions: suggestions,
    selectedReconstitution: suggestions.isNotEmpty ? suggestions.firstWhere(
          (s) => s['volume'] == (selectedReconstitution?['volume']),
      orElse: () => suggestions.first,
    ) : null,
    totalAmount: quantityUnit == 'mg' ? totalAmount.toDouble() : (totalMcg / 1000).toDouble(),
    targetDose: targetMcg.toDouble(),
    medicationName: medicationName.isNotEmpty ? medicationName : 'Medication',
    );
  }
}