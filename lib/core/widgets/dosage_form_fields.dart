// lib/core/widgets/dosage_form_fields.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
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
  final bool isDark;

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
    required this.isDark,
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
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Dosage Name',
          ),
          validator: Validators.required,
        ),
        const SizedBox(height: 16),
        if (isTabletOrCapsule) ...[
          TextFormField(
            controller: tabletCountController,
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
              labelText: medication.type == MedicationType.tablet ? 'Number of Tablets' : 'Number of Capsules',
              labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: AppConstants.textSecondary(isDark)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, color: AppConstants.primaryColor),
                    onPressed: () {
                      final current = double.tryParse(tabletCountController.text) ?? 0.0;
                      final newValue = (current - 1).clamp(0.0, double.infinity);
                      tabletCountController.text = formatNumber(newValue);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                    onPressed: () {
                      final current = double.tryParse(tabletCountController.text) ?? 0.0;
                      final newValue = current + 1;
                      tabletCountController.text = formatNumber(newValue);
                    },
                  ),
                ],
              ),
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.positiveNumber(value, 'Number'),
          ),
          const SizedBox(height: 16),
          Text(
            'Total Dose: ${(double.tryParse(tabletCountController.text) ?? 0) * (medication.dosePerTablet ?? 0)} $doseUnit',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: AppConstants.textSecondary(isDark)),
          ),
        ] else if (isInjection && isReconstituted) ...[
          TextFormField(
            controller: iuController,
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
              labelText: 'Dosage Amount (IU)',
            ),
            keyboardType: TextInputType.number,
            validator: (value) => Validators.positiveNumber(value, 'IU Amount'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: mcgValue > 0 ? formatNumber(mcgValue) : '',
            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
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
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Dosage Amount',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => Validators.positiveNumber(value, 'Amount'),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  value: doseUnit,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Unit',
                    labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: AppConstants.textSecondary(isDark)),
                  ),
                  items: ['mg', 'g', 'mcg', 'mL', 'IU', 'unit']
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit, style: const TextStyle(fontFamily: 'Poppins'))))
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
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Dosage Method',
            labelStyle: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w500, color: AppConstants.textSecondary(isDark)),
          ),
          items: (isTabletOrCapsule ? [DosageMethod.oral, DosageMethod.other] : DosageMethod.values)
              .map((method) => DropdownMenuItem(
            value: method,
            child: Text(method.displayName, style: const TextStyle(fontFamily: 'Poppins')),
          ))
              .toList(),
          onChanged: onMethodChanged,
          validator: (value) => value == null ? 'Please select a method' : null,
        ),
      ],
    );
  }
}