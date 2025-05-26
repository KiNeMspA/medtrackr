import 'package:flutter/material.dart';

class ReconstitutionWidgets extends StatelessWidget {
  final bool isReconstituting;
  final TextEditingController reconstitutionFluidController;
  final TextEditingController targetDoseController;
  final String targetDoseUnit;
  final List<Map<String, dynamic>> reconstitutionSuggestions;
  final Map<String, dynamic>? selectedReconstitution;
  final double totalAmount;
  final double targetDose;
  final String medicationName;
  final String quantityUnit;
  final String? reconstitutionError;
  final ValueChanged<bool> onReconstitutingChanged;
  final VoidCallback onFluidChanged;
  final VoidCallback onTargetDoseChanged;
  final ValueChanged<String?> onTargetDoseUnitChanged;
  final ValueChanged<Map<String, dynamic>> onSuggestionSelected;
  final ValueChanged<Map<String, dynamic>> onEditReconstitution;
  final VoidCallback onClearReconstitution;
  final ValueChanged<double> onAdjustVolume;

  const ReconstitutionWidgets({
    super.key,
    required this.isReconstituting,
    required this.reconstitutionFluidController,
    required this.targetDoseController,
    required this.targetDoseUnit,
    required this.reconstitutionSuggestions,
    required this.selectedReconstitution,
    required this.totalAmount,
    required this.targetDose,
    required this.medicationName,
    required this.quantityUnit,
    this.reconstitutionError,
    required this.onReconstitutingChanged,
    required this.onFluidChanged,
    required this.onTargetDoseChanged,
    required this.onTargetDoseUnitChanged,
    required this.onSuggestionSelected,
    required this.onEditReconstitution,
    required this.onClearReconstitution,
    required this.onAdjustVolume,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reconstitution Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reconstitutionFluidController,
              decoration: InputDecoration(
                labelText: 'Reconstitution Fluid',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => onFluidChanged(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: targetDoseController,
                    decoration: InputDecoration(
                      labelText: 'Target Dose',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => onTargetDoseChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    value: targetDoseUnit,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit']
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: onTargetDoseUnitChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<double>(
              value: selectedReconstitution?['syringeSize'] ?? 0.3,
              decoration: InputDecoration(
                labelText: 'Syringe Size',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: [0.3, 0.5, 1.0, 3.0, 5.0]
                  .map((size) => DropdownMenuItem(value: size, child: Text('$size mL')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  onEditReconstitution({'syringeSize': value});
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Medication Quantity: $totalAmount $quantityUnit',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (reconstitutionSuggestions.isNotEmpty && selectedReconstitution == null) ...[
              const Text(
                'Suggested Reconstitutions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              ...reconstitutionSuggestions.take(4).map((suggestion) {
                return ListTile(
                  title: Text(
                    'Reconstitute with ${suggestion['volume']} mL for ${suggestion['iu']} IU',
                    style: const TextStyle(color: Colors.black),
                  ),
                  onTap: () => onSuggestionSelected(suggestion),
                );
              }),
            ],
            if (selectedReconstitution != null) ...[
              const Text(
                'Selected Reconstitution',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  'Reconstituted with ${selectedReconstitution!['volume']} mL for ${selectedReconstitution!['iu']} IU',
                  style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                      onPressed: () => onEditReconstitution(selectedReconstitution!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFFFFC107)),
                      onPressed: () => onAdjustVolume(0.1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Color(0xFFFFC107)),
                      onPressed: () => onAdjustVolume(-0.1),
                    ),
                  ],
                ),
              ),
            ],
            if (reconstitutionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  reconstitutionError!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            const SizedBox(height: 16),
            if (selectedReconstitution != null)
              ElevatedButton(
                onPressed: onClearReconstitution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Clear Reconstitution', style: TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }
}