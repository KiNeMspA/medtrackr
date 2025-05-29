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
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();
  bool _isMounted = true;
  final Map<String, bool> _expandedMedications = {};

  @override
  void initState() {
    super.initState();
    final medicationPresenter = Provider.of<MedicationPresenter>(
        context, listen: false);
    final schedulePresenter = Provider.of<SchedulePresenter>(
        context, listen: false);
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final medicationPresenter = Provider.of<MedicationPresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final medications = medicationPresenter.medications;
    final schedules = schedulePresenter.upcomingDoses;

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
                onPressed: () =>
                    Navigator.pushNamed(context, '/medication_form'),
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
                  'Today’s Overview',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 18),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/calendar'),
                  child: Text(
                    'View Calendar',
                    style: TextStyle(
                        color: AppConstants.primaryColor, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              floatingActionButton: FloatingActionButton(
                onPressed: () => Navigator.pushNamed(context, '/medication_form'),
                backgroundColor: AppConstants.primaryColor,
                child: const Icon(Icons.add),
                tooltip: 'Add Medication',
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${schedules
                          .where((dose) =>
                      dose['nextTime'].day == DateTime
                          .now()
                          .day)
                          .length} doses today',
                      style: AppConstants.cardTitleStyle.copyWith(fontSize: 14),
                    ),
                    Text(
                      '${medications
                          .where((m) => m.remainingQuantity < m.quantity * 0.2)
                          .length} low stock alerts',
                      style: AppConstants.secondaryTextStyle.copyWith(
                          fontSize: 12, color: AppConstants.errorColor),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Medications & Schedules',
              style: AppConstants.cardTitleStyle.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 4,
                radius: const Radius.circular(4),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: medications.length,
                  itemBuilder: (context, index) {
                    final medication = medications[index];
                    final medicationSchedules = schedules
                        .where((dose) =>
                    dose['schedule'] != null && dose['schedule'].medicationId ==
                        medication.id)
                        .toList();
                    final isExpanded = _expandedMedications[medication.id] ??
                        false;

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            title: Text(
                              medication.name,
                              style: AppConstants.cardTitleStyle.copyWith(
                                  fontSize: 16),
                            ),
                            subtitle: Text(
                              'Stock: ${formatNumber(
                                  medication.remainingQuantity)}/${formatNumber(
                                  medication.quantity)} ${medication
                                  .quantityUnit.displayName}',
                              style: AppConstants.secondaryTextStyle.copyWith(
                                  fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isExpanded ? Icons.expand_less : Icons
                                    .expand_more,
                                color: AppConstants.primaryColor,
                              ),
                              onPressed: () {
                                setState(() {
                                  _expandedMedications[medication.id] =
                                  !isExpanded;
                                });
                              },
                            ),
                            onTap: () =>
                                Navigator.pushNamed(
                                    context, '/medication_details',
                                    arguments: medication),
                          ),


                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Schedules (${medicationSchedules.length})',
                                    style: AppConstants.cardTitleStyle.copyWith(
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  if (medicationSchedules.isEmpty)
                                    Text(
                                      'No schedules added.',
                                      style: AppConstants.secondaryTextStyle
                                          .copyWith(fontSize: 12),
                                    )

                                  else
                                    ...medicationSchedules.map((dose) {
                                      final schedule = dose['schedule'] as Schedule;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: AppConstants.cardDecoration
                                            .copyWith(
                                          borderRadius: BorderRadius.circular(
                                              6),
                                        ),

                                        height: 60,
                                        child: ListTile(
                                          dense: true,
                                          contentPadding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8, vertical: 4),
                                          title: Text(
                                            schedule.dosageName,
                                            style: AppConstants.cardTitleStyle
                                                .copyWith(fontSize: 14),
                                          ),
                                          subtitle: Text(
                                            '${schedule.time.format(
                                                context)} - ${formatNumber(
                                                schedule
                                                    .dosageAmount)} ${schedule
                                                .dosageUnit}',
                                            style: AppConstants
                                                .secondaryTextStyle.copyWith(
                                                fontSize: 12),
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.check_circle,
                                                    size: 18,
                                                    color: Colors.green),
                                                onPressed: () =>
                                                    dosagePresenter.takeDose(
                                                      schedule.medicationId,
                                                      schedule.id,
                                                      schedule.dosageId,
                                                    ),
                                                tooltip: 'Take Now',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.access_time, size: 18,
                                                    color: AppConstants
                                                        .primaryColor),
                                                onPressed: () =>
                                                    schedulePresenter
                                                        .postponeDose(
                                                        schedule.id, '30'),
                                                tooltip: 'Postpone',
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.cancel, size: 18,
                                                    color: AppConstants
                                                        .errorColor),
                                                onPressed: () =>
                                                    schedulePresenter
                                                        .cancelDose(
                                                        schedule.id),
                                                tooltip: 'Cancel',
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.edit, size: 18, color: AppConstants.accentColor),
                                                onPressed: () {
                                                  if (schedule.id.isNotEmpty) {
                                                    print('Navigating to schedule_form with schedule: ${schedule.id}');
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/schedule_form',
                                                      arguments: {'medication': medication, 'schedule': schedule},
                                                    );
                                                  } else {
                                                    print('Invalid schedule ID');
                                                  }
                                                },
                                                tooltip: 'Edit',
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushNamed(
                                                context, '/dosage_form',
                                                arguments: medication),
                                        child: const Text('Add Dosage'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pushNamed(
                                                context, '/add_schedule',
                                                arguments: medication),
                                        child: const Text('Add Schedule'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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