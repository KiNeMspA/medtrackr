import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  IconData _getMedicationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'tablet':
        return Icons.tablet;
      case 'capsule':
        return Icons.medication;
      case 'injection':
        return Icons.medical_services
        ;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final dosages = dataProvider.getDosagesForMedication(medication.id);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(medication.name),
        backgroundColor: const Color(0xFFFFC107),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Medication'),
                  content: const Text('Are you sure you want to delete this medication and all its dosages?'),
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
              if (confirmed == true && context.mounted) {
                print('Deleting medication: ${medication.id}');
                dataProvider.deleteMedication(medication.id);
                Navigator.popUntil(context, ModalRoute.withName('/'));
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getMedicationIcon(medication.type), color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text('Name: ${medication.name}', style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                    Text('Type: ${medication.type}', style: Theme.of(context).textTheme.bodyLarge),
                    Text(
                      'Total: ${medication.quantity.toInt()} ${medication.quantityUnit}${medication.type == 'Tablet' || medication.type == 'Capsule' ? ' units' : ''}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    Text('Remaining: ${medication.remainingQuantity.toInt()} ${medication.quantityUnit}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    if (medication.reconstitutionVolume > 0)
                      Text(
                        'Reconstituted with ${medication.reconstitutionVolume.toInt()} mL for ${medication.selectedReconstitution?['iu'] ?? 0} IU/mL',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    if (medication.reconstitutionFluid.isNotEmpty)
                      Text('Fluid: ${medication.reconstitutionFluid}', style: Theme.of(context).textTheme.bodyLarge),
                    Text('Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
                        style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dosages',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            dosages.isEmpty
                ? const Text('No dosages added', style: TextStyle(fontSize: 16))
                : Expanded(
              child: ListView.builder(
                itemCount: dosages.length,
                itemBuilder: (context, index) {
                  final dosage = dosages[index];
                  return ListTile(
                    title: Text(dosage.name),
                    subtitle: Text('Dose: ${dosage.totalDose} ${dosage.doseUnit} (${dosage.method.toString().split('.').last})'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            print('Editing dosage: ${dosage.id}');
                            Navigator.pushNamed(
                              context,
                              '/add_dosage',
                              arguments: {
                                'medication': medication,
                                'dosage': dosage,
                                'targetDoseMcg': dosage.totalDose,
                                'selectedIU': dosage.insulinUnits,
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Dosage'),
                                content: const Text('Are you sure you want to delete this dosage?'),
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
                            if (confirmed == true && context.mounted) {
                              print('Deleting dosage: ${dosage.id}');
                              dataProvider.deleteDosage(dosage.id);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('Navigating to AddDosageScreen from MedicationDetailsScreen');
                Navigator.pushNamed(
                  context,
                  '/add_dosage',
                  arguments: {
                    'medication': medication,
                    'targetDoseMcg': medication.reconstitutionVolume > 0 ? (medication.selectedReconstitution?['iu']?.toDouble() ?? 0) : 0.0,
                    'selectedIU': medication.reconstitutionVolume > 0 ? (medication.selectedReconstitution?['iu']?.toDouble() ?? 0) : 0.0,
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Dosage', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print('Navigating to MedicationFormScreen to edit medication');
                Navigator.pushNamed(
                  context,
                  '/medication_form',
                  arguments: medication,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Edit Medication', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}