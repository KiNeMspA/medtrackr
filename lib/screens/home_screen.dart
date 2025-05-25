// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/screens/add_medication_screen.dart';
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
                      frequencyType: FrequencyType.daily,
                      notificationTime: '',
                    ),
                  );
                  final dosage = dataProvider.dosages.firstWhere(
                        (dos) => dos.medicationId == medication.id,
                    orElse: () => Dosage(
                      id: '',
                      medicationId: '',
                      method: DosageMethod.other,
                      doseUnit: '',
                      totalDose: 0.0,
                      volume: 0.0,
                      insulinUnits: 0.0,
                    ),
                  );
                  return MedicationCard(
                    medication: medication,
                    schedule: schedule.id.isNotEmpty ? schedule : null,
                    dosage: dosage.id.isNotEmpty ? dosage : null,
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
  final Dosage? dosage;

  const MedicationCard({
    super.key,
    required this.medication,
    this.schedule,
    this.dosage,
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

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        // Navigate to medication details (implement later)
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Semantics(
          label: 'Medication: ${widget.medication.name}, '
              '${widget.schedule != null ? 'Next Dose: ${widget.schedule!.notificationTime}, ' : ''}'
              '${widget.dosage != null ? 'Dose: ${widget.dosage!.totalDose} ${widget.dosage!.doseUnit}' : ''}',
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
                  if (widget.dosage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Dose: ${widget.dosage!.totalDose} ${widget.dosage!.doseUnit}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.dosage != null) {
                        final takenDosage = Dosage(
                          id: const Uuid().v4(),
                          medicationId: widget.medication.id,
                          method: widget.dosage!.method,
                          doseUnit: widget.dosage!.doseUnit,
                          totalDose: widget.dosage!.totalDose,
                          volume: widget.dosage!.volume,
                          insulinUnits: widget.dosage!.insulinUnits,
                          takenTime: DateTime.now(),
                        );
                        dataProvider.addDosage(takenDosage);
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