// lib/core/widgets/dosage_card.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';

class DosageCard extends StatelessWidget {
  final Dosage dosage;
  final VoidCallback onTap;
  final bool isDark;

  const DosageCard({
    super.key,
    required this.dosage,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: AppConstants.cardDecoration(isDark).copyWith(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2,
              offset: const Offset(0, 1),
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
                  style: AppConstants.cardTitleStyle(isDark).copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatNumber(dosage.totalDose)} ${dosage.doseUnit} (${dosage.method.displayName})',
                  style: AppConstants.cardBodyStyle(isDark).copyWith(fontSize: 12),
                ),
                if (dosage.takenTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Taken: ${formatDateTime(dosage.takenTime!)}',
                    style: AppConstants.secondaryTextStyle(isDark),
                  ),
                ],
              ],
            ),
            Icon(Icons.edit, size: 20, color: AppConstants.primaryColor),
          ],
        ),
      ),
    );
  }
}