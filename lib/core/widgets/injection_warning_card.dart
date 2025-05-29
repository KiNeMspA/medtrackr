// lib/core/widgets/injection_warning_card.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class InjectionWarningCard extends StatelessWidget {
  final bool isDark;

  const InjectionWarningCard({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppConstants.infoCardDecoration(isDark),
      child: Text(
        'Note: If you plan to reconstitute, the volume will be updated automatically. Otherwise, a volume in mL will be required.',
        style: AppConstants.infoTextStyle(isDark),
      ),
    );
  }
}