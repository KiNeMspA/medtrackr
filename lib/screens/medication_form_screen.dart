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
  String _quantityUnit = 'mg';
  String _targetDoseUnit = 'mcg';
  bool _isReconstituting = false;
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _totalAmount = 0;
  double _targetDose = 0;
  String _medicationName = '';
  String? _reconstitutionError;
  double _syringeSize = 1.0; // Default syringe size (mL)

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _type = widget.medication!.type;
      _quantityUnit = widget.medication!.quantityUnit;
      _quantityController.text = widget.medication!.quantity.toStringAsFixed(2);
      _isReconstituting = widget.medication!.reconstitutionVolume > 0;
      _reconstitutionFluidController.text = widget.medication!.reconstitutionFluid;
      _notesController.text = widget.medication!.notes;
      _reconstitutionSuggestions = widget.medication!.reconstitutionOptions ?? [];
      _selectedReconstitution = widget.medication!.selectedReconstitution;
      _totalAmount = widget.medication!.quantity;
      _medicationName = widget.medication!.name;
      _targetDose = widget.medication!.selectedReconstitution?['doseVolume']?.toDouble() ?? 0;
      _targetDoseController.text = _targetDose.toStringAsFixed(_targetDose % 1 == 0 ? 0 : 2);
      _targetDoseUnit = widget.medication!.quantityUnit == 'IU' ? 'mcg' : widget.medication!.quantityUnit;
      _syringeSize = widget.medication!.reconstitutionVolume > 0
          ? widget.medication!.reconstitutionVolume
          : 1.0;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _reconstitutionFluidController.dispose();
    _targetDoseController.dispose();
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
      syringeSize: _syringeSize,
    );
    final result = calculator.calculate();
    final concentration = result['selectedReconstitution'] != null
        ? result['selectedReconstitution']['concentration'] as double
        : 0.0;

    setState(() {
      _reconstitutionSuggestions = result['suggestions'] as List<Map<String, dynamic>>;
      _selectedReconstitution = result['selectedReconstitution'] as Map<String, dynamic>?;
      _totalAmount = result['totalAmount'] as double;
      _targetDose = result['targetDose'] as double;
      _medicationName = result['medicationName'] as String;
      _reconstitutionError = result['error'] as String? ??
          (concentration < 0.1 || concentration > 10
              ? 'Warning: Concentration is ${concentration.toStringAsFixed(2)} mg/mL, recommended range is 0.1–10 mg/mL.'
              : null);
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
        const SnackBar(content: Text('Please select a valid reconstitution option')),
      );
      return;
    }

    // Handle reconstitution warning
    bool proceed = true;
    if (_isReconstituting && _reconstitutionError != null) {
      proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reconstitution Warning'),
          content: Text(_reconstitutionError!),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed Anyway'),
            ),
          ],
        ),
      ) ??
          false;
    }

    if (!proceed) return;

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
      builder: (context) => _buildConfirmationDialog(context, medication),
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      print('Saving medication: ${medication.name}');
      if (widget.medication == null) {
        await dataProvider.addMedicationAsync(medication);
      } else {
        await dataProvider.updateMedicationAsync(medication.id, medication);
      }

      if (!context.mounted) return;
      print('Navigating to AddDosageScreen');
      final dosageResult = await Navigator.pushNamed(
        context,
        '/add_dosage',
        arguments: {
          'medication': medication,
          'targetDoseMcg': _targetDose * 1000, // Convert mg to mcg
          'selectedIU': _isReconstituting ? (_selectedReconstitution?['syringeUnits']?.toDouble() ?? 0) : 0.0,
        },
      );

      if (context.mounted && dosageResult != null) {
        print('Navigating to AddScheduleScreen');
        await Navigator.pushNamed(
          context,
          '/add_schedule',
          arguments: {'medication': medication},
        );
        print('Navigating to MedicationDetailsScreen');
        await Future.delayed(const Duration(milliseconds: 200));
        Navigator.pushNamed(
          context,
          '/medication_details',
          arguments: medication,
        );
      }
    } catch (e) {
      print('Error saving medication: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving medication: $e')),
        );
      }
    }
  }

  Widget _buildConfirmationDialog(BuildContext context, Medication medication) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.medication == null ? 'Confirm Medication Settings' : 'Confirm Changes',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Name: ${medication.name}\n'
              'Type: ${medication.type}\n'
              'Quantity: ${medication.quantity.toStringAsFixed(2)} ${medication.quantityUnit}\n'
              '${medication.reconstitutionVolume > 0 ? 'Reconstituted with ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'} ${medication.reconstitutionVolume} mL\nConcentration: ${(medication.selectedReconstitution?['concentration'] ?? 0).toStringAsFixed(2)} mg/mL\n' : ''}'
              'Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
          style: const TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Confirm',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add Medication Stock' : 'Edit Medication'),
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _type == 'Injection'
                    ? 'Enter the potency of the vial (e.g., total mg or mcg in the vial).'
                    : _type == 'Tablet' || _type == 'Capsule'
                    ? 'Enter the potency per tablet/capsule (e.g., mg per tablet) and the total number of tablets/capsules.'
                    : 'Enter the total quantity of the medication.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              MedicationFormFields(
                nameController: _nameController,
                quantityController: _quantityController,
                quantityUnit: _quantityUnit,
                type: _type,
                notesController: _notesController,
                onQuantityChanged: _calculateReconstitutionSuggestions,
                onNameChanged: (value) => setState(() {
                  _medicationName = value?.isNotEmpty == true ? value! : 'Medication';
                  _calculateReconstitutionSuggestions();
                }),
                onTypeChanged: (value) => setState(() {
                  _type = value ?? 'Tablet';
                  _quantityUnit = {
                    'Tablet': 'mg',
                    'Capsule': 'mg',
                    'Injection': 'mg',
                    'Other': 'mg',
                  }[value]!;
                  _targetDoseUnit = 'mcg';
                  _isReconstituting = false;
                  _reconstitutionSuggestions = [];
                  _selectedReconstitution = null;
                  _calculateReconstitutionSuggestions();
                }),
                onQuantityUnitChanged: (value) => setState(() {
                  _quantityUnit = value ?? 'mg';
                  _targetDoseUnit = value == 'IU' ? 'mcg' : 'mcg';
                  _calculateReconstitutionSuggestions();
                }),
              ),
              if (_type == 'Injection' || _type == 'Other') ...[
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text(
                    'Reconstitute Medication',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  activeColor: const Color(0xFFFFC107),
                  value: _isReconstituting,
                  onChanged: (value) => setState(() {
                    _isReconstituting = value;
                    if (!value) {
                      _reconstitutionSuggestions = [];
                      _selectedReconstitution = null;
                      _totalAmount = 0;
                      _targetDose = 0;
                      _reconstitutionFluidController.text = '';
                      _reconstitutionError = null;
                    }
                    _calculateReconstitutionSuggestions();
                  }),
                ),
                if (_isReconstituting) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    value: _syringeSize,
                    decoration: InputDecoration(
                      labelText: 'Syringe Size (mL)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [0.3, 0.5, 1.0, 3.0, 5.0]
                        .map((size) => DropdownMenuItem(
                      value: size,
                      child: Text('$size mL'),
                    ))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _syringeSize = value ?? 1.0;
                      _calculateReconstitutionSuggestions();
                    }),
                  ),
                ],
              ],
              if (_isReconstituting) ...[
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
                  quantityUnit: _quantityUnit,
                  reconstitutionError: _reconstitutionError,
                  onReconstitutingChanged: (value) => setState(() {
                    _isReconstituting = value;
                    if (!value) {
                      _reconstitutionSuggestions = [];
                      _selectedReconstitution = null;
                      _totalAmount = 0;
                      _targetDose = 0;
                      _medicationName = _nameController.text.isNotEmpty ? _nameController.text : 'Medication';
                      _reconstitutionFluidController.text = '';
                      _reconstitutionError = null;
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
                      SnackBar(content: Text('Selected ${suggestion['volume']} mL, ${suggestion['concentration'].toStringAsFixed(2)} mg/mL')),
                    );
                    _calculateReconstitutionSuggestions();
                  }),
                  onEditReconstitution: (suggestion) async {
                    final updated = await showDialog<Map<String, dynamic>>(
                      context: context,
                      builder: (context) => _ReconstitutionEditDialog(
                        suggestion: suggestion,
                        fluid: _reconstitutionFluidController.text,
                      ),
                    );
                    if (updated != null && context.mounted) {
                      setState(() {
                        _selectedReconstitution = updated;
                        _reconstitutionFluidController.text = updated['fluid'] ?? _reconstitutionFluidController.text;
                      });
                      _calculateReconstitutionSuggestions();
                    }
                  },
                  onAdjustVolume: (increment) {
                    if (_selectedReconstitution != null) {
                      setState(() {
                        final currentVolume = (_selectedReconstitution!['volume'] as num).toDouble();
                        final newVolume = (currentVolume + increment).clamp(0.1, _syringeSize);
                        _selectedReconstitution = {
                          ..._selectedReconstitution!,
                          'volume': newVolume,
                          'concentration': _totalAmount / newVolume,
                          'doseVolume': _targetDose / (_totalAmount / newVolume),
                          'syringeUnits': (_targetDose / (_totalAmount / newVolume)) * 100,
                        };
                      });
                      _calculateReconstitutionSuggestions();
                    }
                  },
                  onClearReconstitution: () => setState(() {
                    _selectedReconstitution = null;
                    _reconstitutionError = null;
                    _calculateReconstitutionSuggestions();
                  }),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveMedication(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text('Save Medication', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReconstitutionEditDialog extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final String fluid;

  const _ReconstitutionEditDialog({required this.suggestion, required this.fluid});

  @override
  Widget build(BuildContext context) {
    final volumeController = TextEditingController(text: suggestion['volume'].toStringAsFixed(2));
    final concentrationController = TextEditingController(text: suggestion['concentration'].toStringAsFixed(2));
    final fluidController = TextEditingController(text: fluid);

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Edit Reconstitution',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: volumeController,
            decoration: InputDecoration(
              labelText: 'Volume (mL)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: concentrationController,
            decoration: InputDecoration(
              labelText: 'Concentration (mg/mL)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: fluidController,
            decoration: InputDecoration(
              labelText: 'Fluid',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Color(0xFFFFC107)),
          ),
        ),
        TextButton(
          onPressed: () {
            final volume = double.tryParse(volumeController.text) ?? suggestion['volume'];
            final concentration = double.tryParse(concentrationController.text) ?? suggestion['concentration'];
            Navigator.pop(context, {
              'volume': volume,
              'concentration': concentration,
              'doseVolume': suggestion['doseVolume'],
              'syringeUnits': suggestion['syringeUnits'],
              'fluid': fluidController.text,
            });
          },
          child: const Text(
            'Save',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}