import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MedicationFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final String type;
  final String quantityUnit;
  final TextEditingController quantityController;
  final TextEditingController notesController;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onQuantityUnitChanged;
  final ValueChanged<String?> onNameChanged;
  final VoidCallback onQuantityChanged;

  const MedicationFormFields({
    super.key,
    required this.nameController,
    required this.type,
    required this.quantityUnit,
    required this.quantityController,
    required this.notesController,
    required this.onTypeChanged,
    required this.onQuantityUnitChanged,
    required this.onNameChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Medication Name *',
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
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: type,
          decoration: InputDecoration(
            labelText: 'Type',
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
          items: ['Injection', 'Tablet', 'Capsule', 'Other']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: notesController,
          decoration: InputDecoration(
            labelText: 'Notes',
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
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Total Medication Amount *',
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
                onChanged: (_) => onQuantityChanged(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: quantityUnit,
                decoration: InputDecoration(
                  labelText: 'Measure',
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
                items: ['mcg', 'mg', 'mL', 'IU']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: onQuantityUnitChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}