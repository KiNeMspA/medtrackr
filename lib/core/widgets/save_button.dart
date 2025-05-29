// lib/core/widgets/save_button.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class SaveButton extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onPressed;

  const SaveButton({
    super.key,
    required this.isSaving,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: AppConstants.actionButtonStyle(),
        child: isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Medication', style: TextStyle(fontFamily: 'Inter')),
      ),
    );
  }
}