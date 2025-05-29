// lib/core/widgets/confirm_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class ConfirmScheduleDialog extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDark;

  const ConfirmScheduleDialog({
    super.key,
    required this.schedule,
    required this.onConfirm,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.cardColor(isDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        decoration: AppThemes.dialogCardDecoration(isDark),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirm Schedule',
              style: AppThemes.dialogTitleStyle(isDark),
            ),
            const SizedBox(height: 12),
            Icon(
              Icons.schedule,
              size: 36,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Dosage: '),
                  TextSpan(
                    text: schedule.dosageName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Time: '),
                  TextSpan(
                    text: schedule.time.format(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Frequency: '),
                  TextSpan(
                    text: schedule.frequencyType.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Verify schedule details before saving.',
              style: AppThemes.dialogContentStyle(isDark).copyWith(color: AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: AppConstants.accentColor(isDark), fontFamily: 'Inter'),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: onConfirm,
                  style: AppConstants.dialogButtonStyle(),
                  child: const Text('Confirm', style: TextStyle(fontFamily: 'Inter')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}