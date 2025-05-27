import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/enums/syringe_size.dart';
import 'package:medtrackr/models/enums/fluid_unit.dart';
import 'package:medtrackr/models/enums/target_dose_unit.dart';
import 'package:medtrackr/utils/calculators/reconstitution_calculator.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';

class ReconstitutionScreen extends StatefulWidget {
  final Medication medication;

  const ReconstitutionScreen({super.key, required this.medication});

  @override
  _ReconstitutionScreenState createState() => _ReconstitutionScreenState();
}

class _ReconstitutionScreenState extends State<ReconstitutionScreen> {
  final _reconstitutionFluidController = TextEditingController();
  final _targetDoseController = TextEditingController();
  final _fluidAmountController = TextEditingController();
  TargetDoseUnit _targetDoseUnit = TargetDoseUnit.mcg;
  FluidUnit _fluidVolumeUnit = FluidUnit.mL;
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _targetDose = 0;
  String? _reconstitutionError;
  SyringeSize _syringeSize = SyringeSize.size1_0;

  @override
  void initState() {
    super.initState();
    _reconstitutionFluidController.text = widget.medication.reconstitutionFluid.isNotEmpty
        ? widget.medication.reconstitutionFluid
        : 'Bacteriostatic Water';
    _targetDose = widget.medication.selectedReconstitution?['targetDose']?.toDouble() ?? 0;
    _targetDoseController.text = _formatNumber(_targetDose);
    _fluidAmountController.text = widget.medication.reconstitutionVolume > 0
        ? _formatNumber(widget.medication.reconstitutionVolume)
        : '1';
    _selectedReconstitution = widget.medication.selectedReconstitution;
    _syringeSize = widget.medication.selectedReconstitution?['syringeSize'] != null
        ? SyringeSize.values.firstWhere(
          (e) => e.value == widget.medication.selectedReconstitution!['syringeSize'],
      orElse: () => SyringeSize.size1_0,
    )
        : SyringeSize.size1_0;
    _targetDoseUnit = widget.medication.selectedReconstitution?['targetDoseUnit'] != null
        ? TargetDoseUnit.values.firstWhere(
          (e) => e.displayName == widget.medication.selectedReconstitution!['targetDoseUnit'],
      orElse: () => TargetDoseUnit.mcg,
    )
        : TargetDoseUnit.mcg;
    _calculateReconstitutionSuggestions();
  }

