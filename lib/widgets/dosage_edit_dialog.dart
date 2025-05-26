import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/widgets/dosage_form_fields.dart';
import 'package:medtrackr/models/dosage_method.dart';

class DosageEditDialog extends StatefulWidget {
  final Dosage dosage;
  final Function(Dosage) onSave;

  const DosageEditDialog({super.key, required this.dosage, required this.onSave});

  @override
  _DosageEditDialogState createState() => _DosageEditDialogState();
}

class _DosageEditDialogState extends State<DosageEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _volumeController;
  late TextEditingController _insulinUnitsController;
  late String _doseUnit;
  late DosageMethod _method;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dosage.name);
    _doseController = TextEditingController(text: widget.dosage.totalDose.toString());
    _volumeController = TextEditingController(text: widget.dosage.volume.toString());
    _insulinUnitsController = TextEditingController(text: widget.dosage.insulinUnits.toString());
    _doseUnit = widget.dosage.doseUnit;
    _method = widget.dosage.method;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _volumeController.dispose();
    _insulinUnitsController.dispose();
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
          doseController: _doseController,
          volumeController: _volumeController,
          insulinUnitsController: _insulinUnitsController,
          doseUnit: _doseUnit,
          method: _method,
          onDoseUnitChanged: (value) => setState(() => _doseUnit = value!),
          onMethodChanged: (value) => setState(() => _method = value!),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedDosage = widget.dosage.copyWith(
              name: _nameController.text,
              doseUnit: _doseUnit,
              totalDose: double.tryParse(_doseController.text) ?? widget.dosage.totalDose,
              volume: double.tryParse(_volumeController.text) ?? widget.dosage.volume,
              insulinUnits: double.tryParse(_insulinUnitsController.text) ?? widget.dosage.insulinUnits,
              method: _method,
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