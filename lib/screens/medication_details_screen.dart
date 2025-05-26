import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/dosage_edit_dialog.dart';
import 'package:medtrackr/widgets/schedule_edit_dialog.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final schedules = dataProvider.getScheduleForMedication(medication.id);
    final dosages = dataProvider.getDosagesForMedication(medication.id);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(medication.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Medication'),
                  content: Text('Are you sure you want to delete ${medication.name}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                Provider.of<DataProvider>(context, listen: false).deleteMedication(medication.id);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medication Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${medication.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${medication.type}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Remaining: ${medication.remainingQuantity.toInt()} ${medication.reconstitutionVolume > 0 ? 'mg' : medication.quantityUnit}${medication.reconstitutionVolume > 0 ? ' with ${medication.reconstitutionVolume.toInt()} mL' : ''}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (medication.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Notes: ${medication.notes}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      if (medication.selectedReconstitution != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reconstitution: ${medication.selectedReconstitution!['volume']} mL = ${medication.selectedReconstitution!['iu']} IU',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dosages',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              dosages.isEmpty
                  ? const Text('No dosages added', style: TextStyle(color: Colors.grey))
                  : Column(
                children: dosages
                    .map((dosage) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      dosage.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Dose: ${dosage.totalDose} ${dosage.doseUnit}\n'
                          'Method: ${dosage.method.toString().split('.').last}\n'
                          '${dosage.takenTime != null ? 'Taken: ${dosage.takenTime}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => DosageEditDialog(
                          dosage: dosage,
                          onSave: (updatedDosage) {
                            Provider.of<DataProvider>(context, listen: false)
                                .deleteDosage(dosage.id);
                            Provider.of<DataProvider>(context, listen: false)
                                .addDosage(updatedDosage);
                          },
                        ),
                      ),
                    ),
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Schedules',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              schedules == null
                  ? const Text('No schedules added', style: TextStyle(color: Colors.grey))
                  : Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Next: ${schedules.notificationTime}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Frequency: ${schedules.frequencyType.toString().split('.').last}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => ScheduleEditDialog(
                        schedule: schedules,
                        onSave: (updatedSchedule) {
                          Provider.of<DataProvider>(context, listen: false)
                              .updateSchedule(schedules.id, updatedSchedule);
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}