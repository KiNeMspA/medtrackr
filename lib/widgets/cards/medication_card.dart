import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  String _formatNumber(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: double.infinity),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppConstants.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.8),
              children: [
                const TextSpan(
                  text: 'Type: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '${medication.type}\n'),
                const TextSpan(
                  text: 'Total: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: _formatNumber(medication.quantity),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${medication.quantityUnit}\n'),
                const TextSpan(
                  text: 'Remaining: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: _formatNumber(medication.remainingQuantity ?? medication.quantity),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${medication.quantityUnit}'),
                if (medication.reconstitutionVolume != null && medication.reconstitutionVolume! > 0) ...[
                  const TextSpan(text: '\nReconstituted with: '),
                  TextSpan(
                    text: _formatNumber(medication.reconstitutionVolume!),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' mL'),
                  if (medication.reconstitutionFluid != null && medication.reconstitutionFluid!.isNotEmpty)
                    TextSpan(text: ' of ${medication.reconstitutionFluid}'),
                  if (medication.selectedReconstitution != null &&
                      medication.selectedReconstitution!['concentration'] != null) ...[
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: _formatNumber(medication.selectedReconstitution!['concentration']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' mg/mL'),
                  ],
                ],
                const TextSpan(text: '\nNotes: '),
                TextSpan(
                  text: medication.notes.isNotEmpty ? medication.notes : 'None',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}