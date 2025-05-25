import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/widgets/dosage_form_fields.dart';

class DosageEditDialog extends StatefulWidget {
  final Dosage dosage;
  final Function(Dosage) onSave;

  const DosageEditDialog({super.key, required this.dosage, required this.onSave});

  @override
  _DosageEditDialogState createState() => _DosageEditDialogState();
}

class _DosageEditDialogState extends State<DosageEditDialog> {
  late TextEditingController _nameController;
  late String _doseUnit;
  late TextEditingController _doseController;
  late DosageMethod _method;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dosage.name);
    _doseUnit = widget.dosage.doseUnit;
    _doseController = TextEditingController(text: widget.dosage.totalDose.toString());
    _method = widget.dosage.method;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
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
              insulinUnits:
              double.tryParse(_doseController.text) ?? widget.dosage.insulinUnits,
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