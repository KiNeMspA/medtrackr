import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:medtrackr/widgets/dosage_form_fields.dart';

class AddDosageScreen extends StatefulWidget {
  final Medication medication;
  final double? targetDoseMcg;
  final double? selectedIU;

  const AddDosageScreen({
    super.key,
    required this.medication,
    this.targetDoseMcg,
    this.selectedIU,
  });

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  final _nameController = TextEditingController();
  String _doseUnit = 'IU';
  final _doseController = TextEditingController();
  DosageMethod _method = DosageMethod.subcutaneous;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.medication.name} Dose';
    if (widget.selectedIU != null) {
      _doseController.text = widget.selectedIU!.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _saveDosage(BuildContext context) {
    if (_nameController.text.isEmpty || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final dosage = Dosage(
      id: const Uuid().v4(),
      medicationId: widget.medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: double.tryParse(_doseController.text) ?? 0,
      volume: 0.0,
      insulinUnits: double.tryParse(_doseController.text) ?? 0,
    );

    Provider.of<DataProvider>(context, listen: false).addDosage(dosage);
    Navigator.pop(context, dosage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Add Dosage for ${widget.medication.name}'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DosageFormFields(
              nameController: _nameController,
              doseController: _doseController,
              doseUnit: _doseUnit,
              method: _method,
              onDoseUnitChanged: (value) => setState(() => _doseUnit = value!),
              onMethodChanged: (value) => setState(() => _method = value!),
            ),
            if (widget.targetDoseMcg != null) ...[
              const SizedBox(height: 8),
              Text(
                'Target Dose: ${widget.targetDoseMcg!.toInt()} mcg',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveDosage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Dosage', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}