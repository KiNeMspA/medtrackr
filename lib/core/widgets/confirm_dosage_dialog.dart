// lib/core/widgets/confirm_dosage_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';

class ConfirmDosageDialog extends StatelessWidget {
  final Dosage dosage;
  final bool isTabletOrCapsule;
  final bool isInjection;
  final bool isReconstituted;
  final Medication medication;
  final double insulinUnits;
  final double amount;
  final double volume;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isDark;

  const ConfirmDosageDialog({
    super.key,
    required this.dosage,
    required this.isTabletOrCapsule,
    required this.isInjection,
    required this.isReconstituted,
    required this.medication,
    required this.insulinUnits,
    required this.amount,
    required this.volume,
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
              'Confirm Dosage',
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
                  const TextSpan(text: 'Dosage: '),
                  TextSpan(
                    text: dosage.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: AppThemes.dialogContentStyle(isDark),
                children: [
                  const TextSpan(text: 'Method: '),
                  TextSpan(
                    text: dosage.method.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (isTabletOrCapsule) ...[
              RichText(
                text: TextSpan(
                  style: AppThemes.dialogContentStyle(isDark),
                  children: [
                    const TextSpan(text: 'Tablets: '),
                    TextSpan(
                      text: formatNumber(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            if (isInjection && isReconstituted) ...[
              RichText(
                text: TextSpan(
                  style: AppThemes.dialogContentStyle(isDark),
                  children: [
                    const TextSpan(text: 'IU: '),
                    TextSpan(
                      text: formatNumber(insulinUnits),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' ('),
                    TextSpan(
                      text: formatNumber(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' mg)'),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  style: AppThemes.dialogContentStyle(isDark),
                  children: [
                    const TextSpan(text: 'Volume: '),
                    TextSpan(
                      text: formatNumber(volume),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' mL'),
                  ],
                ),
              ),
            ],
            if (isInjection && !isReconstituted) ...[
              RichText(
                text: TextSpan(
                  style: AppThemes.dialogContentStyle(isDark),
                  children: [
                    const TextSpan(text: 'Volume: '),
                    TextSpan(
                      text: formatNumber(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' mL'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Verify dosage details before saving.',
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