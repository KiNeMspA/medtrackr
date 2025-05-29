// lib/core/widgets/dose_input_row.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/validators.dart';

class DoseInputRow extends StatelessWidget {
  final MedicationType type;
  final TextEditingController doseController;
  final QuantityUnit doseUnit;
  final ValueChanged<QuantityUnit?> onUnitChanged;
  final FormFieldValidator<QuantityUnit> validator;
  final bool isDark;

  const DoseInputRow({
    super.key,
    required this.type,
    required this.doseController,
    required this.doseUnit,
    required this.onUnitChanged,
    required this.validator,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: doseController,
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
              labelText: type == MedicationType.tablet ? 'Dose per Tablet' : 'Dose per Capsule',
              labelStyle: AppThemes.formLabelStyle(isDark),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.positiveNumber(value, 'Dose'),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<QuantityUnit>(
            value: doseUnit,
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
              labelText: 'Unit',
              labelStyle: AppThemes.formLabelStyle(isDark),
            ),
            items: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg]
                .map((unit) => DropdownMenuItem<QuantityUnit>(
              value: unit,
              child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Inter')),
            ))
                .toList(),
            onChanged: onUnitChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }
}