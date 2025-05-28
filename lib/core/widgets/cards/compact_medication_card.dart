// In lib/core/widgets/cards/compact_medication_card.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/data/data_sources/local/data_provider.dart';

class CompactMedicationCard extends StatelessWidget {
  final Medication medication;

  const CompactMedicationCard({super.key, required this.medication});

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final dosages = dataProvider.getDosagesForMedication(medication.id);
    final schedule = dataProvider.getScheduleForMedication(medication.id);
    final isReconstituted = medication.reconstitutionVolume > 0;
    final reconVolumeUnit = medication.reconstitutionVolumeUnit.isNotEmpty
        ? medication.reconstitutionVolumeUnit
        : 'mL';
    final isInjection = dosages.isNotEmpty &&
        [
          DosageMethod.subcutaneous,
        ].contains(dosages.first.method);

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/medication_details',
          arguments: medication,
        );
      },
      child: Container(
        width: double.infinity,
        decoration: AppConstants.cardDecoration,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication.name,
              style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Stock: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text:
                      '${formatNumber(medication.remainingQuantity)}/${formatNumber(medication.quantity)} ${medication.quantityUnit.displayName}'),
                  if (isReconstituted) ...[
                    const TextSpan(text: ', '),
                    TextSpan(
                      text:
                      '${formatNumber(medication.remainingQuantity / (medication.quantity / medication.reconstitutionVolume))}/${formatNumber(medication.reconstitutionVolume)} $reconVolumeUnit (reconstituted)',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
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
                style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Next Dose: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: schedule != null && dosages.isNotEmpty
                        ? '${formatNumber(dosages.first.totalDose)} ${dosages.first.doseUnit}${isInjection && medication.selectedReconstitution != null ? ' (${formatNumber(medication.selectedReconstitution!['syringeUnits'] ?? 0)} IU)' : ''} at ${schedule.time.format(context)}'
                        : 'None scheduled',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  context,
                  'Refill',
                  Icons.refresh,
                      () => Navigator.pushNamed(context, '/medication_form', arguments: medication),
                ),
                _buildActionButton(
                  context,
                  'Add Dosage',
                  Icons.add_circle,
                      () => Navigator.pushNamed(context, '/dosage_form', arguments: medication),
                ),
                _buildActionButton(
                  context,
                  'Add Schedule',
                  Icons.schedule,
                      () => Navigator.pushNamed(context, '/add_schedule', arguments: medication),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: AppConstants.primaryColor),
        label: Text(
          label,
          style: TextStyle(fontSize: 12, color: AppConstants.primaryColor),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        ),
      ),
    );
  }
}