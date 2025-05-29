// lib/core/widgets/notes_field.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';

class NotesField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const NotesField({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: AppConstants.formFieldDecoration(isDark).copyWith(
        labelText: 'Notes (Optional)',
        labelStyle: AppThemes.formLabelStyle(isDark),
      ),
      maxLines: 3,
    );
  }
}