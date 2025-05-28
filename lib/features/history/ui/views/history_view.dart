// lib/features/home/ui/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/medication/ui/widgets/compact_medication_card.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationPresenter = Provider.of<MedicationPresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final medications = medicationPresenter.medications;
    final schedules = schedulePresenter.schedules;

    Schedule? nextSchedule;
    if (schedules.isNotEmpty) {
      nextSchedule = schedules.reduce((a, b) {
        final now = TimeOfDay.now();
        final aTime = a.time;
        final bTime = b.time;
        final aMinutes = aTime.hour * 60 + aTime.minute;
        final bMinutes = bTime.hour * 60 + bTime.minute;
        final nowMinutes = now.hour * 60 + now.minute;
        final aDiff = aMinutes >= nowMinutes ? aMinutes - nowMinutes : 1440 + aMinutes - nowMinutes;
        final bDiff = bMinutes >= nowMinutes ? bMinutes - nowMinutes : 1440 + bMinutes - nowMinutes;
        return aDiff < bDiff ? a : b;
      });
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('MedTrackr'),
        backgroundColor: AppConstants.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/add_schedule');
            },
            tooltip: 'Add Schedule',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: medications.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No medications added. Add one now.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medication_form');
                },
                style: AppConstants.actionButtonStyle,
                child: const Text('Add Medication'),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next Scheduled Dose',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            if (nextSchedule != null)
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(24),
                  title: Text(
                    '${medications.firstWhere((m) => m.id == nextSchedule!.medicationId, orElse: () => Medication(id: '', name: 'Unknown', type: MedicationType.other, quantityUnit: QuantityUnit.mg, quantity: 0, remainingQuantity: 0, reconstitutionVolumeUnit: '', reconstitutionVolume: 0, reconstitutionFluid: '', notes: '')).name} (${nextSchedule.dosageName})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  subtitle: Text(
                    'Time: ${nextSchedule.time.format(context)}\nDose: ${formatNumber(nextSchedule.dosageAmount)} ${nextSchedule.dosageUnit}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              )
            else
              const Text(
                'No upcoming doses scheduled.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            const Text(
              'Medications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: medications.length,
                itemBuilder: (context, index) {
                  final medication = medications[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CompactMedicationCard(medication: medication),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/medication_form');
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/calendar');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    );
  }
}