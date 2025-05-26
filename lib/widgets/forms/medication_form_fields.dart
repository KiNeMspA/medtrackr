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
  final TextEditingController notesController;

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
    required this.notesController,
  });

  @override
  Widget build(BuildContext context) {
    final medicationTypes = ['Tablet', 'Capsule', 'Injection', 'Other'];
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
        DropdownButtonFormField<String>(
          value: medicationTypes.contains(type) ? type : medicationTypes.first,
          decoration: InputDecoration(
            labelText: 'Medication Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: medicationTypes
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