import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/screens/edit_medication_screen.dart';
import 'package:medtrackr/screens/add_dosage_screen.dart';
import 'package:medtrackr/screens/add_schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;
  final Schedule? schedule;
  final List<Dosage> dosages;

  const MedicationDetailsScreen({
    super.key,
    required this.medication,
    this.schedule,
    required this.dosages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(medication.name),
        backgroundColor: const Color(0xFFFFC107),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: Text('Type: ${medication.type}'),
                subtitle: Text(
                  'Quantity: ${medication.remainingQuantity} ${medication.quantityUnit}\n'
                      '${medication.reconstitutionVolume > 0 ? 'Reconstituted with ${medication.reconstitutionVolume} ${medication.reconstitutionVolumeUnit}' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMedicationScreen(
                          medication: medication,
                          schedule: schedule,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dosages',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            ...dosages.map((dosage) => Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: Text(dosage.name),
                subtitle: Text(
                  'Dose: ${dosage.totalDose} ${dosage.doseUnit}\n'
                      '${dosage.volume > 0 ? 'Volume: ${dosage.volume.toStringAsFixed(2)} mL\n' : ''}'
                      '${dosage.insulinUnits > 0 ? 'Insulin Units: ${dosage.insulinUnits.toStringAsFixed(1)} IU' : ''}',
                ),
              ),
            )),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final dosage = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDosageScreen(medication: medication),
                  ),
                );
                if (dosage != null) {
                  Provider.of<DataProvider>(context, listen: false).addDosage(dosage);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Dosage', style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 16),
            Text(
              'Schedules',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (schedule != null)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  title: Text('Schedule: ${schedule!.notificationTime}'),
                  subtitle: Text(
                    '${schedule!.frequencyType == FrequencyType.daily ? 'Daily' : 'Weekly: ${schedule!.selectedDays.join(', ')}'}\n'
                        'Dosage: ${dosages.firstWhere((d) => d.id == schedule!.dosageId, orElse: () => Dosage(id: '', medicationId: '', name: 'Unknown', method: DosageMethod.other, doseUnit: '', totalDose: 0.0, volume: 0.0, insulinUnits: 0.0)).name}',
                  ),
                ),
              ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final schedule = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddScheduleScreen(medication: medication, dosages: dosages)),
                );
                if (schedule != null) {
                  Provider.of<DataProvider>(context, listen: false)
                      .addSchedule(schedule.copyWith(medicationId: medication.id));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Add Schedule', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}