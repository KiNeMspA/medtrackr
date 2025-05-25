import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  void _editDosage(BuildContext context, Dosage dosage) async {
    final nameController = TextEditingController(text: dosage.name);
    String doseUnit = dosage.doseUnit;
    final doseController = TextEditingController(text: dosage.totalDose.toString());
    DosageMethod method = dosage.method;

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[50],
        title: const Text('Edit Dosage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Dosage Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: doseController,
                      decoration: InputDecoration(
                        labelText: 'Dose Amount',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: doseUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['IU', 'mcg', 'mg', 'mL']
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) => doseUnit = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DosageMethod>(
                value: method,
                decoration: InputDecoration(
                  labelText: 'Method',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: DosageMethod.values
                    .map((m) => DropdownMenuItem(value: m, child: Text(m.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => method = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated == true) {
      final updatedDosage = dosage.copyWith(
        name: nameController.text,
        doseUnit: doseUnit,
        totalDose: double.tryParse(doseController.text) ?? dosage.totalDose,
        insulinUnits: double.tryParse(doseController.text) ?? dosage.insulinUnits,
        method: method,
      );
      Provider.of<DataProvider>(context, listen: false).deleteDosage(dosage.id);
      Provider.of<DataProvider>(context, listen: false).addDosage(updatedDosage);
    }
  }

  void _editSchedule(BuildContext context, Schedule schedule) async {
    final timeController = TextEditingController(text: schedule.notificationTime);
    FrequencyType frequency = schedule.frequencyType;

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[50],
        title: const Text('Edit Schedule'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Notification Time (e.g., 8:00 AM)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<FrequencyType>(
                value: frequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: FrequencyType.values
                    .map((f) => DropdownMenuItem(value: f, child: Text(f.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => frequency = value!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated == true) {
      final updatedSchedule = schedule.copyWith(
        notificationTime: timeController.text,
        frequencyType: frequency,
      );
      Provider.of<DataProvider>(context, listen: false).updateSchedule(schedule.id, updatedSchedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final schedules = dataProvider.getScheduleForMedication(medication.id);
    final dosages = dataProvider.getDosagesForMedication(medication.id);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Details for ${medication.name}'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medication Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${medication.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Type: ${medication.type}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Remaining: ${medication.remainingQuantity.toInt()} ${medication.reconstitutionVolume > 0 ? 'mg' : medication.quantityUnit}${medication.reconstitutionVolume > 0 ? ' with ${medication.reconstitutionVolume.toInt()} mL' : ''}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      if (medication.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Notes: ${medication.notes}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                      if (medication.selectedReconstitution != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Reconstitution: ${medication.selectedReconstitution!['volume']} mL = ${medication.selectedReconstitution!['iu']} IU',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Dosages',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              dosages.isEmpty
                  ? const Text('No dosages added', style: TextStyle(color: Colors.grey))
                  : Column(
                children: dosages
                    .map((dosage) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      dosage.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      'Dose: ${dosage.totalDose} ${dosage.doseUnit}\n'
                          'Method: ${dosage.method.toString().split('.').last}\n'
                          '${dosage.takenTime != null ? 'Taken: ${dosage.takenTime}' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                      onPressed: () => _editDosage(context, dosage),
                    ),
                  ),
                ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Schedules',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              schedules == null
                  ? const Text('No schedules added', style: TextStyle(color: Colors.grey))
                  : Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Next: ${schedules.notificationTime}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    'Frequency: ${schedules.frequencyType.toString().split('.').last}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFFFFC107)),
                    onPressed: () => _editSchedule(context, schedules),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}