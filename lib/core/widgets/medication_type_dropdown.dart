// lib/core/widgets/medication_type_dropdown.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';

class MedicationTypeDropdown extends StatelessWidget {
  final MedicationType? value;
  final ValueChanged<MedicationType?> onChanged;
  final FormFieldValidator<MedicationType>? validator;
  final bool isDark;

  const MedicationTypeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.validator,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MedicationType>(
      value: value,
      decoration: AppConstants.formFieldDecoration(isDark).copyWith(
        labelText: 'Medication Type',
        labelStyle: AppThemes.formLabelStyle(isDark),
      ),
      items: MedicationType.values
          .map((type) => DropdownMenuItem(
        value: type,
        child: Text(type.displayName, style: const TextStyle(fontFamily: 'Inter')),
      ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}