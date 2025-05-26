import 'package:flutter/material.dart';

class MedicationFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final String quantityUnit;
  final String type;
  final VoidCallback onQuantityChanged;
  final ValueChanged<String?> onNameChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onQuantityUnitChanged;
  final TextEditingController notesController; // Add notes

  const MedicationFormFields({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.quantityUnit,
    required this.type,
    required this.onQuantityChanged,
    required this.onNameChanged,
    required this.onTypeChanged,
    required this.onQuantityUnitChanged,
    required this.notesController, // Add notes
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Medication Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: type.isNotEmpty ? type : null,
          decoration: InputDecoration(
            labelText: 'Medication Type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: ['Tablet', 'Injection', 'Liquid', 'Capsule', 'Other']
              .map((t) => DropdownMenuItem(value: t, child: Text(t)))
              .toList(),
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => onQuantityChanged(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: quantityUnit.isNotEmpty ? quantityUnit : 'mcg',
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['mcg', 'mg', 'mL']
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}