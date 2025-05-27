import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';
import 'package:medtrackr/models/enums/target_dose_unit.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/enums/syringe_size.dart';
import 'package:medtrackr/widgets/forms/medication_form_fields.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({super.key, this.medication});

  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _notesController;
  late TextEditingController _reconstitutionFluidController;
  late TextEditingController _targetDoseController;
  MedicationType _type = MedicationType.injection;
  QuantityUnit _quantityUnit = QuantityUnit.mcg;
  TargetDoseUnit _targetDoseUnit = TargetDoseUnit.mcg;
  bool _isReconstituting = false;
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _totalAmount = 0;
  double _targetDose = 0;
  String _medicationName = '';
  SyringeSize _syringeSize = SyringeSize.size1_0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.medication != null ? widget.medication!.quantity.toStringAsFixed(0) : '');
    _notesController = TextEditingController(text: widget.medication?.notes ?? '');
    _reconstitutionFluidController = TextEditingController(
        text: widget.medication?.reconstitutionFluid ?? '');
    _targetDoseController = TextEditingController(
        text: widget.medication?.selectedReconstitution?['iu']?.toString() ?? '');
    if (widget.medication != null) {
      _type = MedicationType.values.firstWhere(
            (e) => e.displayName == widget.medication!.type,
        orElse: () => MedicationType.injection,
      );
      _quantityUnit = QuantityUnit.values.firstWhere(
            (e) => e.displayName == widget.medication!.quantityUnit,
        orElse: () => QuantityUnit.mcg,
      );
      _isReconstituting = widget.medication!.reconstitutionVolume > 0;
      _reconstitutionSuggestions = widget.medication!.reconstitutionOptions;
      _selectedReconstitution = widget.medication!.selectedReconstitution;
      _totalAmount = widget.medication!.quantity;
      _medicationName = widget.medication!.name;
      _targetDose = widget.medication!.selectedReconstitution?['iu']?.toDouble() ?? 0;
    }
    _calculateReconstitutionSuggestions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _reconstitutionFluidController.dispose();
    _targetDoseController.dispose();
    super.dispose();
  }

  void _calculateReconstitutionSuggestions() {
    final totalAmount = int.tryParse(_quantityController.text) ?? 0;
    final targetDose = int.tryParse(_targetDoseController.text) ?? 0;
    if (totalAmount <= 0 || (_isReconstituting && targetDose <= 0)) {
      setState(() {
        _reconstitutionSuggestions = [];
        _selectedReconstitution = null;
        _totalAmount = 0;
        _targetDose = 0;
        _medicationName = '';
      });
      return;
    }

    final totalMcg = _quantityUnit == QuantityUnit.mg ? totalAmount * 1000 : totalAmount;
    final targetMcg = _targetDoseUnit == TargetDoseUnit.mg ? targetDose * 1000 : targetDose;

    setState(() {
      _totalAmount = _quantityUnit == QuantityUnit.mg
          ? totalAmount.toDouble()
          : (totalMcg / 1000).toDouble();
      _targetDose = targetMcg.toDouble();
      _medicationName = _nameController.text.isNotEmpty ? _nameController.text : 'Medication';
    });

    if (!_isReconstituting) {
      setState(() {
        _reconstitutionSuggestions = [];
        _selectedReconstitution = null;
      });
      return;
    }

    final suggestions = <Map<String, dynamic>>[];
    for (final volume in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
      final concentration = totalMcg / volume;
      final iuPerDose = (targetMcg / concentration) * 100 / _syringeSize.value;
      if (iuPerDose >= 10 && iuPerDose <= 100 * _syringeSize.value) {
        suggestions.add({
          'volume': volume,
          'iu': iuPerDose.round(),
          'concentration': concentration.round(),
          'totalAmount': _totalAmount,
          'targetDose': _targetDose,
        });
      }
    }
    setState(() {
      _reconstitutionSuggestions = suggestions;
      if (_selectedReconstitution != null &&
          !suggestions.any((s) => s['volume'] == _selectedReconstitution!['volume'])) {
        _selectedReconstitution = null;
      }
    });
  }

  void _editReconstitution(Map<String, dynamic> suggestion) async {
    final volumeController = TextEditingController(text: suggestion['volume'].toString());
    final iuController = TextEditingController(text: suggestion['iu'].toString());
    final fluidController = TextEditingController(text: _reconstitutionFluidController.text);

    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Reconstitution'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: volumeController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Volume (mL)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: iuController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'IU per Dose',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: fluidController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Reconstitution Fluid',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppConstants.primaryColor)),
          ),
          TextButton(
            onPressed: () {
              if (volumeController.text.isEmpty || iuController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }
              final volume = int.tryParse(volumeController.text) ?? suggestion['volume'];
              final iu = int.tryParse(iuController.text) ?? suggestion['iu'];
              Navigator.pop(context, {
                'volume': volume,
                'iu': iu,
                'concentration': suggestion['concentration'],
                'totalAmount': suggestion['totalAmount'],
                'targetDose': suggestion['targetDose'],
              });
              _reconstitutionFluidController.text = fluidController.text;
            },
            child: const Text('Save', style: TextStyle(color: AppConstants.primaryColor)),
          ),
        ],
      ),
    );

    if (updated != null) {
      setState(() {
        _selectedReconstitution = updated;
      });
    }
  }

  Future<void> _saveMedication(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
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

    final medication = Medication(
      id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _type,
      quantityUnit: _quantityUnit,
      quantity: double.tryParse(_quantityController.text) ?? 0.0,
      remainingQuantity: double.tryParse(_quantityController.text) ?? 0.0,
      reconstitutionVolumeUnit: _isReconstituting ? 'mL' : '',
      reconstitutionVolume: _isReconstituting
          ? (_selectedReconstitution != null ? _selectedReconstitution!['volume'].toDouble() : 0.0)
          : 0.0,
      reconstitutionFluid: _isReconstituting ? _reconstitutionFluidController.text : '',
      notes: _notesController.text,
      reconstitutionOptions: _isReconstituting ? _reconstitutionSuggestions : [],
      selectedReconstitution: _isReconstituting ? _selectedReconstitution : null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Confirm Medication Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Name: ${medication.name}\n'
                'Type: ${medication.type.displayName}\n'
                'Quantity: ${medication.quantity.toStringAsFixed(0)} ${medication.quantityUnit.displayName}\n'
                '${medication.reconstitutionVolume > 0 ? 'Reconstituted with ${medication.reconstitutionVolume.toStringAsFixed(0)} mL\nIU per Dose: ${_selectedReconstitution?['iu'] ?? 0} IU\nFluid: ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'}\n' : ''}'
                'Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Confirm',
              style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      if (widget.medication == null) {
        await dataProvider.addMedicationAsync(medication);
      } else {
        await dataProvider.updateMedicationAsync(medication.id, medication);
      }
      if (context.mounted) {
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medication: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication Details',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                MedicationFormFields(
                  nameController: _nameController,
                  quantityController: _quantityController,
                  quantityUnit: _quantityUnit,
                  type: _type,
                  notesController: _notesController,
                  isReconstituting: _isReconstituting,
                  reconstitutionFluidController: _reconstitutionFluidController,
                  targetDoseController: _targetDoseController,
                  targetDoseUnit: _targetDoseUnit,
                  reconstitutionSuggestions: _reconstitutionSuggestions,
                  selectedReconstitution: _selectedReconstitution,
                  onNameChanged: (value) {
                    setState(() => _medicationName = value ?? 'Medication');
                    _calculateReconstitutionSuggestions();
                  },
                  onTypeChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                        _calculateReconstitutionSuggestions();
                      });
                    }
                  },
                  onQuantityUnitChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _quantityUnit = value;
                        _calculateReconstitutionSuggestions();
                      });
                    }
                  },
                  onTargetDoseUnitChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _targetDoseUnit = value;
                        _calculateReconstitutionSuggestions();
                      });
                    }
                  },
                  onReconstitutingChanged: (value) {
                    setState(() {
                      _isReconstituting = value;
                      if (!value) {
                        _reconstitutionSuggestions = [];
                        _selectedReconstitution = null;
                        _totalAmount = 0;
                        _targetDose = 0;
                        _reconstitutionFluidController.text = '';
                      }
                      _calculateReconstitutionSuggestions();
                    });
                  },
                  onQuantityChanged: _calculateReconstitutionSuggestions,
                  onTargetDoseChanged: _calculateReconstitutionSuggestions,
                  onReconstitutionFluidChanged: _calculateReconstitutionSuggestions,
                  onSelectReconstitution: (suggestion) {
                    setState(() => _selectedReconstitution = suggestion);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected ${suggestion['volume']} mL reconstitution')),
                    );
                  },
                  onEditReconstitution: _editReconstitution,
                  onClearReconstitution: () {
                    setState(() => _selectedReconstitution = null);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _saveMedication(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    widget.medication == null ? 'Add Medication' : 'Update Medication',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}