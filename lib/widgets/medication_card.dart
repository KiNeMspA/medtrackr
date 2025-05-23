import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage_schedule.dart';
import 'package:medtrackr/screens/add_medication_screen.dart';
import 'package:medtrackr/screens/dosage_schedule_screen.dart';
import 'package:medtrackr/screens/dose_history_screen.dart';
import 'package:medtrackr/services/medication_manager.dart';

class MedicationCard extends StatefulWidget {
  final Medication medication;
  final DosageSchedule schedule;
  final VoidCallback onDoseTaken;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.schedule,
    required this.onDoseTaken,
  });

  @override
  State<MedicationCard> createState() => _MedicationCardState();
}

class _MedicationCardState extends State<MedicationCard> {
  double _scale = 1.0;

  String _formatNumber(double number) {
    return number
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'\.0+$'), '')
        .replaceAll(RegExp(r'\.(\d)0+$'), r'.$1');
  }

  String _getNextDoseDetails() {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    if (widget.schedule.frequencyType == FrequencyType.daily) {
      return 'Daily at ${widget.schedule.notificationTime}';
    } else if (widget.schedule.selectedDays != null &&
        widget.schedule.selectedDays!.isNotEmpty) {
      final nextDay = widget.schedule.selectedDays!.firstWhere(
        (day) => day >= DateTime.now().weekday % 7,
        orElse: () => widget.schedule.selectedDays!.first,
      );
      return '${days[nextDay]} at ${widget.schedule.notificationTime}';
    }
    return 'No schedule set';
  }

  @override
  Widget build(BuildContext context) {
    final isLowQuantity =
        widget.medication.remainingQuantity < widget.medication.quantity * 0.1;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: Transform.scale(
        scale: _scale,
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.medication.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    if (isLowQuantity)
                      Chip(
                        label: const Text('Low Quantity'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                        labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onError),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining: ${_formatNumber(widget.medication.remainingQuantity)} ${widget.medication.quantityUnit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Next Dose: ${_formatNumber(widget.schedule.totalDose)} ${widget.schedule.doseUnit} '
                  '(1mL Syringe: ${_formatNumber(widget.schedule.insulinUnits)} IU), ${_getNextDoseDetails()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  alignment: WrapAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check,
                          color: Theme.of(context).colorScheme.primary),
                      onPressed: widget.onDoseTaken,
                      tooltip: 'Mark Dose Taken',
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    AddMedicationScreen(
                              medication: widget.medication,
                              onSave: (updatedMedication) {
                                MedicationManager.updateMedication(
                                    updatedMedication);
                                Navigator.pop(context);
                              },
                            ),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: const Text('Edit Medication'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                DosageScheduleScreen(
                                    medication: widget.medication),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                          ),
                        ).then((result) {
                          if (result is DosageSchedule) {
                            MedicationManager.addSchedule(result);
                          }
                        });
                      },
                      child: const Text('Edit Dosage'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation,
                                    secondaryAnimation) =>
                                DoseHistoryScreen(schedule: widget.schedule),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: const Text('View History'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
