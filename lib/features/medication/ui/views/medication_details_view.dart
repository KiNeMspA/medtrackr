// lib/features/medication/ui/views/medication_details_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/widgets/buttons/animated_action_button.dart';
import 'package:medtrackr/core/widgets/dosage_edit_dialog.dart';
import 'package:medtrackr/core/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/core/widgets/navigation/navigation_wrapper.dart';
import 'package:medtrackr/features/medication/ui/widgets/medication_card.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';



class MedicationDetailsView extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsView({super.key, required this.medication});

  Future<void> _deleteMedication(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemes.warningBackgroundColor,
        title: Text('Delete Medication', style: AppThemes.warningTitleStyle),
        content: Text(
          'Are you sure you want to delete ${medication.name}?',
          style: AppThemes.warningContentTextStyle,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppConstants.dialogButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final medicationPresenter =
          Provider.of<MedicationPresenter>(context, listen: false);
      await medicationPresenter.deleteMedication(medication.id);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final dosages = dosagePresenter.getDosagesForMedication(medication.id);
    final schedules = schedulePresenter.upcomingDoses
        .where((dose) => dose['schedule'] != null && dose['schedule'].medicationId == medication.id)
        .map((dose) => dose['schedule'] as Schedule)
        .toSet()
        .toList()
        .take(10)
        .toList();

    return NavigationWrapper(
      currentIndex: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: AppConstants.cardTitleStyle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock Summary',
                      style: AppConstants.cardTitleStyle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remaining: ${formatNumber(medication.remainingQuantity)}/${formatNumber(medication.quantity)} ${medication.quantityUnit.displayName}',
                      style: AppConstants.secondaryTextStyle,
                    ),
                    if (medication.reconstitutionVolume > 0)
                      Text(
                        'Reconstituted: ${formatNumber(medication.reconstitutionVolume)} ${medication.reconstitutionVolumeUnit}',
                        style: AppConstants.secondaryTextStyle,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dosages (${dosages.length})',
                      style: AppConstants.cardTitleStyle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (dosages.isEmpty)
                      Text(
                        'No dosages added.',
                        style: AppConstants.secondaryTextStyle,
                      )
                    else
                      ...dosages.map((dosage) => DosageCard(
                        dosage: dosage,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => DosageEditDialog(
                            dosage: dosage,
                            medication: medication,
                            onSave: (updatedDosage) async {
                              await dosagePresenter.updateDosage(dosage.id, updatedDosage);
                            },
                            isInjection: medication.type == MedicationType.injection,
                            isTabletOrCapsule: medication.type == MedicationType.tablet || medication.type == MedicationType.capsule,
                            isReconstituted: medication.reconstitutionVolume > 0,
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedules (${schedules.length})',
                      style: AppConstants.cardTitleStyle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (schedules.isEmpty)
                      Text(
                        'No schedules added.',
                        style: AppConstants.secondaryTextStyle,
                      )
                    else
                      ...schedules.map((schedule) => ListTile(
                        title: Text(schedule.dosageName),
                        subtitle: Text('${schedule.time.format(context)} - ${formatNumber(schedule.dosageAmount)} ${schedule.dosageUnit}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: AppConstants.accentColor),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            '/schedule_form',
                            arguments: {'medication': medication, 'schedule': schedule},
                          ),
                        ),
                      )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/dosage_form', arguments: medication),
                  style: AppConstants.actionButtonStyle,
                  child: const Text('Add Dosage'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/add_schedule', arguments: medication),
                  style: AppConstants.actionButtonStyle,
                  child: const Text('Add Schedule'),
                ),
                if (medication.type == MedicationType.injection)
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/reconstitute', arguments: medication),
                    style: AppConstants.actionButtonStyle,
                    child: const Text('Reconstitute'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showNoDosageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.informationCardDecoration,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No Dosage Available',
                  style: AppThemes.informationTitleStyle),
              const SizedBox(height: 16),
              const Text(
                'You must create at least one dosage before adding a schedule.',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dosage_form',
                  arguments: medication);
            },
            style: AppConstants.dialogButtonStyle,
            child: const Text('Add Dosage'),
          ),
        ],
      ),
    );
  }


}
