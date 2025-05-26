import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:medtrackr/widgets/dosage_form_fields.dart';
import 'package:medtrackr/models/dosage_method.dart';



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
  final _doseController = TextEditingController();
  final _volumeController = TextEditingController();
  final _insulinUnitsController = TextEditingController();
  String _doseUnit = 'IU';
  DosageMethod _method = DosageMethod.subcutaneous;

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.medication.name} Dose';
    if (widget.selectedIU != null) {
      _insulinUnitsController.text = widget.selectedIU!.toString();
    }
    if (widget.targetDoseMcg != null) {
      _doseController.text = widget.targetDoseMcg!.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _volumeController.dispose();
    _insulinUnitsController.dispose();
    super.dispose();
  }

  void _saveDosage(BuildContext context) async {
    if (_nameController.text.isEmpty || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (widget.medication.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid medication ID')),
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
      volume: _volumeController.text.isNotEmpty ? double.tryParse(_volumeController.text) ?? 0 : 0,
      insulinUnits: _insulinUnitsController.text.isNotEmpty ? double.tryParse(_insulinUnitsController.text) ?? 0 : (widget.selectedIU ?? 0),
    );

    try {
      print('Saving dosage: $dosage');
      await Provider.of<DataProvider>(context, listen: false).addDosageAsync(dosage);
      print('Navigating back');
      if (context.mounted) {
        Navigator.pop(context, dosage);
      }
    } catch (e) {
      print('Error saving dosage: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving dosage: $e')),
        );
      }
    }
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
              volumeController: _volumeController,
              insulinUnitsController: _insulinUnitsController,
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