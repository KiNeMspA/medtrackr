import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage_schedule.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final DosageSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onDoseTaken;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.schedule,
    required this.onEdit,
    required this.onDoseTaken,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          medication.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          'Type: ${medication.type}\n'
              'Storage: ${medication.storageType}\n'
              'Quantity: ${medication.quantity.toStringAsFixed(2)} ${medication.quantityUnit}\n'
              'Remaining: ${medication.remainingQuantity.toStringAsFixed(2)} ${medication.quantityUnit}\n'
              'Concentration: ${medication.concentration.toStringAsFixed(2)} mcg/${medication.reconstitutionVolumeUnit}\n'
              'Dose: ${schedule.totalDose.toStringAsFixed(2)} ${schedule.doseUnit} (${schedule.insulinUnits.toStringAsFixed(2)} IU)\n'
              'Schedule: ${schedule.frequencyType.toString().split('.').last}, ${schedule.cycleOn} days on, ${schedule.cycleOff} days off, ${schedule.totalCycles} cycles',
          style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: onDoseTaken,
              tooltip: 'Mark Dose Taken',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
              tooltip: 'Edit Medication',
            ),
          ],
        ),
      ),
    );
  }
}