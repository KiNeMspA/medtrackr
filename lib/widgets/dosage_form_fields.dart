import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage_method.dart';

class DosageFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController doseController;
  final TextEditingController volumeController;
  final TextEditingController insulinUnitsController;
  final String doseUnit;
  final List<String> doseUnits; // Add this
  final DosageMethod method;
  final ValueChanged<String?> onDoseUnitChanged;
  final ValueChanged<DosageMethod?> onMethodChanged;

  const DosageFormFields({
    super.key,
    required this.nameController,
    required this.doseController,
    required this.volumeController,
    required this.insulinUnitsController,
    required this.doseUnit,
    required this.doseUnits, // Add this
    required this.method,
    required this.onDoseUnitChanged,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Dosage Name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: doseController,
          decoration: InputDecoration(
            labelText: 'Dose',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: doseUnits.contains(doseUnit) ? doseUnit : doseUnits.first, // Use doseUnits
          decoration: InputDecoration(
            labelText: 'Dose Unit',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: doseUnits
              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
              .toList(),
          onChanged: onDoseUnitChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: volumeController,
          decoration: InputDecoration(
            labelText: 'Volume (mL)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: insulinUnitsController,
          decoration: InputDecoration(
            labelText: 'Insulin Units (IU)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<DosageMethod>(
          value: method,
          decoration: InputDecoration(
            labelText: 'Method',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: DosageMethod.values
              .map((m) => DropdownMenuItem(
            value: m,
            child: Text(m.toString().split('.').last),
          ))
              .toList(),
          onChanged: onMethodChanged,
        ),
      ],
    );
  }
}