import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Type: ${medication.type}'),
            Text('Quantity: ${medication.quantity.toStringAsFixed(2)} ${medication.quantityUnit}'),
            Text('Remaining: ${medication.remainingQuantity.toStringAsFixed(2)} ${medication.quantityUnit}'),
            if (medication.reconstitutionVolume > 0)
              Text(
                'Reconstitution: ${medication.reconstitutionVolume.toStringAsFixed(2)} mL '
                    '${medication.reconstitutionFluid}, '
                    '${medication.selectedReconstitution?['concentration']?.toStringAsFixed(2)} mg/mL',
              ),
            Text('Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}'),
          ],
        ),
      ),
    );
  }
}