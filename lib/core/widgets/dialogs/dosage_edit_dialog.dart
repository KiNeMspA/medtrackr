// In lib/core/widgets/dialogs/dosage_edit_dialog.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/core/widgets/forms/dosage_form_fields.dart';


class DosageEditDialog extends StatefulWidget {
  final Dosage dosage;
  final Function(Dosage) onSave;
  final bool isInjection;
  final bool isTabletOrCapsule;
  final bool isReconstituted;

  const DosageEditDialog({
    super.key,
    required this.dosage,
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
  late SyringeSize? _syringeSize;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dosage.name);
    _doseController = TextEditingController(text: widget.dosage.totalDose.toString());
    _tabletCountController = TextEditingController(
        text: widget.isTabletOrCapsule ? widget.dosage.totalDose.toInt().toString() : '');
    _doseUnit = widget.dosage.doseUnit;
    _method = widget.dosage.method;
    _syringeSize = widget.dosage.syringeSize;
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
      backgroundColor: Colors.grey[50],
      title: const Text('Edit Dosage'),
      content: SingleChildScrollView(
        child: DosageFormFields(
          nameController: _nameController,
          amountController: _doseController,
          tabletCountController: _tabletCountController,
          doseUnit: _doseUnit,
          method: _method,
          syringeSize: _syringeSize,
          isInjection: widget.isInjection,
          isTabletOrCapsule: widget.isTabletOrCapsule,
          isReconstituted: widget.isReconstituted,
          onDoseUnitChanged: (value) => setState(() => _doseUnit = value!),
          onMethodChanged: (value) => setState(() => _method = value!),
          onSyringeSizeChanged: (value) => setState(() => _syringeSize = value),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final amount = widget.isTabletOrCapsule
                ? double.tryParse(_tabletCountController.text) ?? widget.dosage.totalDose
                : double.tryParse(_doseController.text) ?? widget.dosage.totalDose;
            final updatedDosage = widget.dosage.copyWith(
              name: _nameController.text,
              doseUnit: _doseUnit,
              totalDose: amount,
              volume: widget.isInjection
                  ? (widget.isReconstituted && widget.dosage.selectedReconstitution != null
                  ? amount / (widget.dosage.selectedReconstitution!['concentration']?.toDouble() ?? 1.0)
                  : amount)
                  : 0.0,
              insulinUnits: widget.isReconstituted && widget.dosage.selectedReconstitution != null
                  ? (widget.dosage.selectedReconstitution!['syringeUnits'] as num?)?.toDouble() ?? 0.0
                  : 0.0,
              method: _method,
              syringeSize: _syringeSize,
            );
            widget.onSave(updatedDosage);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}