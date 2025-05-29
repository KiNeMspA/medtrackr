// lib/core/widgets/medication_form_fields.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';

class MedicationFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController dosePerTabletController;
  final TextEditingController dosePerCapsuleController;
  final TextEditingController notesController;
  final MedicationType type;
  final QuantityUnit quantityUnit;
  final QuantityUnit dosePerTabletUnit;
  final QuantityUnit dosePerCapsuleUnit;
  final ValueChanged<MedicationType?> onTypeChanged;
  final ValueChanged<QuantityUnit?> onQuantityUnitChanged;
  final ValueChanged<QuantityUnit?> onDosePerTabletUnitChanged;
  final ValueChanged<QuantityUnit?> onDosePerCapsuleUnitChanged;
  final bool isDark;

  const MedicationFormFields({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.dosePerTabletController,
    required this.dosePerCapsuleController,
    required this.notesController,
    required this.type,
    required this.quantityUnit,
    required this.dosePerTabletUnit,
    required this.dosePerCapsuleUnit,
    required this.onTypeChanged,
    required this.onQuantityUnitChanged,
    required this.onDosePerTabletUnitChanged,
    required this.onDosePerCapsuleUnitChanged,
    required this.isDark,
  });

  static const Map<MedicationType, List<QuantityUnit>> _quantityUnits = {
    MedicationType.tablet: [QuantityUnit.tablets],
    MedicationType.capsule: [QuantityUnit.tablets],
    MedicationType.injection: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg, QuantityUnit.mL],
    MedicationType.other: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg, QuantityUnit.mL],
  };

  static const Map<MedicationType, List<QuantityUnit>> _doseUnits = {
    MedicationType.tablet: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg],
    MedicationType.capsule: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg],
    MedicationType.injection: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg, QuantityUnit.iu, QuantityUnit.unit],
    MedicationType.other: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg, QuantityUnit.unit],
  };

  @override
  Widget build(BuildContext context) {
    final isTabletOrCapsule = type == MedicationType.tablet || type == MedicationType.capsule;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Medication Name',
            labelStyle: AppThemes.formLabelStyle(isDark),
          ),
          validator: Validators.required,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<MedicationType>(
          value: type,
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Type',
            labelStyle: AppThemes.formLabelStyle(isDark),
          ),
          items: MedicationType.values
              .map((type) => DropdownMenuItem(
            value: type,
            child: Text(type.displayName, style: const TextStyle(fontFamily: 'Poppins')),
          ))
              .toList(),
          onChanged: onTypeChanged,
          validator: (value) => value == null ? 'Please select a type' : null,
        ),
        const SizedBox(height: 16),
        Row(
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
                value: isTabletOrCapsule ? QuantityUnit.tablets : quantityUnit,
                decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                  labelText: 'Unit',
                  labelStyle: AppThemes.formLabelStyle(isDark),
                ),
                items: _quantityUnits[type]!
                    .map((unit) => DropdownMenuItem<QuantityUnit>(
                  value: unit,
                  child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Poppins')),
                ))
                    .toList(),
                onChanged: onQuantityUnitChanged,
                validator: (value) => value == null ? 'Please select a unit' : null,
              ),
            ),
          ],
        ),
        if (isTabletOrCapsule) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: type == MedicationType.tablet ? dosePerTabletController : dosePerCapsuleController,
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
                  value: type == MedicationType.tablet ? dosePerTabletUnit : dosePerCapsuleUnit,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Unit',
                    labelStyle: AppThemes.formLabelStyle(isDark),
                  ),
                  items: _doseUnits[type]!
                      .map((unit) => DropdownMenuItem<QuantityUnit>(
                    value: unit,
                    child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Poppins')),
                  ))
                      .toList(),
                  onChanged: type == MedicationType.tablet ? onDosePerTabletUnitChanged : onDosePerCapsuleUnitChanged,
                  validator: (value) => value == null ? 'Please select a unit' : null,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Notes (Optional)',
            labelStyle: AppThemes.formLabelStyle(isDark),
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}