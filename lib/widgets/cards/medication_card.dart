import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;

  const MedicationCard({super.key, required this.medication});

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  String _formatFraction(double current, double total, String unit) {
    return '${_formatNumber(current)}/${_formatNumber(total)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final dosages = dataProvider.getDosagesForMedication(medication.id);
    final isReconstituted = medication.reconstitutionVolume > 0;
    final remainingFraction = _formatFraction(
      medication.remainingQuantity,
      medication.quantity,
      medication.quantityUnit.displayName,
    );
    final reconVolumeUnit = medication.reconstitutionVolumeUnit.isNotEmpty
        ? medication.reconstitutionVolumeUnit
        : 'mL';
    final reconRemaining = isReconstituted
        ? _formatFraction(
            medication.remainingQuantity /
                (medication.quantity / medication.reconstitutionVolume),
            medication.reconstitutionVolume,
            reconVolumeUnit,
          )
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/medication_form',
          arguments: medication,
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                  style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
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
              Consumer<DataProvider>(
                builder: (context, dataProvider, child) {
                  final schedule =
                      dataProvider.getScheduleForMedication(medication.id);
                  return RichText(
                    text: TextSpan(
                      style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
                      children: [
                        const TextSpan(
                          text: 'Next Dose: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: schedule != null && dosages.isNotEmpty
                              ? '${_formatNumber(dosages.first.totalDose)} ${dosages.first.doseUnit} at ${schedule.time.format(context)}'
                              : 'None scheduled',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            if (isReconstituted) ...[
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
                  children: [
                    const TextSpan(
                      text: 'Reconstituted with: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          '${_formatNumber(medication.reconstitutionVolume)} $reconVolumeUnit of ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'}',
                    ),
                  ],
                ),
              ),
              if (medication.selectedReconstitution != null &&
                  medication.selectedReconstitution!.isNotEmpty) ...[
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
                    children: [
                      const TextSpan(
                        text: 'Reference Dose: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '${_formatNumber(medication.selectedReconstitution?['syringeUnits']?.toDouble() ?? 0)} IU',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' contains '),
                      TextSpan(
                        text:
                            '${_formatNumber(medication.selectedReconstitution?['targetDose']?.toDouble() ?? 0)} ${medication.selectedReconstitution?['targetDoseUnit'] ?? 'mcg'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style:
                        AppConstants.secondaryTextStyle.copyWith(fontSize: 12),
                    children: [
                      const TextSpan(
                        text: 'Concentration: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            '${_formatNumber(medication.selectedReconstitution!['concentration'] ?? 0)} mg/mL',
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle.copyWith(fontSize: 14),
                children: [
                  const TextSpan(
                    text: 'Notes: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        medication.notes.isNotEmpty ? medication.notes : 'None',
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
