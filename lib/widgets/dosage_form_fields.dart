import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage.dart';

class DosageFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController doseController;
  final String doseUnit;
  final DosageMethod method;
  final ValueChanged<String?> onDoseUnitChanged;
  final ValueChanged<DosageMethod?> onMethodChanged;

  const DosageFormFields({
    super.key,
    required this.nameController,
    required this.doseController,
    required this.doseUnit,
    required this.method,
    required this.onDoseUnitChanged,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Dosage Name *',
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: doseController,
                decoration: InputDecoration(
                  labelText: 'Dose Amount *',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: doseUnit,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: ['IU', 'mcg', 'mg', 'mL']
                    .map((unit) =>
                        DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: onDoseUnitChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<DosageMethod>(
          value: method,
          decoration: InputDecoration(
            labelText: 'Method',
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
          items: DosageMethod.values
              .map((method) => DropdownMenuItem(
                    value: method,
                    child: Text(method.toString().split('.').last),
                  ))
              .toList(),
          onChanged: onMethodChanged,
        ),
      ],
    );
  }
}
