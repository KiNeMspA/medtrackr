import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/enums.dart';

class DosageFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController tabletCountController;
  final String doseUnit;
  final DosageMethod method;
  final SyringeSize? syringeSize;
  final bool isInjection;
  final bool isTabletOrCapsule;
  final bool isReconstituted;
  final ValueChanged<String?> onDoseUnitChanged;
  final ValueChanged<DosageMethod?> onMethodChanged;
  final ValueChanged<SyringeSize?> onSyringeSizeChanged;

  const DosageFormFields({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.tabletCountController,
    required this.doseUnit,
    required this.method,
    required this.syringeSize,
    required this.isInjection,
    required this.isTabletOrCapsule,
    required this.isReconstituted,
    required this.onDoseUnitChanged,
    required this.onMethodChanged,
    required this.onSyringeSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Dosage Name',
          ),
          validator: (value) =>
          value == null || value.isEmpty ? 'Please enter a name' : null,
        ),
        const SizedBox(height: 16),
        if (isTabletOrCapsule) ...[
          TextFormField(
            controller: tabletCountController,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Number of Tablets/Capsules',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of tablets';
              }
              if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: doseUnit,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Dose per Tablet',
            ),
            items: ['mg', 'mcg']
                .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                .toList(),
            onChanged: onDoseUnitChanged,
            validator: (value) => value == null ? 'Please select a unit' : null,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: amountController,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Dosage Amount',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null || double.parse(value)! <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                  enabled: !isReconstituted,
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  value: doseUnit,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Unit',
                  ),
                  items: ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit']
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                      .toList(),
                  onChanged: isReconstituted ? null : onDoseUnitChanged,
                  validator: (value) => value == null ? 'Please select a unit' : null,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        DropdownButtonFormField<DosageMethod>(
          value: method,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Dosage Method',
          ),
          items: DosageMethod.values
              .map((method) => DropdownMenuItem(
            value: method,
            child: Text(method.displayName),
          ))
              .toList(),
          onChanged: onMethodChanged,
          validator: (value) => value == null ? 'Please select a method' : null,
        ),
        if (isInjection &&
            [DosageMethod.subcutaneous, DosageMethod.intramuscular, DosageMethod.intravenous]
                .contains(method)) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<SyringeSize>(
            value: syringeSize,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Syringe Size',
            ),
            items: SyringeSize.values
                .map((size) => DropdownMenuItem(
              value: size,
              child: Text(size.displayName),
            ))
                .toList(),
            onChanged: onSyringeSizeChanged,
            validator: (value) => value == null ? 'Please select a syringe size' : null,
          ),
        ],
      ],
    );
  }
}