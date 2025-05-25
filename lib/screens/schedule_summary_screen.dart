import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dddosage_schedule.dart';
import 'package:medtrackr/services/medication_manager.dart';

class ScheduleSummaryScreen extends StatelessWidget {
  const ScheduleSummaryScreen({super.key});

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.(\d)0+$'), r'.$1');
  }

  String _getScheduleDetails(DosageSchedule schedule) {
    if (schedule.frequencyType == FrequencyType.daily) {
      return 'Daily at ${schedule.notificationTime}';
    } else if (schedule.selectedDays != null && schedule.selectedDays!.isNotEmpty) {
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      final selected = schedule.selectedDays!.map((d) => days[d]).join(', ');
      return '$selected at ${schedule.notificationTime}';
    }
    return 'No schedule set';
  }

  @override
  Widget build(BuildContext context) {
    final medications = MedicationManager.medications;
    final schedules = MedicationManager.schedules;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Summary'),
      ),
      body: schedules.isEmpty
          ? Center(
        child: Text(
          'No schedules added yet.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          final medication = medications.firstWhere(
                (m) => m.id == schedule.medicationId,
            orElse: () => Medication(
              name: 'Unknown',
              type: 'Injection',
              storageType: 'Vial',
              quantityUnit: 'mg',
              quantity: 0,
              reconstitutionVolumeUnit: 'mL',
              reconstitutionVolume: 0,
            ),
          );
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                medication.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Dose: ${_formatNumber(schedule.totalDose)} ${schedule.doseUnit} '
                    '(1mL Syringe: ${_formatNumber(schedule.insulinUnits)} IU)\n'
                    'Schedule: ${_getScheduleDetails(schedule)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}