import 'package:flutter/material.dart';

class MedicationFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final String quantityUnit;
  final String type; // Read-only type
  final TextEditingController notesController;
  final VoidCallback onQuantityChanged;
  final ValueChanged<String?> onNameChanged;
  final ValueChanged<String?> onQuantityUnitChanged;

  const MedicationFormFields({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.quantityUnit,
    required this.type,
    required this.notesController,
    required this.onQuantityChanged,
    required this.onNameChanged,
    required this.onQuantityUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final quantityUnits = {
      'Tablet': ['g', 'mg', 'mcg'],
      'Capsule': ['g', 'mg', 'mcg'],
      'Injection': ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit'],
      'Other': ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit'],
    }[type] ?? ['g', 'mg', 'mcg'];

    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Medication Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: type == 'Tablet' || type == 'Capsule' ? 'Total Units' : 'Quantity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => onQuantityChanged(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: quantityUnits.contains(quantityUnit) ? quantityUnit : quantityUnits.first,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: quantityUnits
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: onQuantityUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}