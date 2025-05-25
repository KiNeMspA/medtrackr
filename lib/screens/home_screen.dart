import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/screens/add_medication_screen.dart';
import 'package:medtrackr/screens/medication_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatelessWidget {
  final Dosage? dosage;
  final String? medicationId;

  const HomeScreen({super.key, this.dosage, this.medicationId});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    if (dosage != null && medicationId != null) {
      dataProvider.addDosage(dosage!.copyWith(medicationId: medicationId!));
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Medications',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dataProvider.medications.length,
                itemBuilder: (context, index) {
                  final medication = dataProvider.medications[index];
                  final schedule = dataProvider.schedules.firstWhere(
                        (sch) => sch.medicationId == medication.id,
                    orElse: () => Schedule(
                      id: '',
                      medicationId: '',
                      dosageId: '',
                      frequencyType: FrequencyType.daily,
                      notificationTime: '',
                    ),
                  );
                  final dosages = dataProvider.dosages.where((dos) => dos.medicationId == medication.id).toList();
                  return MedicationCard(
                    medication: medication,
                    schedule: schedule.id.isNotEmpty ? schedule : null,
                    dosages: dosages,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMedicationScreen()),
          );
          if (result != null) {
            final (medication, schedule, dosage) = result as (Medication?, Schedule?, Dosage?);
            if (medication != null) {
              dataProvider.addMedication(medication);
              if (schedule != null) {
                dataProvider.addSchedule(schedule.copyWith(medicationId: medication.id));
              }
              if (dosage != null) {
                dataProvider.addDosage(dosage.copyWith(medicationId: medication.id));
              }
            }
          }
        },
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MedicationCard extends StatefulWidget {
  final Medication medication;
  final Schedule? schedule;
  final List<Dosage> dosages;

  const MedicationCard({
    super.key,
    required this.medication,
    this.schedule,
    required this.dosages,
  });

  @override
  _MedicationCardState createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showEditDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Manage ${widget.medication.name}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MedicationDetailsScreen(
                    medication: widget.medication,
                    schedule: widget.schedule,
                    dosages: widget.dosages,
                  ),
                ),
              );
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<DataProvider>(context, listen: false).deleteMedication(widget.medication.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${widget.medication.name} deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final primaryDosage = widget.dosages.isNotEmpty ? widget.dosages[0] : null;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicationDetailsScreen(
              medication: widget.medication,
              schedule: widget.schedule,
              dosages: widget.dosages,
            ),
          ),
        );
      },
      onLongPress: () => _showEditDeleteDialog(context),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Semantics(
          label: 'Medication: ${widget.medication.name}, '
              '${widget.schedule != null ? 'Next Dose: ${widget.schedule!.notificationTime}, ' : ''}'
              '${primaryDosage != null ? 'Dose: ${primaryDosage.totalDose} ${primaryDosage.doseUnit}' : ''}',
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.only(right: 8),
            child: Container(
              width: 180,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.medication.name,
                    style: Theme.of(context).textTheme.titleLarge,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.schedule != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Next Dose: ${widget.schedule!.notificationTime}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (primaryDosage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dose: ${primaryDosage.totalDose} ${primaryDosage.doseUnit}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Remaining: ${widget.medication.remainingQuantity} ${widget.medication.quantityUnit}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (primaryDosage != null) {
                        final takenDosage = Dosage(
                          id: const Uuid().v4(),
                          medicationId: widget.medication.id,
                          name: primaryDosage.name,
                          method: primaryDosage.method,
                          doseUnit: primaryDosage.doseUnit,
                          totalDose: primaryDosage.totalDose,
                          volume: primaryDosage.volume,
                          insulinUnits: primaryDosage.insulinUnits,
                          takenTime: DateTime.now(),
                        );
                        dataProvider.addDosage(takenDosage);
                        dataProvider.updateMedication(
                          widget.medication.id,
                          widget.medication.copyWith(
                            remainingQuantity: widget.medication.remainingQuantity - primaryDosage.totalDose,
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget.medication.name} dose recorded')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Take Now', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}