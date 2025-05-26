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
        return Icons.medical_services;
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
        title: Text(medication.name, style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFC107),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => _buildConfirmationDialog(context),
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
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                print('Navigating to MedicationFormScreen to edit medication');
                Navigator.pushNamed(
                  context,
                  '/medication_form',
                  arguments: medication,
                );
              },
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getMedicationIcon(medication.type), color: const Color(0xFFFFC107)),
                          const SizedBox(width: 8),
                          Text(
                            medication.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Type: ${medication.type}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                      Text(
                        'Remaining: ${medication.remainingQuantity.toInt()}/${medication.quantity.toInt()} ${medication.quantityUnit}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      if (medication.reconstitutionVolume > 0)
                        Text(
                          'Reconstituted with ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'Fluid'} ${medication.reconstitutionVolume} mL, ${(medication.selectedReconstitution?['iu'] ?? 0) / medication.reconstitutionVolume} mcg/mL',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      if (medication.notes.isNotEmpty)
                        Text('Notes: ${medication.notes}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Dosages',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            dosages.isEmpty
                ? const Text('No dosages added', style: TextStyle(fontSize: 16, color: Colors.grey))
                : Expanded(
              child: ListView.builder(
                itemCount: dosages.length,
                itemBuilder: (context, index) {
                  final dosage = dosages[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        dosage.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      subtitle: Text(
                        'Dose: ${dosage.totalDose.toStringAsFixed(dosage.totalDose % 1 == 0 ? 0 : 1)} ${dosage.doseUnit}\nMethod: ${dosage.method.toString().split('.').last.replaceAll('subcutaneous', 'Subcutaneous Injection')}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => _buildConfirmationDialog(context, title: 'Delete Dosage'),
                              );
                              if (confirmed == true && context.mounted) {
                                print('Deleting dosage: ${dosage.id}');
                                dataProvider.deleteDosage(dosage.id);
                              }
                            },
                          ),
                        ],
                      ),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: const Text('Add Dosage', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text('Medication: ${medication.name}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    Text('Type: ${medication.type}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    Text(
                      'Remaining: ${medication.remainingQuantity.toInt()}/${medication.quantity.toInt()} ${medication.quantityUnit}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    if (medication.reconstitutionVolume > 0)
                      Text(
                        'Reconstituted: ${medication.reconstitutionFluid} ${medication.reconstitutionVolume} mL, ${(medication.selectedReconstitution?['iu'] ?? 0) / medication.reconstitutionVolume} mcg/mL',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    if (dosages.isNotEmpty)
                      Text(
                        'Latest Dosage: ${dosages.last.name} (${dosages.last.totalDose.toStringAsFixed(dosages.last.totalDose % 1 == 0 ? 0 : 1)} ${dosages.last.doseUnit}, ${dosages.last.method.toString().split('.').last.replaceAll('subcutaneous', 'Subcutaneous Injection')})',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationDialog(BuildContext context, {String title = 'Delete Medication'}) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this ${title.toLowerCase().contains('dosage') ? 'dosage' : 'medication and all its dosages'}?',
        style: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}