  @override
  void dispose() {
    _reconstitutionFluidController.dispose();
    _targetDoseController.dispose();
    _fluidAmountController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  void _calculateReconstitutionSuggestions() {
    final volume = double.tryParse(_fluidAmountController.text) ?? 1.0;
    final calculator = ReconstitutionCalculator(
      quantityController: TextEditingController(text: widget.medication.quantity.toString()),
      targetDoseController: _targetDoseController,
      quantityUnit: widget.medication.quantityUnit.displayName,
      targetDoseUnit: _targetDoseUnit.displayName,
      medicationName: widget.medication.name,
      syringeSize: _syringeSize.value,
      fixedVolume: volume,
      fixedVolumeUnit: _fluidVolumeUnit,
    );
    final result = calculator.calculate();
    final concentration = result['selectedReconstitution'] != null
        ? (result['selectedReconstitution']['concentration'] as double?) ?? 0.0
        : 0.0;

    setState(() {
      _targetDose = double.tryParse(_targetDoseController.text) ?? 0.0;
      _reconstitutionSuggestions = (result['suggestions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      _selectedReconstitution = result['selectedReconstitution'] as Map<String, dynamic>?;
      _reconstitutionError = result['error'] as String? ??
          (concentration < 0.1
              ? 'Warning: Concentration is ${_formatNumber(concentration)} mg/mL, too low. Increase fluid amount.'
              : concentration > 10
              ? 'Warning: Concentration is ${_formatNumber(concentration)} mg/mL, too high. Decrease fluid amount.'
              : null);
    });
  }

  void _nudgeVolume(bool increase) {
    double currentVolume = double.tryParse(_fluidAmountController.text) ?? 1.0;
    currentVolume = increase ? currentVolume + 0.1 : currentVolume - 0.1;
    if (currentVolume < 0.1) currentVolume = 0.1;
    _fluidAmountController.text = _formatNumber(currentVolume);
    _calculateReconstitutionSuggestions();
  }

  Future<void> _saveReconstitution(BuildContext context) async {
    if (_selectedReconstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reconstitution option')),
      );
      return;
    }

    final updatedMedication = widget.medication.copyWith(
      reconstitutionVolumeUnit: 'mL',
      reconstitutionVolume: _selectedReconstitution!['volume']?.toDouble() ?? 0,
      reconstitutionFluid: _reconstitutionFluidController.text,
      reconstitutionOptions: _reconstitutionSuggestions,
      selectedReconstitution: {
        ...?_selectedReconstitution,
        'targetDoseUnit': _targetDoseUnit.displayName,
      },
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Confirm Reconstitution',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [Shadow(color: AppConstants.primaryColor, blurRadius: 2)],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: RichText(
            text: TextSpan(
              style: AppConstants.cardBodyStyle.copyWith(height: 1.5),
              children: [
                const TextSpan(
                    text: 'Reconstitution Fluid: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${_reconstitutionFluidController.text}\n'),
                const TextSpan(
                    text: 'Fluid Amount: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${_formatNumber(_selectedReconstitution!['volume'])} ${_fluidVolumeUnit.displayName}\n'),
                const TextSpan(
                    text: 'Concentration: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL\n'),
                const TextSpan(
                    text: 'Target Dose: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${_formatNumber(_targetDose)} ${_targetDoseUnit.displayName}\n'),
                const TextSpan(
                    text: 'Administer: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '${_formatNumber(_selectedReconstitution!['syringeUnits'])} IU on a ${_syringeSize.displayName}'),
              ],
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: AppConstants.dialogButtonStyle,
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.updateMedicationAsync(updatedMedication.id, updatedMedication);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/medication_details', arguments: updatedMedication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reconstitution: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetDoseUnits = widget.medication.quantityUnit == QuantityUnit.mg
        ? [TargetDoseUnit.mg, TargetDoseUnit.mcg]
        : [TargetDoseUnit.mcg, TargetDoseUnit.mg];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Reconstitute Medication'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reconstitution Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reconstitutionFluidController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Reconstitution Fluid (e.g., Bacteriostatic Water)',
                ),
                onChanged: (value) => _calculateReconstitutionSuggestions(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetDoseController,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: 'Target Dose',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateReconstitutionSuggestions(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<TargetDoseUnit>(
                      value: _targetDoseUnit,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: 'Unit',
                      ),
                      items: targetDoseUnits
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit.displayName)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _targetDoseUnit = value;
                            _calculateReconstitutionSuggestions();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fluidAmountController,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: 'Fluid Amount',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateReconstitutionSuggestions(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<FluidUnit>(
                      value: _fluidVolumeUnit,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: 'Unit',
                      ),
                      items: FluidUnit.values
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit.displayName)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _fluidVolumeUnit = value;
                            _calculateReconstitutionSuggestions();
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _nudgeVolume(false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _nudgeVolume(true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SyringeSize>(
                value: _syringeSize,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Syringe Size',
                ),
                items: SyringeSize.values
                    .map((size) => DropdownMenuItem(value: size, child: Text(size.displayName)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _syringeSize = value;
                      _calculateReconstitutionSuggestions();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedReconstitution != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formula: Units = (Target Dose (mg) / Concentration (mg/mL)) * 100',
                        style: AppConstants.secondaryTextStyle,
                      ),
                      Text(
                        'Calculation: ${_formatNumber(_targetDose * (_targetDoseUnit == TargetDoseUnit.mg ? 1 : 1 / 1000))} mg / ${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL * 100 = ${_formatNumber(_selectedReconstitution!['syringeUnits'])} IU',
                        style: AppConstants.secondaryTextStyle,
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  padding: const EdgeInsets.all(16),
                  decoration: AppConstants.cardDecoration,
                  child: RichText(
                    text: TextSpan(
                      style: AppConstants.cardBodyStyle,
                      children: [
                        TextSpan(
                          text: 'Reconstitute ${widget.medication.name} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: 'with '),
                        TextSpan(
                          text: _formatNumber(_selectedReconstitution!['volume']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${_fluidVolumeUnit.displayName} '),
                        const TextSpan(text: 'of '),
                        TextSpan(
                          text: _reconstitutionFluidController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nAdminister '),
                        TextSpan(
                          text: _formatNumber(_selectedReconstitution!['syringeUnits']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                          text: ' IU',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' on a '),
                        TextSpan(
                          text: _syringeSize.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nfor a dosage of '),
                        TextSpan(
                          text: _formatNumber(_targetDose),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' ${_targetDoseUnit.displayName}\n'),
                        const TextSpan(
                          text: 'Concentration: ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        TextSpan(
                          text: '${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL',
                          style: AppConstants.secondaryTextStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_reconstitutionError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _reconstitutionError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveReconstitution(context),
                style: AppConstants.actionButtonStyle,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/calendar');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    );
  }
}