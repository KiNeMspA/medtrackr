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
            TextFormField(
              controller: targetDoseController,
              decoration: InputDecoration(
                labelText: 'Target Dose',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixText: targetDoseUnit,
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => onTargetDoseChanged(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: targetDoseUnit,
              decoration: InputDecoration(
                labelText: 'Target Dose Unit',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit']
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: onTargetDoseUnitChanged,
            ),
            const SizedBox(height: 16),
            if (reconstitutionSuggestions.isNotEmpty) ...[
              const Text(
                'Suggested Reconstitutions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              ...reconstitutionSuggestions.map((suggestion) {
                final isSelected = suggestion == selectedReconstitution;
                return ListTile(
                  title: Text(
                    'Reconstitute with ${suggestion['volume']} mL for ${suggestion['iu']} IU',
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFFC107) : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                        onPressed: () => onEditReconstitution(suggestion),
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
                  )
                      : null,
                  onTap: () => onSuggestionSelected(suggestion),
                );
              }),
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

class ReconstitutionEditDialog extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final String fluid;

  const ReconstitutionEditDialog({super.key, required this.suggestion, required this.fluid});

  @override
  Widget build(BuildContext context) {
    final volumeController = TextEditingController(text: suggestion['volume'].toString());
    final iuController = TextEditingController(text: suggestion['iu'].toString());
    final fluidController = TextEditingController(text: fluid);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Edit Reconstitution',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: volumeController,
            decoration: InputDecoration(
              labelText: 'Volume (mL)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: iuController,
            decoration: InputDecoration(
              labelText: 'IU',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: fluidController,
            decoration: InputDecoration(
              labelText: 'Fluid',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFFFC107)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'volume': double.tryParse(volumeController.text) ?? suggestion['volume'],
              'iu': double.tryParse(iuController.text) ?? suggestion['iu'],
              'fluid': fluidController.text,
            });
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}