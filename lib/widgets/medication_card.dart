import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage_schedule.dart';
import 'package:medtrackr/screens/add_medication_screen.dart';
import 'package:medtrackr/screens/dosage_schedule_screen.dart';
import 'package:medtrackr/services/medication_manager.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final DosageSchedule schedule;
  final VoidCallback onDoseTaken;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.schedule,
    required this.onDoseTaken,
  });

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.(\d)0+$'), r'.$1');
  }

  String _getNextDoseDetails() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (schedule.frequencyType == FrequencyType.daily) {
      return 'Daily at ${schedule.notificationTime}';
    } else if (schedule.selectedDays != null && schedule.selectedDays!.isNotEmpty) {
      final nextDay = schedule.selectedDays!.firstWhere(
            (day) => day >= DateTime.now().weekday % 7,
        orElse: () => schedule.selectedDays!.first,
      );
      return '${days[nextDay]} at ${schedule.notificationTime}';
    }
    return 'No schedule set';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining: ${_formatNumber(medication.remainingQuantity)} ${medication.quantityUnit}',
              style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            Text(
              'Next Dose: ${_formatNumber(schedule.totalDose)} ${schedule.doseUnit} '
                  '(1mL Syringe: ${_formatNumber(schedule.insulinUnits)} IU), ${_getNextDoseDetails()}',
              style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: onDoseTaken,
                  tooltip: 'Mark Dose Taken',
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedicationScreen(
                          medication: medication,
                          onSave: (updatedMedication) {
                            MedicationManager.updateMedication(updatedMedication);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  },
                  child: const Text('Edit Medication', style: TextStyle(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DosageScheduleScreen(medication: medication),
                      ),
                    ).then((result) {
                      if (result is DosageSchedule) {
                        MedicationManager.addSchedule(result);
                      }
                    });
                  },
                  child: const Text('Edit Dosage', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}