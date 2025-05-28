// lib/core/widgets/confirm_schedule_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class ConfirmScheduleDialog extends StatelessWidget {
  final Schedule schedule;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmScheduleDialog({
    super.key,
    required this.schedule,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: EdgeInsets.zero,
      content: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: AppThemes.informationCardDecoration,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confirm Schedule', style: AppThemes.informationTitleStyle),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: AppThemes.informationContentTextStyle?.copyWith(height: 1.5),
                children: [
                  const TextSpan(text: 'Dosage: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: schedule.dosageName),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Amount: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '${schedule.dosageAmount} ${schedule.dosageUnit}'),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Time: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: schedule.time.format(context)),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Frequency: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: schedule.frequencyType.displayName),
                ],
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: onConfirm,
          style: AppConstants.dialogButtonStyle,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}