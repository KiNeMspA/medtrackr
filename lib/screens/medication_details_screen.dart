import 'package:flutter/material.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/widgets/cards/medication_card.dart';
import 'package:medtrackr/widgets/cards/dosage_card.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication? medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  Future<void> _deleteMedication(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Delete Medication',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${medication!.name}?',
          style: AppConstants.cardBodyStyle,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppConstants.dialogButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.deleteMedication(medication!.id);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (medication == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Medication Overview'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: AppConstants.cardDecoration,
                child: MedicationCard(medication: medication!),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dosages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  final dosages =
                  dataProvider.getDosagesForMedication(medication!.id);
                  return dosages.isEmpty
                      ? const Text(
                    'No dosages added.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  )
                      : Column(
                    children: dosages
                        .map<Widget>((dosage) => DosageCard(
                      dosage: dosage,
                      onTap: () => Navigator.pushNamed(
                          context, '/dosage_form',
                          arguments: {
                            'medication': medication,
                            'dosage': dosage
                          }),
                    ))
                        .toList(),
                  );
                },
              ),
              if (medication!.type == MedicationType.injection) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/reconstitute',
                      arguments: medication,
                    );
                  },
                  style: AppConstants.actionButtonStyle,
                  child: Text(
                    medication!.reconstitutionVolume > 0
                        ? 'Edit Reconstitution'
                        : 'Reconstitute',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/dosage_form',
                    arguments: medication,
                  );
                },
                style: AppConstants.actionButtonStyle,
                child: const Text('Add Dosage'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _deleteMedication(context),
                style: AppConstants.actionButtonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.red[300]),
                ),
                child: const Text('Delete Medication'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/calendar');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    );
  }
}