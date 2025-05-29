// lib/features/medication/ui/widgets/medication_card.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final bool isDark;

  const MedicationCard({super.key, required this.medication, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final dosages = dosagePresenter.getDosagesForMedication(medication.id);
    final schedule = schedulePresenter.getScheduleForMedication(medication.id);
    final isReconstituted = medication.reconstitutionVolume > 0;
    final reconVolumeUnit = medication.reconstitutionVolumeUnit.isNotEmpty ? medication.reconstitutionVolumeUnit : 'mL';
    final remainingFraction = '${formatNumber(medication.remainingQuantity)}/${formatNumber(medication.quantity)} ${medication.quantityUnit.displayName}';
    final reconRemaining = isReconstituted
        ? '${formatNumber(medication.remainingQuantity / (medication.quantity / medication.reconstitutionVolume))}/${formatNumber(medication.reconstitutionVolume)} $reconVolumeUnit'
        : '';

    return GestureDetector(
      onTap: () {
        navigationService.navigateTo('/medication_form', arguments: medication);
      },
      child: Container(
        width: double.infinity,
        decoration: AppConstants.cardDecoration(isDark),
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medication.name,
                  style: AppConstants.cardTitleStyle(isDark).copyWith(fontSize: 20),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppConstants.primaryColor),
                  tooltip: 'Refill Medication',
                  onPressed: () => navigationService.navigateTo('/medication_form', arguments: medication),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Type: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: medication.type.displayName),
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Stock: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: remainingFraction),
                  if (isReconstituted) ...[
                    const TextSpan(text: ', '),
                    TextSpan(text: '$reconRemaining (reconstituted)'),
                  ],
                ],
              ),
            ),
            if (dosages.isNotEmpty) ...[
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Method: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: dosages.first.method.displayName),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Next Dose: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: schedule != null && dosages.isNotEmpty
                          ? '${formatNumber(dosages.first.totalDose)} ${dosages.first.doseUnit} at ${schedule.time.format(context)}'
                          : 'None scheduled',
                    ),
                  ],
                ),
              ),
            ],
            if (isReconstituted) ...[
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Reconstituted with: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${formatNumber(medication.reconstitutionVolume)} $reconVolumeUnit of ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'}',
                    ),
                  ],
                ),
              ),
              if (medication.selectedReconstitution != null && medication.selectedReconstitution!.isNotEmpty) ...[
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                    children: [
                      const TextSpan(
                        text: 'Reference Dose: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${formatNumber(medication.selectedReconstitution?['syringeUnits']?.toDouble() ?? 0)} IU',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' contains '),
                      TextSpan(
                        text: '${formatNumber(medication.selectedReconstitution?['targetDose']?.toDouble() ?? 0)} ${medication.selectedReconstitution?['targetDoseUnit'] ?? 'mcg'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppConstants.secondaryTextStyle(isDark).copyWith(fontSize: 12),
                    children: [
                      const TextSpan(
                        text: 'Concentration: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${formatNumber(medication.selectedReconstitution!['concentration'] ?? 0)} mg/mL',
                      ),
                    ],
                  ),
                ),
              ],
            ],
            if (medication.isLowStock) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Low Stock Warning',
                style: AppThemes.reconstitutionErrorStyle(isDark),
              ),
            ],
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Notes: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: medication.notes.isNotEmpty ? medication.notes : 'None',
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}