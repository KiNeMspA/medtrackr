// lib/core/widgets/dialogs/dialog_actions.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class DialogActions extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmText;
  final String cancelText;

  const DialogActions({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            cancelText,
            style: TextStyle(
              color: AppConstants.accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: onConfirm,
          style: AppConstants.dialogButtonStyle,
          child: Text(confirmText),
        ),
      ],
    );
  }
}