import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';
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
        decoration: AppConstants.prominentCardDecoration,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle,
                children: [
                  const TextSpan(
                    text: 'Type: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: medication.type.displayName),
                ],
              ),
            ),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle,
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
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle,
                  children: [
                    const TextSpan(
                      text: 'Method: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: dosages.first.method.displayName),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle,
                  children: [
                    const TextSpan(
                      text: 'Next Dose: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: dosages.isNotEmpty
                          ? '${_formatNumber(dosages.first.totalDose)} ${dosages.first.doseUnit}'
                          : 'None scheduled',
                    ),
                  ],
                ),
              ),
            ],
            if (isReconstituted) ...[
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: AppConstants.cardBodyStyle,
                  children: [
                    const TextSpan(
                      text: 'Reconstituted with: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: '${_formatNumber(medication.reconstitutionVolume)} $reconVolumeUnit of ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'}',
                    ),
                  ],
                ),
              ),
              if (medication.selectedReconstitution != null && medication.selectedReconstitution!.isNotEmpty) ...[
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: AppConstants.cardBodyStyle,
                    children: [
                      const TextSpan(
                        text: 'Initial Dose: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${_formatNumber(medication.selectedReconstitution!['syringeUnits'] ?? 0)} IU ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: 'for a '),
                      TextSpan(
                        text: '${_formatNumber(medication.selectedReconstitution!['targetDose'] ?? 0)} ${medication.selectedReconstitution!['targetDoseUnit'] ?? 'mcg'} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: 'dose using '),
                      TextSpan(
                        text: '${_formatNumber(medication.selectedReconstitution!['volume'] ?? 0)} mL ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: 'volume.'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RichText(
                  text: TextSpan(
                    style: AppConstants.secondaryTextStyle,
                    children: [
                      const TextSpan(
                        text: 'Concentration: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${_formatNumber(medication.selectedReconstitution!['concentration'] ?? 0)} mg/mL',
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: AppConstants.cardBodyStyle,
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}