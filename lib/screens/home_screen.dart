import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/screens/add_medication_screen.dart';
import 'package:medtrackr/widgets/medication_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Medication> _medications = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MedTrackr'),
      ),
      body: _medications.isEmpty
          ? const Center(child: Text('No medications added yet.'))
          : ListView.builder(
        itemCount: _medications.length,
        itemBuilder: (context, index) {
          return MedicationCard(
            medication: _medications[index],
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddMedicationScreen(
                    medication: _medications[index],
                    onSave: (updatedMedication) {
                      setState(() {
                        _medications[index] = updatedMedication;
                      });
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMedicationScreen(
                onSave: (medication) {
                  setState(() {
                    _medications.add(medication);
                  });
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Track Medication',
      ),
    );
  }
}