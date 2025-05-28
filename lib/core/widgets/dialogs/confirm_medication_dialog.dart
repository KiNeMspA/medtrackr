// In lib/core/widgets/dialogs/confirm_medication_dialog.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/core/utils/format_helper.dart';

class ConfirmMedicationDialog extends StatelessWidget {
  final Medication medication;
  final bool isTabletOrCapsule;
  final MedicationType? type;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmMedicationDialog({
    super.key,
    required this.medication,
    required this.isTabletOrCapsule,
    required this.type,
    required this.onConfirm,
    required this.onCancel,
  });

  String _formatNumber(double value) => formatNumber(value);

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
            Text('Confirm Medication', style: AppThemes.informationTitleStyle),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Colors.black, fontSize: 14, height: 1.6),
                children: [
                  const TextSpan(
                    text: 'Name: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: medication.name),
                  const TextSpan(
                    text: '\nType: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: medication.type.displayName),
                  const TextSpan(
                    text: '\nQuantity: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text:
                          '${_formatNumber(medication.quantity)} ${medication.quantityUnit.displayName}'),
                  if (isTabletOrCapsule &&
                      medication.dosePerTablet != null &&
                      type == MedicationType.tablet)
                    TextSpan(
                      text: '\nDose per Tablet: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text:
                                '${_formatNumber(medication.dosePerTablet!)} ${medication.dosePerTabletUnit?.displayName ?? "mg"}'),
                      ],
                    ),
                  if (isTabletOrCapsule &&
                      medication.dosePerCapsule != null &&
                      type == MedicationType.capsule)
                    TextSpan(
                      text: '\nDose per Capsule: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text:
                                '${_formatNumber(medication.dosePerCapsule!)} ${medication.dosePerCapsuleUnit?.displayName ?? "mg"}'),
                      ],
                    ),
                  const TextSpan(
                    text: '\nNotes: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: medication.notes.isNotEmpty
                          ? medication.notes
                          : 'None'),
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
          child: const Text(
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
