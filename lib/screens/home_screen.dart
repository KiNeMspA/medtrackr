import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final medications = dataProvider.medications;
    final schedules = dataProvider.schedules;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('MedTrackr', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFC107),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/add_schedule');
            },
            tooltip: 'Add Schedule',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: medications.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No medications added. Add one now.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medication_form');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Add Medication', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Doses',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            schedules.isEmpty
                ? const SizedBox()
                : Expanded(
              child: ListView.builder(
                itemCount: schedules.length.clamp(0, 3),
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  final medication = medications.firstWhere(
                        (m) => m.id == schedule.medicationId,
                    orElse: () => Medication(
                      id: '',
                      name: 'Unknown',
                      type: '',
                      quantityUnit: '',
                      quantity: 0,
                      remainingQuantity: 0,
                      reconstitutionVolumeUnit: '',
                      reconstitutionVolume: 0,
                      reconstitutionFluid: '',
                      notes: '',
                    ),
                  );
                  final isFirst = index == 0;
                  return Card(
                    elevation: isFirst ? 6 : 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(isFirst ? 24 : 16),
                      title: Text(
                        '${medication.name} (${schedule.dosageName})',
                        style: TextStyle(
                          fontSize: isFirst ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        'Time: ${schedule.time.format(context)}\nDose: ${schedule.dosageAmount.toStringAsFixed(schedule.dosageAmount % 1 == 0 ? 0 : 1)} ${schedule.dosageUnit}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      trailing: isFirst
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Color(0xFFFFC107)),
                            onPressed: () {
                              dataProvider.takeDose(
                                medication.id,
                                schedule.id,
                                schedule.dosageId,
                              );
                            },
                            tooltip: 'Take Now',
                          ),
                          IconButton(
                            icon: const Icon(Icons.schedule, color: Colors.grey),
                            onPressed: () {
                              dataProvider.postponeDose(
                                schedule.id,
                                '${schedule.time.hour + 1}:${schedule.time.minute}',
                              );
                            },
                            tooltip: 'Postpone',
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () {
                              dataProvider.cancelDose(schedule.id);
                            },
                            tooltip: 'Cancel',
                          ),
                        ],
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/medication_form');
        },
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}