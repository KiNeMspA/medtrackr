// In lib/core/widgets/dialogs/confirm_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart'; // Ensure this import is present
import 'package:medtrackr/core/widgets/dialogs/dialog_actions.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDark;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.cardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: AppThemes.dialogCardDecoration(isDark), // Restored
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppThemes.dialogTitleStyle(isDark)), // Restored
            const SizedBox(height: 12),
            content,
            const SizedBox(height: 16),
            DialogActions(
              onConfirm: onConfirm,
              onCancel: onCancel,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}