// In lib/core/widgets/cards/dosage_card.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';

class DosageCard extends StatelessWidget {
  final Dosage dosage;
  final VoidCallback onTap;

  const DosageCard({super.key, required this.dosage, required this.onTap});

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: AppConstants.cardDecoration.copyWith(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dosage.name,
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatNumber(dosage.totalDose)} ${dosage.doseUnit} (${dosage.method.displayName})',
                  style: AppConstants.cardBodyStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
            Icon(Icons.edit, size: 20, color: AppConstants.primaryColor),
          ],
        ),
      ),
    );
  }
}