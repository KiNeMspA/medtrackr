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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Overview'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please add the medication stock to begin tracking.',
              style: AppConstants.cardBodyStyle.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(
              'Medication Details',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            MedicationCard(medication: medication!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/add_dosage',
                  arguments: {'medication': medication},
                );
              },
              style: AppConstants.actionButtonStyle,
              child: const Text('Add Dosage'),
            ),
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
              child: const Text('Edit Reconstitution'),
            ),
          ],
        ),
      ),
    );
  }
}