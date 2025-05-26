import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/utils/reconstitution_calculator.dart';
import 'package:medtrackr/widgets/medication_form_fields.dart';
import 'package:medtrackr/widgets/reconstitution_widgets.dart';
import 'package:uuid/uuid.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({super.key, this.medication});

  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _reconstitutionFluidController = TextEditingController();
  final _targetDoseController = TextEditingController();
  final _notesController = TextEditingController();
  String _type = 'Tablet';
  String _quantityUnit = 'mcg';
  String _targetDoseUnit = 'mcg';
  bool _isReconstituting = false;
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _totalAmount = 0;
  double _targetDose = 0;
  String _medicationName = '';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _type = widget.medication!.type;
      _quantityUnit = widget.medication!.quantityUnit;
      _quantityController.text = widget.medication!.quantity.toInt().toString();
      _isReconstituting = widget.medication!.reconstitutionVolume > 0;
      _reconstitutionFluidController.text = widget.medication!.reconstitutionFluid;
      _notesController.text = widget.medication!.notes;
      _reconstitutionSuggestions = widget.medication!.reconstitutionOptions;
      _selectedReconstitution = widget.medication!.selectedReconstitution;
      _totalAmount = widget.medication!.quantity;
      _medicationName = widget.medication!.name;
      _targetDose = widget.medication!.selectedReconstitution?['iu']?.toDouble() ?? 0;
      _targetDoseController.text = _targetDose.toInt().toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _targetDoseController.dispose();
    _reconstitutionFluidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateReconstitutionSuggestions() {
    final calculator = ReconstitutionCalculator(
      quantityController: _quantityController,
      targetDoseController: _targetDoseController,
      quantityUnit: _quantityUnit,
      targetDoseUnit: _targetDoseUnit,
      medicationName: _nameController.text,
    );
    final result = calculator.calculate();
    setState(() {
      _reconstitutionSuggestions = result.suggestions;
      _selectedReconstitution = result.selectedReconstitution;
      _totalAmount = result.totalAmount;
      _targetDose = result.targetDose;
      _medicationName = result.medicationName;
    });
  }

  Future<void> _saveMedication(BuildContext context) async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_isReconstituting && _selectedReconstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reconstitution option')),
      );
      return;
    }

    final medication = (widget.medication ?? Medication(
      id: const Uuid().v4(),
      name: '',
      type: '',
      quantityUnit: '',
      quantity: 0,
      remainingQuantity: 0,
      reconstitutionVolumeUnit: '',
      reconstitutionVolume: 0,
      reconstitutionFluid: '',
      notes: '',
    )).copyWith(
      name: _nameController.text,
      type: _type,
      quantityUnit: _quantityUnit,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      remainingQuantity: double.tryParse(_quantityController.text) ?? 0,
      reconstitutionVolumeUnit: _isReconstituting ? 'mL' : '',
      reconstitutionVolume: _isReconstituting ? (_selectedReconstitution?['volume']?.toDouble() ?? 0) : 0,
      reconstitutionFluid: _isReconstituting ? _reconstitutionFluidController.text : '',
      notes: _notesController.text,
      reconstitutionOptions: _isReconstituting ? _reconstitutionSuggestions : [],
      selectedReconstitution: _isReconstituting ? _selectedReconstitution : null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[100],
        title: Text(
          widget.medication == null ? 'Confirm Medication Settings' : 'Confirm Changes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Name: ${medication.name}\n'
                'Type: ${medication.type}\n'
                'Quantity: ${medication.quantity.toInt()} ${medication.quantityUnit}\n'
                '${medication.reconstitutionVolume > 0 ? 'Reconstituted with ${medication.reconstitutionVolume.toInt()} mL\nIU per Dose: ${_selectedReconstitution?['iu'] ?? 0} IU\nFluid: ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'}\n' : ''}'
                'Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.green[900],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (widget.medication == null) {
      dataProvider.addMedication(medication);
    } else {
      dataProvider.updateMedication(medication.id, medication);
    }

    await Navigator.pushNamed(
      context,
      '/add_dosage',
      arguments: {
        'medication': medication,
        'targetDoseMcg': _targetDose,
        'selectedIU': _selectedReconstitution?['iu']?.toDouble() ?? 0,
      },
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medication Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              MedicationFormFields(
                nameController: _nameController,
                quantityController: _quantityController,
                quantityUnit: _quantityUnit,
                type: _type,
                notesController: _notesController, // Add notes
                onQuantityChanged: _calculateReconstitutionSuggestions,
                onNameChanged: (value) => setState(() {
                  _medicationName = value?.isNotEmpty == true ? value! : 'Medication';
                  _calculateReconstitutionSuggestions();
                }),
                onTypeChanged: (value) => setState(() {
                  _type = value ?? 'Tablet';
                }),
                onQuantityUnitChanged: (value) => setState(() {
                  _quantityUnit = value ?? 'mcg';
                  _calculateReconstitutionSuggestions();
                }),
              ),
              const SizedBox(height: 24),
              ReconstitutionWidgets(
                isReconstituting: _isReconstituting,
                reconstitutionFluidController: _reconstitutionFluidController,
                targetDoseController: _targetDoseController,
                targetDoseUnit: _targetDoseUnit,
                reconstitutionSuggestions: _reconstitutionSuggestions,
                selectedReconstitution: _selectedReconstitution,
                totalAmount: _totalAmount,
                targetDose: _targetDose,
                medicationName: _medicationName,
                quantityUnit: _quantityUnit, // Add this line
                onReconstitutingChanged: (value) => setState(() {
                  _isReconstituting = value;
                  if (!value) {
                    _reconstitutionSuggestions = [];
                    _selectedReconstitution = null;
                    _totalAmount = 0;
                    _targetDose = 0;
                    _medicationName = _nameController.text.isNotEmpty ? _nameController.text : 'Medication';
                    _reconstitutionFluidController.text = '';
                  }
                  _calculateReconstitutionSuggestions();
                }),
                onFluidChanged: _calculateReconstitutionSuggestions,
                onTargetDoseChanged: _calculateReconstitutionSuggestions,
                onTargetDoseUnitChanged: (value) => setState(() {
                  _targetDoseUnit = value!;
                  _calculateReconstitutionSuggestions();
                }),
                onSuggestionSelected: (suggestion) => setState(() {
                  _selectedReconstitution = suggestion;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selected ${suggestion['volume']} mL reconstitution')),
                  );
                }),
                onEditReconstitution: (suggestion) async {
                  final updated = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => ReconstitutionEditDialog(
                      suggestion: suggestion,
                      fluid: _reconstitutionFluidController.text,
                    ),
                  );
                  if (updated != null) {
                    setState(() {
                      _selectedReconstitution = updated;
                      _reconstitutionFluidController.text = updated['fluid'] ?? _reconstitutionFluidController.text;
                    });
                  }
                },
                onClearReconstitution: () => setState(() => _selectedReconstitution = null),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveMedication(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Medication', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}