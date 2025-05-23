import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;

  const MedicationCard({super.key, required this.medication, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(medication.name),
        subtitle: Text(
          'Type: ${medication.type}\n'
              'Storage: ${medication.storageType}\n'
              'Stock: ${medication.stockQuantity.toStringAsFixed(2)} ${medication.stockUnit}\n'
              'Concentration: ${medication.concentration.toStringAsFixed(2)} ${medication.stockUnit}/${medication.reconstitutionVolumeUnit}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: onEdit,
        ),
      ),
    );
  }
}