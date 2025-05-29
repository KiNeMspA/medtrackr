// lib/features/medication/ui/widgets/reconstitution_widgets.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';

class ReconstitutionWidgets extends StatelessWidget {
  final bool isReconstituting;
  final TextEditingController reconstitutionFluidController;
  final TextEditingController targetDoseController;
  final String targetDoseUnit;
  final List<Map<String, dynamic>> reconstitutionSuggestions;
  final Map<String, dynamic>? selectedReconstitution;
  final double totalAmount;
  final double targetDose;
  final String medicationName;
  final String quantityUnit;
  final String? reconstitutionError;
  final ValueChanged<bool> onReconstitutingChanged;
  final VoidCallback onFluidChanged;
  final VoidCallback onTargetDoseChanged;
  final ValueChanged<String?> onTargetDoseUnitChanged;
  final ValueChanged<Map<String, dynamic>> onSuggestionSelected;
  final ValueChanged<Map<String, dynamic>> onEditReconstitution;
  final VoidCallback onClearReconstitution;
  final ValueChanged<double> onAdjustVolume;
  final bool isDark;

  const ReconstitutionWidgets({
    super.key,
    required this.isReconstituting,
    required this.reconstitutionFluidController,
    required this.targetDoseController,
    required this.targetDoseUnit,
    required this.reconstitutionSuggestions,
    required this.selectedReconstitution,
    required this.totalAmount,
    required this.targetDose,
    required this.medicationName,
    required this.quantityUnit,
    this.reconstitutionError,
    required this.onReconstitutingChanged,
    required this.onFluidChanged,
    required this.onTargetDoseChanged,
    required this.onTargetDoseUnitChanged,
    required this.onSuggestionSelected,
    required this.onEditReconstitution,
    required this.onClearReconstitution,
    required this.onAdjustVolume,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppConstants.cardColor(isDark),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reconstitution Settings',
              style: AppThemes.reconstitutionTitleStyle(isDark),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: reconstitutionFluidController,
              decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                labelText: 'Reconstitution Fluid',
              ),
              validator: Validators.required,
              onChanged: (value) => onFluidChanged(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: targetDoseController,
                    decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                      labelText: 'Target Dose',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => Validators.positiveNumber(value, 'Target Dose'),
                    onChanged: (value) => onTargetDoseChanged(),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    value: targetDoseUnit,
                    decoration: AppConstants.formFieldDecoration(isDark).copyWith(),
                    items: ['g', 'mg', 'mcg', 'mL', 'IU', 'unit']
                        .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit, style: const TextStyle(fontFamily: 'Poppins')),
                    ))
                        .toList(),
                    onChanged: onTargetDoseUnitChanged,
                    validator: (value) => value == null ? 'Please select a unit' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Medication Quantity: ${formatNumber(totalAmount)} $quantityUnit',
              style: AppThemes.cardBodyStyle(isDark),
            ),
            const SizedBox(height: 16),
            if (reconstitutionSuggestions.isNotEmpty && selectedReconstitution == null) ...[
              Text(
                'Suggested Reconstitutions',
                style: AppThemes.reconstitutionTitleStyle(isDark),
              ),
              const SizedBox(height: 8),
              ...reconstitutionSuggestions.take(4).map((suggestion) {
                return ListTile(
                  title: Text(
                    '${formatNumber(suggestion['volume'])} mL, ${formatNumber(suggestion['concentration'])} mg/mL',
                    style: AppThemes.cardBodyStyle(isDark),
                  ),
                  onTap: () => onSuggestionSelected(suggestion),
                );
              }),
            ],
            if (selectedReconstitution != null) ...[
              Text(
                'Selected Reconstitution',
                style: AppThemes.reconstitutionTitleStyle(isDark),
              ),
              const SizedBox(height: 8),
              ListTile(
                title: Text(
                  '${formatNumber(selectedReconstitution!['volume'])} mL, ${formatNumber(selectedReconstitution!['concentration'])} mg/mL',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppConstants.primaryColor),
                      onPressed: () => onEditReconstitution(selectedReconstitution!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                      onPressed: () => onAdjustVolume(0.1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, color: AppConstants.primaryColor),
                      onPressed: () => onAdjustVolume(-0.1),
                    ),
                  ],
                ),
              ),
            ],
            if (reconstitutionError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  reconstitutionError!,
                  style: AppThemes.reconstitutionErrorStyle(isDark),
                ),
              ),
            const SizedBox(height: 16),
            if (selectedReconstitution != null)
              ElevatedButton(
                onPressed: onClearReconstitution,
                style: AppConstants.deleteButtonStyle(),
                child: const Text('Clear Reconstitution', style: TextStyle(fontFamily: 'Poppins')),
              ),
          ],
        ),
      ),
    );
  }
}