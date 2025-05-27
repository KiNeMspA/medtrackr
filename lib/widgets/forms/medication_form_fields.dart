import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';
import 'package:medtrackr/models/enums/target_dose_unit.dart';

class MedicationFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final QuantityUnit quantityUnit;
  final MedicationType type;
  final TextEditingController notesController;
  final bool isReconstituting;
  final TextEditingController reconstitutionFluidController;
  final TextEditingController targetDoseController;
  final TargetDoseUnit targetDoseUnit;
  final List<Map<String, dynamic>> reconstitutionSuggestions;
  final Map<String, dynamic>? selectedReconstitution;
  final ValueChanged<String?> onNameChanged;
  final ValueChanged<MedicationType?> onTypeChanged;
  final ValueChanged<QuantityUnit?> onQuantityUnitChanged;
  final ValueChanged<TargetDoseUnit?> onTargetDoseUnitChanged;
  final ValueChanged<bool> onReconstitutingChanged;
  final VoidCallback onQuantityChanged;
  final VoidCallback onTargetDoseChanged;
  final VoidCallback onReconstitutionFluidChanged;
  final ValueChanged<Map<String, dynamic>> onSelectReconstitution;
  final ValueChanged<Map<String, dynamic>> onEditReconstitution;
  final VoidCallback onClearReconstitution;

  const MedicationFormFields({
    super.key,
    required this.nameController,
    required this.quantityController,
    required this.quantityUnit,
    required this.type,
    required this.notesController,
    required this.isReconstituting,
    required this.reconstitutionFluidController,
    required this.targetDoseController,
    required this.targetDoseUnit,
    required this.reconstitutionSuggestions,
    this.selectedReconstitution,
    required this.onNameChanged,
    required this.onTypeChanged,
    required this.onQuantityUnitChanged,
    required this.onTargetDoseUnitChanged,
    required this.onReconstitutingChanged,
    required this.onQuantityChanged,
    required this.onTargetDoseChanged,
    required this.onReconstitutionFluidChanged,
    required this.onSelectReconstitution,
    required this.onEditReconstitution,
    required this.onClearReconstitution,
  });

  @override
  Widget build(BuildContext context) {
    final quantityUnits = {
      MedicationType.tablet: [QuantityUnit.g, QuantityUnit.mg, QuantityUnit.mcg],
      MedicationType.capsule: [QuantityUnit.g, QuantityUnit.mg, QuantityUnit.mcg],
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: quantityController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: type == MedicationType.tablet || type == MedicationType.capsule
                      ? 'Total Units *'
                      : 'Quantity *',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value!.isEmpty ? 'Required' : null,
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
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Notes',
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Text(
              'Reconstitute this medication?',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Switch(
              value: isReconstituting,
              activeColor: AppConstants.primaryColor,
              onChanged: onReconstitutingChanged,
            ),
          ],
        ),
        if (isReconstituting) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: reconstitutionFluidController,
            decoration: AppConstants.formFieldDecoration.copyWith(
              labelText: 'Reconstitution Fluid (e.g., Saline, Water)',
            ),
            onChanged: (value) => onReconstitutionFluidChanged(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: targetDoseController,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Target Single Dosage *',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onChanged: (value) => onTargetDoseChanged(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<TargetDoseUnit>(
                  value: targetDoseUnit,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Unit',
                  ),
                  items: TargetDoseUnit.values
                      .map((unit) => DropdownMenuItem(value: unit, child: Text(unit.displayName)))
                      .toList(),
                  onChanged: onTargetDoseUnitChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (reconstitutionSuggestions.isNotEmpty && selectedReconstitution == null) ...[
            const Text(
              'Reconstitution Options:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...reconstitutionSuggestions.take(4).map((suggestion) => Card(
              decoration: AppConstants.cardDecoration,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Option: '),
                      TextSpan(
                        text: '${suggestion['volume']} mL',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const TextSpan(text: ' = '),
                      TextSpan(
                        text: '${suggestion['iu']} IU',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  'For ${suggestion['totalAmount']?.toInt() ?? 0} ${quantityUnit.displayName} at ${suggestion['targetDose']?.toInt() ?? 0} ${targetDoseUnit.displayName}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                  onPressed: () => onSelectReconstitution(suggestion),
                ),
              ),
            )),
          ],
          if (selectedReconstitution != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Selected Reconstitution:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              decoration: AppConstants.cardDecoration.copyWith(
                border: Border.fromBorderSide(BorderSide(color: Colors.green[900]!, width: 2)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[900]),
                    children: [
                      const TextSpan(text: 'Option: '),
                      TextSpan(
                        text: '${selectedReconstitution!['volume']} mL',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' = '),
                      TextSpan(
                        text: '${selectedReconstitution!['iu']} IU',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  'For ${selectedReconstitution!['totalAmount']?.toInt() ?? 0} ${quantityUnit.displayName} at ${selectedReconstitution!['targetDose']?.toInt() ?? 0} ${targetDoseUnit.displayName}\n'
                      'Fluid: ${reconstitutionFluidController.text.isNotEmpty ? reconstitutionFluidController.text : 'None'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green[900]),
                      onPressed: () => onEditReconstitution(selectedReconstitution!),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.green[900]),
                      onPressed: onClearReconstitution,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}