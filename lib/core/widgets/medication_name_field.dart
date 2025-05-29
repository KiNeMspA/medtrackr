// lib/core/widgets/medication_name_field.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/utils/validators.dart';

class MedicationNameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const MedicationNameField({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: AppConstants.formFieldDecoration(isDark).copyWith(
        labelText: 'Medication Name',
        labelStyle: AppThemes.formLabelStyle(isDark),
      ),
      validator: Validators.required,
    );
  }
}