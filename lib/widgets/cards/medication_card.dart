import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppConstants.cardDecoration,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.name,
            style: AppConstants.cardTitleStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Type: ${medication.type.displayName}',
            style: AppConstants.cardBodyStyle,
          ),
          Text(
            'Quantity: ${medication.quantity.toStringAsFixed(2)} ${medication.quantityUnit.displayName}',
            style: AppConstants.cardBodyStyle,
          ),
          Text(
            'Remaining: ${medication.remainingQuantity.toStringAsFixed(2)} ${medication.quantityUnit.displayName}',
            style: AppConstants.cardBodyStyle,
          ),
          if (medication.reconstitutionVolume > 0)
            Text(
              'Reconstitution: ${medication.reconstitutionVolume.toStringAsFixed(2)} mL '
                  '${medication.reconstitutionFluid}, '
                  '${medication.selectedReconstitution?['concentration']?.toStringAsFixed(2)} mg/mL',
              style: AppConstants.cardBodyStyle,
            ),
          Text(
            'Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
            style: AppConstants.cardBodyStyle,
          ),
        ],
      ),
    );
  }
}