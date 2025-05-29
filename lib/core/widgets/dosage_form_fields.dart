// lib/core/widgets/dosage_form_fields.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/features/medication/models/medication.dart';


class DosageFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController tabletCountController;
  final TextEditingController iuController;
  final String doseUnit;
  final DosageMethod method;
  final SyringeSize? syringeSize;
  final bool isInjection;
  final bool isTabletOrCapsule;
  final bool isReconstituted;
  final Medication medication;
  final ValueChanged<String?> onDoseUnitChanged;
  final ValueChanged<DosageMethod?> onMethodChanged;
  final ValueChanged<SyringeSize?> onSyringeSizeChanged;

  const DosageFormFields({
    super.key,
    required this.nameController,
    required this.amountController,
    required this.tabletCountController,
    required this.iuController,
    required this.doseUnit,
    required this.method,
    required this.syringeSize,
    required this.isInjection,
    required this.isTabletOrCapsule,
    required this.isReconstituted,
    required this.medication,
    required this.onDoseUnitChanged,
    required this.onMethodChanged,
    required this.onSyringeSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final concentration = medication.selectedReconstitution?['concentration']?.toDouble() ?? 1.0;
    final iuValue = double.tryParse(iuController.text) ?? 0.0;
    final mcgValue = isReconstituted ? iuValue * concentration / 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Dosage Name',
          ),
          validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
        ),
        const SizedBox(height: 16),
        if (isTabletOrCapsule) ...[
          TextFormField(
            controller: tabletCountController,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: isTabletOrCapsule
                  ? (medication.type == MedicationType.tablet ? 'Number of Tablets' : 'Number of Capsules')
                  : null,
              labelStyle: AppThemes.formLabelStyle,
              suffixIcon: isTabletOrCapsule
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final current = double.tryParse(tabletCountController.text) ?? 0.0;
                      final newValue = (current - 1).clamp(0.0, double.infinity);
                      tabletCountController.text = formatNumber(newValue);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final current = double.tryParse(tabletCountController.text) ?? 0.0;
                      final newValue = current + 1;
                      tabletCountController.text = formatNumber(newValue);
                    },
                  ),
                ],
              )
                  : null,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (isTabletOrCapsule && (value == null || value.isEmpty)) return 'Please enter the number';
              if (isTabletOrCapsule && (double.tryParse(value!) == null || double.parse(value)! <= 0)) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Total Dose: ${(double.tryParse(tabletCountController.text) ?? 0) * (medication.dosePerTablet ?? 0)} $doseUnit',
            style: const TextStyle(color: Colors.grey),
          ),
        ] else if (isInjection && isReconstituted) ...[
          TextFormField(
            controller: iuController,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Dosage Amount (IU)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter an IU amount';
              if (double.tryParse(value) == null || double.parse(value)! <= 0) {
                return 'Please enter a valid positive number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: mcgValue > 0 ? mcgValue.toStringAsFixed(2) : '',
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Equivalent (mcg)',
            ),
            enabled: false,
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
                    if (value == null || value.isEmpty) return 'Please enter an amount';
                    if (double.tryParse(value) == null || double.parse(value)! <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
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
                  onChanged: onDoseUnitChanged,
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
              .map((method) => DropdownMenuItem(value: method, child: Text(method.displayName)))
              .toList(),
          onChanged: onMethodChanged,
          validator: (value) => value == null ? 'Please select a method' : null,
        ),
        if (isInjection && [DosageMethod.subcutaneous].contains(method)) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<DosageMethod>(
            value: method,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Dosage Method',
              labelStyle: AppThemes.formLabelStyle,
            ),
            items: (isTabletOrCapsule ? [DosageMethod.oral] : DosageMethod.values)
                .map((method) => DropdownMenuItem(value: method, child: Text(method.displayName)))
                .toList(),
            onChanged: onMethodChanged,
            validator: (value) => value == null ? 'Please select a method' : null,
          ),
        ],
      ],
    );
  }
}