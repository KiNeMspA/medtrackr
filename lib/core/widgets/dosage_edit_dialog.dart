// lib/core/widgets/dosage_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/core/widgets/dosage_form_fields.dart';
import 'package:medtrackr/features/medication/models/medication.dart';

class DosageEditDialog extends StatefulWidget {
  final Dosage dosage;
  final Medication medication;
  final Function(Dosage) onSave;
  final bool isInjection;
  final bool isTabletOrCapsule;
  final bool isReconstituted;

  const DosageEditDialog({
    super.key,
    required this.dosage,
    required this.medication,
    required this.onSave,
    required this.isInjection,
    required this.isTabletOrCapsule,
    required this.isReconstituted,
  });

  @override
  _DosageEditDialogState createState() => _DosageEditDialogState();
}

class _DosageEditDialogState extends State<DosageEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _tabletCountController;
  late String _doseUnit;
  late DosageMethod _method;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dosage.name);
    _doseController = TextEditingController(text: widget.dosage.totalDose.toString());
    _tabletCountController = TextEditingController(
        text: widget.isTabletOrCapsule ? widget.dosage.totalDose.toInt().toString() : '');
    _doseUnit = widget.dosage.doseUnit;
    _method = widget.dosage.method;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _tabletCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.backgroundColor,
      title: const Text('Edit Dosage'),
      content: SingleChildScrollView(
        child: DosageFormFields(
          nameController: _nameController,
          amountController: _doseController,
          tabletCountController: _tabletCountController,
          iuController: TextEditingController(), // Placeholder for IU input
          doseUnit: _doseUnit,
          method: _method,
          syringeSize: null, // Not stored in Dosage model
          isInjection: widget.isInjection,
          isTabletOrCapsule: widget.isTabletOrCapsule,
          isReconstituted: widget.isReconstituted,
          medication: Medication(
            id: widget.dosage.medicationId,
            name: '',
            type: MedicationType.injection,
            quantityUnit: QuantityUnit.mg,
            quantity: 0,
            remainingQuantity: 0,
            reconstitutionVolumeUnit: '',
            reconstitutionVolume: 0,
            reconstitutionFluid: '',
            notes: '',
          ),
          onDoseUnitChanged: (value) => setState(() => _doseUnit = value ?? _doseUnit),
          onMethodChanged: (value) => setState(() => _method = value ?? _method),
          onSyringeSizeChanged: (_) {}, // No-op, syringeSize not used
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = widget.isTabletOrCapsule
                ? double.tryParse(_tabletCountController.text) ?? widget.dosage.totalDose
                : double.tryParse(_doseController.text) ?? widget.dosage.totalDose;
            final updatedDosage = widget.dosage.copyWith(
              name: _nameController.text,
              doseUnit: _doseUnit,
              totalDose: amount,
              volume: widget.isInjection
                  ? (widget.isReconstituted && widget.medication.selectedReconstitution != null
                  ? amount / (widget.medication.selectedReconstitution!['concentration']?.toDouble() ?? 1.0)
                  : amount)
                  : 0.0,
              insulinUnits: widget.isReconstituted && widget.medication.selectedReconstitution != null
                  ? (widget.medication.selectedReconstitution!['syringeUnits'] as num?)?.toDouble() ?? 0.0
                  : 0.0,
              method: _method,
            );
            widget.onSave(updatedDosage);
            Navigator.pop(context);
          },
          style: AppConstants.dialogButtonStyle,
          child: const Text('Save'),
        ),
      ],
    );
  }
}