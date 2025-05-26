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
  final Dosage? dosage;
  final double? targetDoseMcg;
  final double? selectedIU;

  const AddDosageScreen({
    super.key,
    required this.medication,
    this.dosage,
    this.targetDoseMcg,
    this.selectedIU,
  });

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  final _nameController = TextEditingController();
  final _doseController = TextEditingController();
  final _insulinUnitsController = TextEditingController();
  String _doseUnit = 'mcg';
  DosageMethod _method = DosageMethod.subcutaneous;
  bool _isReconstituted = false;

  @override
  void initState() {
    super.initState();
    _isReconstituted = widget.medication.reconstitutionVolume > 0;
    _doseUnit = _isReconstituted ? widget.medication.quantityUnit : widget.medication.quantityUnit;
    if (widget.dosage != null) {
      _nameController.text = widget.dosage!.name;
      _doseController.text = widget.dosage!.totalDose.toStringAsFixed(widget.dosage!.totalDose % 1 == 0 ? 0 : 1);
      _insulinUnitsController.text = widget.dosage!.insulinUnits.toStringAsFixed(widget.dosage!.insulinUnits % 1 == 0 ? 0 : 1);
      _method = widget.dosage!.method;
      _doseUnit = widget.dosage!.doseUnit;
    } else {
      _nameController.text = _isReconstituted
          ? '${widget.medication.name} Dose 1'
          : '${widget.medication.name} Dose of ${widget.targetDoseMcg?.toStringAsFixed(widget.targetDoseMcg! % 1 == 0 ? 0 : 1) ?? '0'} ${widget.medication.quantityUnit}';
      _doseController.text = widget.targetDoseMcg?.toStringAsFixed(widget.targetDoseMcg! % 1 == 0 ? 0 : 1) ?? '';
      _insulinUnitsController.text = widget.selectedIU?.toStringAsFixed(widget.selectedIU! % 1 == 0 ? 0 : 1) ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
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
      id: widget.dosage?.id ?? const Uuid().v4(),
      medicationId: widget.medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: double.tryParse(_doseController.text) ?? 0,
      volume: 0,
      insulinUnits: _insulinUnitsController.text.isNotEmpty ? double.tryParse(_insulinUnitsController.text) ?? 0 : (widget.selectedIU ?? 0),
      takenTime: null,
    );

    try {
      print('Saving dosage: $dosage');
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      if (widget.dosage == null) {
        await dataProvider.addDosageAsync(dosage);
      } else {
        await dataProvider.updateDosageAsync(dosage.id, dosage);
      }
      print('Navigating back from AddDosageScreen');
      if (context.mounted && Navigator.canPop(context)) {
        await Future.delayed(const Duration(milliseconds: 200));
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
    final doseUnits = _isReconstituted
        ? [widget.medication.quantityUnit]
        : ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit'];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.dosage == null ? 'Add Dosage' : 'Edit Dosage'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DosageFormFields(
                nameController: _nameController,
                doseController: _doseController,
                volumeController: null,
                insulinUnitsController: _insulinUnitsController,
                doseUnit: _doseUnit,
                doseUnits: doseUnits,
                method: _method,
                onDoseUnitChanged: (value) => setState(() => _doseUnit = value!),
                onMethodChanged: (value) => setState(() => _method = value!),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dosage Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text('Medication: ${widget.medication.name}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('Dose: ${_doseController.text.isEmpty ? '0' : _doseController.text} $_doseUnit', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      Text(
                        'Method: ${_method == DosageMethod.subcutaneous ? 'Subcutaneous Injection' : _method.toString().split('.').last}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      if (_isReconstituted)
                        Text(
                          'Insulin Units: ${_insulinUnitsController.text.isEmpty ? '0' : _insulinUnitsController.text} IU (${(double.tryParse(_insulinUnitsController.text) ?? 0) / 100} CC)',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
              if (_isReconstituted) ...[
                const SizedBox(height: 8),
                Text(
                  'Target Dose: ${widget.targetDoseMcg?.toStringAsFixed(widget.targetDoseMcg! % 1 == 0 ? 0 : 1) ?? '0'} ${widget.medication.quantityUnit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
                if (widget.selectedIU != null)
                  Text(
                    'Insulin Units: ${widget.selectedIU!.toStringAsFixed(widget.selectedIU! % 1 == 0 ? 0 : 1)} IU (${(widget.selectedIU! / 100).toStringAsFixed(2)} CC)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveDosage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text('Save Dosage', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}