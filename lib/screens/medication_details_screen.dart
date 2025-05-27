import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/widgets/cards/medication_card.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication? medication;

  const MedicationDetailsScreen({super.key, required this.medication});

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

    final isReconstituted = medication!.reconstitutionVolume > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(medication!.name),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/medication_form',
                  arguments: medication,
                );
              },
              child: MedicationCard(medication: medication!),
            ),
            const SizedBox(height: 16),
            if (isReconstituted) ...[
              Container(
                decoration: AppConstants.cardDecoration,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reconstitution Details',
                      style: AppConstants.cardTitleStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Volume: ${medication!.reconstitutionVolume.toStringAsFixed(2)} ${medication!.reconstitutionVolumeUnit}',
                      style: AppConstants.cardBodyStyle,
                    ),
                    Text(
                      'Fluid: ${medication!.reconstitutionFluid.isNotEmpty ? medication!.reconstitutionFluid : 'None'}',
                      style: AppConstants.cardBodyStyle,
                    ),
                    if (medication!.selectedReconstitution != null)
                      Text(
                        'Concentration: ${medication!.selectedReconstitution!['concentration']?.toStringAsFixed(2)} mg/mL',
                        style: AppConstants.cardBodyStyle,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (!isReconstituted)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/reconstitute',
                    arguments: medication,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Reconstitute Medication',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}