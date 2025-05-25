import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/screens/edit_medication_screen.dart';
import 'package:medtrackr/screens/add_dosage_screen.dart';
import 'package:medtrackr/screens/add_schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class MedicationDetailsScreen extends StatefulWidget {
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
  _MedicationDetailsScreenState createState() => _MedicationDetailsScreenState();
}

class _MedicationDetailsScreenState extends State<MedicationDetailsScreen> {
  void _deleteDosage(BuildContext context, String dosageId, String dosageName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete $dosageName?'),
        content: const Text('This will remove the dosage and any linked schedules.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false).deleteDosage(dosageId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$dosageName deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteSchedule(BuildContext context, String scheduleId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule?'),
        content: const Text('This will remove the schedule and its notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false).deleteSchedule(scheduleId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedule deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final schedule = dataProvider.schedules.firstWhere(
              (sch) => sch.medicationId == widget.medication.id,
          orElse: () => Schedule(
            id: '',
            medicationId: '',
            dosageId: '',
            frequencyType: FrequencyType.daily,
            notificationTime: '',
          ),
        );
        final dosages = dataProvider.dosages.where((dos) => dos.medicationId == widget.medication.id).toList();

        return Scaffold(
          backgroundColor: Colors.grey[300],
          appBar: AppBar(
            title: Text(widget.medication.name),
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
                  color: Colors.grey[50],
                  child: ListTile(
                    title: Text('Type: ${widget.medication.type}'),
                    subtitle: Text(
                      'Quantity: ${widget.medication.remainingQuantity} ${widget.medication.quantityUnit}\n'
                          '${widget.medication.reconstitutionVolume > 0 ? 'Reconstituted with ${widget.medication.reconstitutionVolume} ${widget.medication.reconstitutionVolumeUnit}' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditMedicationScreen(
                              medication: widget.medication,
                              schedule: schedule.id.isNotEmpty ? schedule : null,
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
                  color: Colors.grey[50],
                  child: ListTile(
                    title: Text(dosage.name),
                    subtitle: Text(
                      'Dose: ${dosage.totalDose} ${dosage.doseUnit}\n'
                          '${dosage.volume > 0 ? 'Volume: ${dosage.volume.toStringAsFixed(2)} mL\n' : ''}'
                          '${dosage.insulinUnits > 0 ? 'Insulin Units: ${dosage.insulinUnits.toStringAsFixed(1)} IU' : ''}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteDosage(context, dosage.id, dosage.name),
                    ),
                  ),
                )),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final dosage = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddDosageScreen(medication: widget.medication),
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
                if (schedule.id.isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    color: Colors.grey[50],
                    child: ListTile(
                      title: Text('Schedule: ${schedule.notificationTime}'),
                      subtitle: Text(
                        '${schedule.frequencyType == FrequencyType.daily ? 'Daily' : 'Weekly: ${schedule.selectedDays.join(', ')}'}\n'
                            'Dosage: ${dosages.firstWhere((d) => d.id == schedule.dosageId, orElse: () => Dosage(id: '', medicationId: '', name: 'Unknown', method: DosageMethod.other, doseUnit: '', totalDose: 0.0, volume: 0.0, insulinUnits: 0.0)).name}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteSchedule(context, schedule.id),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final newSchedule = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddScheduleScreen(medication: widget.medication, dosages: dosages)),
                    );
                    if (newSchedule != null) {
                      Provider.of<DataProvider>(context, listen: false)
                          .addSchedule(newSchedule.copyWith(medicationId: widget.medication.id));
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
      },
    );
  }
}