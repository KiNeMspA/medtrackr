import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';

class MedicationFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController tabletCountController;
  final TextEditingController volumeController;
  final TextEditingController notesController;
  final QuantityUnit quantityUnit;
  final MedicationType type;
  final ValueChanged<String?> onNameChanged;
  final ValueChanged<MedicationType?> onTypeChanged;
  final ValueChanged<QuantityUnit?> onQuantityUnitChanged;
  final VoidCallback onQuantityChanged;

  const MedicationFormFields({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.tabletCountController,
    required this.volumeController,
    required this.notesController,
    required this.quantityUnit,
    required this.type,
    required this.onNameChanged,
    required this.onTypeChanged,
    required this.onQuantityUnitChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final quantityUnits = {
      MedicationType.tablet: [QuantityUnit.tablets],
      MedicationType.capsule: [QuantityUnit.tablets],
      MedicationType.injection: [
        QuantityUnit.g,
        QuantityUnit.mg,
        QuantityUnit.mcg,
        QuantityUnit.mL,
        QuantityUnit.iu,
        QuantityUnit.unit,
      ],
      MedicationType.other: [
        QuantityUnit.g,
        QuantityUnit.mg,
        QuantityUnit.mcg,
        QuantityUnit.mL,
        QuantityUnit.iu,
        QuantityUnit.unit,
      ],
    }[type] ?? [QuantityUnit.g, QuantityUnit.mg, QuantityUnit.mcg];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Medication Name *',
          ),
          validator: (value) => value!.isEmpty ? 'Required' : null,
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<MedicationType>(
          value: type,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Type',
          ),
          items: MedicationType.values
              .map((type) => DropdownMenuItem(value: type, child: Text(type.displayName)))
              .toList(),
          onChanged: onTypeChanged,
          validator: (value) => value == null ? 'Please select a type' : null,
        ),
        const SizedBox(height: 16),
        if (type == MedicationType.tablet || type == MedicationType.capsule) ...[
          TextFormField(
            controller: tabletCountController,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Total Units (Tablets/Capsules) *',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter total units';
              if (double.tryParse(value) == null || double.parse(value)! <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
            onChanged: (value) => onQuantityChanged(),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: quantityController,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Quantity *',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a quantity';
                    if (double.tryParse(value) == null || double.parse(value)! <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                  onChanged: (value) => onQuantityChanged(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<QuantityUnit>(
                  value: quantityUnits.contains(quantityUnit) ? quantityUnit : quantityUnits.first,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Unit',
                  ),
                  items: quantityUnits
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit.displayName)))
                      .toList(),
                  onChanged: onQuantityUnitChanged,
                  validator: (value) => value == null ? 'Please select a unit' : null,
                ),
              ),
            ],
          ),
          if (quantityUnit == QuantityUnit.mL && type == MedicationType.injection) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: volumeController,
              decoration: AppConstants.formFieldDecoration.copyWith(
                labelText: 'Total Volume (mL) *',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Please enter a volume';
                if (double.tryParse(value) == null || double.parse(value)! <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
              onChanged: (value) => onQuantityChanged(),
            ),
          ],
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Notes',
          ),
          maxLines: 3,
        ),
      ],
    );
  }
}