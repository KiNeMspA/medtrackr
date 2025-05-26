import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/constants/constants.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final Schedule? schedule;
  final List<Dosage> dosages;

  const MedicationCard({
    super.key,
    required this.medication,
    this.schedule,
    required this.dosages,
  });

  void _postponeDose(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        DateTime selectedDateTime = DateTime.now();
        return AlertDialog(
          title: const Text('Postpone Dose'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDateTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                    );
                    if (time != null) {
                      selectedDateTime = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    }
                  }
                },
                child: const Text('Select New Date & Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final timeString =
                    '${selectedDateTime.hour % 12 == 0 ? 12 : selectedDateTime.hour % 12}:${selectedDateTime.minute.toString().padLeft(2, '0')} ${selectedDateTime.hour >= 12 ? 'PM' : 'AM'}';
                Provider.of<DataProvider>(context, listen: false)
                    .postponeDose(schedule!.id, timeString);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dosage = dosages.isNotEmpty ? dosages.first : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/medication_details', arguments: medication);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remaining: ${medication.remainingQuantity.toInt()} ${medication.reconstitutionVolume > 0 ? 'mg' : medication.quantityUnit}${medication.reconstitutionVolume > 0 ? ' with ${medication.reconstitutionVolume.toInt()} mL' : ''}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              if (schedule != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Next: ${schedule!.notificationTime}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
              Text(
                medication.type,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (dosage != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Dosage: ${dosage.name}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: schedule != null && dosage != null
                        ? () {
                      Provider.of<DataProvider>(context, listen: false)
                          .takeDose(medication.id, schedule!.id, dosage.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Took dose for ${medication.name}')),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Take Now'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: schedule != null ? () => _postponeDose(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Postpone'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: schedule != null
                        ? () {
                      Provider.of<DataProvider>(context, listen: false)
                          .cancelDose(schedule!.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Canceled dose for ${medication.name}')),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}