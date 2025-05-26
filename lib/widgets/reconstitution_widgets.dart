import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final ValueChanged<bool> onReconstitutingChanged;
  final VoidCallback onFluidChanged;
  final VoidCallback onTargetDoseChanged;
  final ValueChanged<String?> onTargetDoseUnitChanged;
  final ValueChanged<Map<String, dynamic>> onSuggestionSelected;
  final Function(Map<String, dynamic>) onEditReconstitution;
  final VoidCallback onClearReconstitution;

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
    required this.quantityUnit, // Add this
    required this.onReconstitutingChanged,
    required this.onFluidChanged,
    required this.onTargetDoseChanged,
    required this.onTargetDoseUnitChanged,
    required this.onSuggestionSelected,
    required this.onEditReconstitution,
    required this.onClearReconstitution,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Reconstitute this medication?',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Switch(
              value: isReconstituting,
              activeColor: const Color(0xFFFFC107),
              onChanged: onReconstitutingChanged,
            ),
          ],
        ),
        if (isReconstituting) ...[
          const SizedBox(height: 16),
          TextField(
            controller: reconstitutionFluidController,
            decoration: InputDecoration(
              labelText: 'Reconstitution Fluid (e.g., Saline, Water)',
              labelStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFFFC107)),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (_) => onFluidChanged(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: targetDoseController,
                  decoration: InputDecoration(
                    labelText: 'Target Single Dosage *',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFFFC107)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => onTargetDoseChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  value: targetDoseUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    labelStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFFFC107)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: ['mcg', 'mg']
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: onTargetDoseUnitChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (reconstitutionSuggestions.isNotEmpty && selectedReconstitution == null) ...[
            const Text(
              'Reconstitution Options:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...reconstitutionSuggestions.take(4).map((suggestion) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFFC107), width: 2),
              ),
              elevation: 4,
              color: Colors.grey[50],
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Option: '),
                      TextSpan(
                        text: '${suggestion['volume']} mL',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      const TextSpan(text: ' = '),
                      TextSpan(
                        text: '${suggestion['iu']} IU',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                  softWrap: true,
                ),
                subtitle: Text(
                  'For ${totalAmount.toInt()} $quantityUnit of “$medicationName” at ${targetDose.toInt()} mcg',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFFFFC107)),
                  onPressed: () => onSuggestionSelected(suggestion),
                ),
              ),
            )),
          ],
          if (selectedReconstitution != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Selected Reconstitution:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.green[900]!, width: 2),
              ),
              elevation: 4,
              color: Colors.green[100],
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[900]),
                    children: [
                      const TextSpan(text: 'Option: '),
                      TextSpan(
                        text: '${selectedReconstitution!['volume']} mL',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' = '),
                      TextSpan(
                        text: '${selectedReconstitution!['iu']} IU',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  softWrap: true,
                ),
                subtitle: Text(
                  'For ${totalAmount.toInt()} $quantityUnit of “$medicationName” at ${targetDose.toInt()} mcg\n'
                      'Fluid: ${reconstitutionFluidController.text.isNotEmpty ? reconstitutionFluidController.text : 'None'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[900]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green[900]),
                      onPressed: () => onEditReconstitution(selectedReconstitution!),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.green[900]),
                      onPressed: onClearReconstitution,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
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
      backgroundColor: Colors.grey[50],
      title: const Text('Edit Reconstitution'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: volumeController,
              decoration: InputDecoration(
                labelText: 'Volume (mL)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: iuController,
              decoration: InputDecoration(
                labelText: 'IU per Dose',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: fluidController,
              decoration: InputDecoration(
                labelText: 'Reconstitution Fluid',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, {
              'volume': int.tryParse(volumeController.text) ?? suggestion['volume'],
              'iu': int.tryParse(iuController.text) ?? suggestion['iu'],
              'concentration': suggestion['concentration'],
              'fluid': fluidController.text,
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}