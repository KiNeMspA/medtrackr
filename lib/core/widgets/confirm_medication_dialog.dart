// lib/core/widgets/confirm_medication_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/medication/models/medication.dart';

class ConfirmMedicationDialog extends StatelessWidget {
  final Medication medication;
  final bool isTabletOrCapsule;
  final MedicationType type;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDark;

  const ConfirmMedicationDialog({
    super.key,
    required this.medication,
    required this.isTabletOrCapsule,
    required this.type,
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
              'Confirm Medication',
              style: AppThemes.dialogTitleStyle(isDark),
            ),
            const SizedBox(height: 12),
            Icon(
              isTabletOrCapsule ? Icons.tablet : Icons.medical_services,
              size: 36,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Name: '),
                  TextSpan(
                    text: medication.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Type: '),
                  TextSpan(
                    text: type.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Stock: '),
                  TextSpan(
                    text: formatNumber(medication.quantity),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' ${medication.quantityUnit.displayName}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Verify medication details before saving.',
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