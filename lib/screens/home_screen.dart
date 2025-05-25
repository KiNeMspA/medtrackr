import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/medication_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final upcomingDoses = dataProvider.upcomingDoses;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('MedTrackr'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Doses',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          Expanded(
            child: upcomingDoses.isEmpty
                ? const Center(child: Text('No upcoming doses'))
                : ListView.builder(
              itemCount: upcomingDoses.length,
              itemBuilder: (context, index) {
                final item = upcomingDoses[index];
                return MedicationCard(
                  medication: item['medication'] as Medication,
                  schedule: item['schedule'] as Schedule?,
                  dosages: item['dosages'] as List<Dosage>,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}