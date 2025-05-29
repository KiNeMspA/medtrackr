// lib/core/widgets/quantity_input_row.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/validators.dart';

class QuantityInputRow extends StatelessWidget {
  final TextEditingController quantityController;
  final MedicationType? type;
  final QuantityUnit quantityUnit;
  final ValueChanged<QuantityUnit?> onUnitChanged;
  final FormFieldValidator<QuantityUnit> validator;
  final bool isDark;

  const QuantityInputRow({
    super.key,
    required this.quantityController,
    required this.type,
    required this.quantityUnit,
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
            controller: quantityController,
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
              labelText: 'Quantity',
              labelStyle: AppThemes.formLabelStyle(isDark),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.positiveNumber(value, 'Quantity'),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: DropdownButtonFormField<QuantityUnit>(
            value: (type == MedicationType.tablet || type == MedicationType.capsule) ? QuantityUnit.tablets : quantityUnit,
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
              labelText: 'Unit',
              labelStyle: AppThemes.formLabelStyle(isDark),
            ),
            items: (type == MedicationType.tablet || type == MedicationType.capsule)
                ? [QuantityUnit.tablets]
                .map((unit) => DropdownMenuItem<QuantityUnit>(
              value: unit,
              child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Inter')),
            ))
                .toList()
                : [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg, QuantityUnit.mL]
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