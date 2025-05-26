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
  final _volumeController = TextEditingController();
  final _insulinUnitsController = TextEditingController();
  String _doseUnit = 'IU';
  DosageMethod _method = DosageMethod.subcutaneous;
  bool _isReconstituted = false;

  @override
  void initState() {
    super.initState();
    _isReconstituted = widget.medication.reconstitutionVolume > 0;
    if (widget.dosage != null) {
      _nameController.text = widget.dosage!.name;
      _doseController.text = widget.dosage!.totalDose.toString();
      _volumeController.text = widget.dosage!.volume.toString();
      _insulinUnitsController.text = widget.dosage!.insulinUnits.toString();
      _method = widget.dosage!.method;
      _doseUnit = widget.dosage!.doseUnit;
    } else {
      _nameController.text = _isReconstituted
          ? 'Dose of ${widget.targetDoseMcg?.toInt() ?? 0} IU'
          : '${widget.medication.name} Dose 1';
      _doseController.text = _isReconstituted ? (widget.targetDoseMcg?.toString() ?? '') : '';
      _insulinUnitsController.text = _isReconstituted ? (widget.selectedIU?.toString() ?? '') : '';
      _doseUnit = _isReconstituted ? 'IU' : widget.medication.quantityUnit;
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
      id: widget.dosage?.id ?? const Uuid().v4(),
      medicationId: widget.medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: double.tryParse(_doseController.text) ?? 0,
      volume: _volumeController.text.isNotEmpty ? double.tryParse(_volumeController.text) ?? 0 : 0,
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
        ? ['IU', 'mL']
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
                volumeController: _volumeController,
                insulinUnitsController: _insulinUnitsController,
                doseUnit: _doseUnit,
                doseUnits: doseUnits,
                method: _method,
                onDoseUnitChanged: (value) => setState(() => _doseUnit = value!),
                onMethodChanged: (value) => setState(() => _method = value!),
              ),
              if (_isReconstituted) ...[
                const SizedBox(height: 8),
                Text(
                  'Target Dose: ${widget.targetDoseMcg?.toInt() ?? 0} IU',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (widget.selectedIU != null)
                  Text(
                    'IU per mL: ${widget.selectedIU!.toInt()} IU',
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
      ),
    );
  }
}