import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage_schedule.dart';
import 'package:medtrackr/screens/add_medication_screen.dart';
import 'package:medtrackr/services/medication_manager.dart';
import 'package:medtrackr/widgets/medication_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    MedicationManager.load().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final medications = MedicationManager.medications;
    final schedules = MedicationManager.schedules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MedTrackr', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: medications.isEmpty
          ? Center(
        child: Text(
          'No medications added yet.',
          style: TextStyle(fontSize: 18, color: Colors.blueGrey.shade400),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final medication = medications[index];
          final schedule = schedules.firstWhere(
                (s) => s.medicationId == medication.id,
            orElse: () => DosageSchedule(
              medicationId: medication.id,
              method: DosageMethod.subcutaneous,
              doseUnit: 'mcg',
              totalDose: 0,
              volume: 0,
              insulinUnits: 0,
              frequencyType: FrequencyType.daily,
              selectedDays: null,
              notificationTime: '',
            ),
          );
          return MedicationCard(
            medication: medication,
            schedule: schedule,
            onDoseTaken: () {
              MedicationManager.markDoseTaken(medication, schedule, DateTime.now());
              setState(() {});
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicationScreen(
                onSave: (medication) {
                  MedicationManager.addMedication(medication);
                },
              ),
            ),
          );
          if (result is DosageSchedule) {
            MedicationManager.addSchedule(result);
          }
          setState(() {});
        },
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Add Medication',
        child: const Icon(Icons.add),
      ),
    );
  }
}