import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage_method.dart';

class DosageFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController doseController;
  final TextEditingController? volumeController;
  final TextEditingController insulinUnitsController;
  final String doseUnit;
  final List<String> doseUnits;
  final DosageMethod method;
  final ValueChanged<String?> onDoseUnitChanged;
  final ValueChanged<DosageMethod?> onMethodChanged;

  const DosageFormFields({
    super.key,
    required this.nameController,
    required this.doseController,
    this.volumeController,
    required this.insulinUnitsController,
    required this.doseUnit,
    required this.doseUnits,
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: doseController,
          decoration: InputDecoration(
            labelText: 'Dose',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
            suffixText: doseUnit,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: doseUnits.contains(doseUnit) ? doseUnit : doseUnits.first,
          decoration: InputDecoration(
            labelText: 'Dose Unit',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: doseUnits.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
          onChanged: onDoseUnitChanged,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: insulinUnitsController,
          decoration: InputDecoration(
            labelText: 'Insulin Units (IU/CC)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<DosageMethod>(
          value: method,
          decoration: InputDecoration(
            labelText: 'Method',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ),
          items: DosageMethod.values
              .map((m) => DropdownMenuItem(
            value: m,
            child: Text(m == DosageMethod.subcutaneous ? 'Subcutaneous Injection' : m.toString().split('.').last),
          ))
              .toList(),
          onChanged: onMethodChanged,
        ),
      ],
    );
  }
}