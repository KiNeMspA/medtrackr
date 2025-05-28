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
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationPresenter = Provider.of<MedicationPresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final medications = medicationPresenter.medications;
    final upcomingDoses = schedulePresenter.upcomingDoses;

    Map<String, dynamic>? nextDose;
    if (upcomingDoses.isNotEmpty) {
      nextDose = upcomingDoses.firstWhere(
            (dose) => dose['schedule'] != null,
        orElse: () => {},
      );
      schedulePresenter.loadSchedules(); // Sync with calendar
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('MedTrackr'),
        backgroundColor: AppConstants.primaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/add_schedule');
            },
            tooltip: 'Add Schedule',
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/medication_form');
            },
            tooltip: 'Add Medication',
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
                    'Next Scheduled Doses',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  upcomingDoses.isEmpty
                      ? const Text(
                    'No upcoming doses scheduled.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  )
                      : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      itemCount: upcomingDoses.length,
                      itemBuilder: (context, index) {
                        final dose = upcomingDoses[index];
                        if (dose['schedule'] == null) return const SizedBox.shrink();
                        final schedule = dose['schedule'] as Schedule;
                        return Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(24),
                            title: Text(
                              '${medications.firstWhere((m) => m.id == schedule.medicationId, orElse: () => Medication(id: '', name: 'Unknown', type: MedicationType.other, quantityUnit: QuantityUnit.mg, quantity: 0, remainingQuantity: 0, reconstitutionVolumeUnit: '', reconstitutionVolume: 0, reconstitutionFluid: '', notes: '')).name} (${schedule.dosageName})',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            subtitle: Text(
                              'Time: ${schedule.time.format(context)}\nDose: ${formatNumber(schedule.dosageAmount)} ${schedule.dosageUnit}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                    const Text(
                      'No upcoming doses scheduled.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Medications',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Scrollbar(
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 6,
                      radius: const Radius.circular(8),
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
                  ),
                ],
              ),
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
