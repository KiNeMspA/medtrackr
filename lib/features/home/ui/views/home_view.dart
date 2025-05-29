// lib/features/home/ui/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/medication/ui/widgets/compact_medication_card.dart';
import 'package:medtrackr/core/widgets/navigation/navigation_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scheduleScrollController = ScrollController();
  final ScrollController _medicationScrollController = ScrollController();
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
    final schedulePresenter = Provider.of<SchedulePresenter>(context, listen: false);
    medicationPresenter.loadMedications().then((_) {
      if (_isMounted) setState(() {});
    });
    schedulePresenter.loadSchedules().then((_) {
      if (_isMounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _scheduleScrollController.dispose();
    _medicationScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicationPresenter = Provider.of<MedicationPresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final medications = medicationPresenter.medications;
    final upcomingDoses = schedulePresenter.upcomingDoses;

    return NavigationWrapper(
      currentIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: medications.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No medications added. Add one now.',
                style: AppConstants.secondaryTextStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/medication_form'),
                style: AppConstants.actionButtonStyle,
                child: const Text('Add Medication'),
              ),
            ],
          ),
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Scheduled Doses',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 16),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/calendar'),
                  child: Text(
                    'View Calendar',
                    style: TextStyle(color: AppConstants.primaryColor, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            upcomingDoses.isEmpty
                ? Text(
              'No upcoming doses scheduled.',
              style: AppConstants.secondaryTextStyle.copyWith(fontSize: 14),
            )
                : SizedBox(
              height: 100,
              child: Scrollbar(
                controller: _scheduleScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 4,
                radius: const Radius.circular(4),
                child: ListView.builder(
                  controller: _scheduleScrollController,
                  itemCount: upcomingDoses.length,
                  itemBuilder: (context, index) {
                    final dose = upcomingDoses[index];
                    if (dose['schedule'] == null) return const SizedBox.shrink();
                    final schedule = dose['schedule'] as Schedule;
                    final medication = medications.firstWhere(
                          (m) => m.id == schedule.medicationId,
                      orElse: () => Medication(
                        id: '',
                        name: 'Unknown',
                        type: MedicationType.other,
                        quantityUnit: QuantityUnit.mg,
                        quantity: 0,
                        remainingQuantity: 0,
                        reconstitutionVolumeUnit: '',
                        reconstitutionVolume: 0,
                        reconstitutionFluid: '',
                        notes: '',
                      ),
                    );
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: AppConstants.cardDecoration,
                      height: 60,
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        title: Text(
                          '${medication.name} (${schedule.dosageName})',
                          style: AppConstants.cardTitleStyle.copyWith(fontSize: 14),
                        ),
                        subtitle: Text(
                          '${schedule.time.format(context)} - ${formatNumber(schedule.dosageAmount)} ${schedule.dosageUnit}',
                          style: AppConstants.secondaryTextStyle.copyWith(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle, size: 18, color: Colors.green),
                              onPressed: () => Provider.of<DosagePresenter>(context, listen: false).takeDose(
                                schedule.medicationId,
                                schedule.id,
                                schedule.dosageId,
                              ),
                              tooltip: 'Take Now',
                            ),
                            IconButton(
                              icon: const Icon(Icons.access_time, size: 18, color: AppConstants.primaryColor),
                              onPressed: () => Provider.of<SchedulePresenter>(context, listen: false).postponeDose(schedule.id, '30'),
                              tooltip: 'Postpone',
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel, size: 18, color: AppConstants.errorColor),
                              onPressed: () => Provider.of<SchedulePresenter>(context, listen: false).cancelDose(schedule.id),
                              tooltip: 'Cancel',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18, color: AppConstants.accentColor),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                '/schedule_form',
                                arguments: {'medication': medication, 'schedule': schedule},
                              ),
                              tooltip: 'Edit',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Medications',
              style: AppConstants.cardTitleStyle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Scrollbar(
                controller: _medicationScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 4,
                radius: const Radius.circular(4),
                child: ListView.builder(
                  controller: _medicationScrollController,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: CompactMedicationCard(medication: medication),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}