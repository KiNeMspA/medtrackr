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
            Text('Confirm Dosage', style: AppThemes.informationTitleStyle),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: AppThemes.informationContentTextStyle?.copyWith(height: 1.5),
                children: [
                  const TextSpan(text: 'Dosage: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: dosage.name),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Amount: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: isTabletOrCapsule
                          ? '${formatNumber(amount)} tablets (${formatNumber(amount)} ${dosage.doseUnit})'
                          : isReconstituted
                          ? '${formatNumber(insulinUnits)} IU'
                          : '${formatNumber(amount)} ${dosage.doseUnit}',
                      style: TextStyle(color: AppConstants.primaryColor)),
                  if (isInjection) ...[
                    const TextSpan(text: '\n'),
                    const TextSpan(text: 'Volume: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: '${formatNumber(volume)} mL',
                        style: TextStyle(color: AppConstants.primaryColor)),
                  ],
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Method: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: dosage.method.displayName),
                  const TextSpan(text: '\n'),
                  const TextSpan(text: 'Medication: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: medication.name),
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
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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