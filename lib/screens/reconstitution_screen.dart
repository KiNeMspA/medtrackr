import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/models/medication.dart';
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
  double _targetDose = 0;
  TargetDoseUnit _targetDoseUnit = TargetDoseUnit.mcg; // Default to mcg
  FluidUnit _fluidVolumeUnit = FluidUnit.mL;
  SyringeSize _syringeSize = SyringeSize.size1_0;
  Map<String, dynamic>? _selectedReconstitution;
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication.type != MedicationType.injection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return;
    }
    _reconstitutionFluidController.text = widget.medication.reconstitutionFluid.isNotEmpty
        ? widget.medication.reconstitutionFluid
        : 'Bacteriostatic Water';
    _targetDose = widget.medication.selectedReconstitution?['targetDose']?.toDouble() ?? 0;
    _targetDoseController.text = _targetDose > 0 ? _formatNumber(_targetDose) : '';
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
    _fluidVolumeUnit = widget.medication.reconstitutionVolumeUnit.isNotEmpty
        ? FluidUnit.values.firstWhere(
          (e) => e.displayName == widget.medication.reconstitutionVolumeUnit,
      orElse: () => FluidUnit.mL,
    )
        : FluidUnit.mL;
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
    _reconstitutionSuggestions.clear();
    final fluidAmount = double.tryParse(_fluidAmountController.text) ?? 1;
    final concentration = widget.medication.quantity / fluidAmount;
    final targetDose = double.tryParse(_targetDoseController.text) ?? 0;
    final syringeUnits = targetDose / concentration;

    _reconstitutionSuggestions.add({
      'volume': fluidAmount,
      'concentration': concentration,
      'syringeUnits': syringeUnits,
      'targetDose': targetDose,
      'targetDoseUnit': _targetDoseUnit.displayName,
      'syringeSize': _syringeSize.value,
    });

    // Add lower and higher reference doses
    _reconstitutionSuggestions.add({
      'volume': fluidAmount,
      'concentration': concentration,
      'syringeUnits': syringeUnits * 0.5,
      'targetDose': targetDose * 0.5,
      'targetDoseUnit': _targetDoseUnit.displayName,
      'syringeSize': _syringeSize.value,
    });
    _reconstitutionSuggestions.add({
      'volume': fluidAmount,
      'concentration': concentration,
      'syringeUnits': syringeUnits * 1.5,
      'targetDose': targetDose * 1.5,
      'targetDoseUnit': _targetDoseUnit.displayName,
      'syringeSize': _syringeSize.value,
    });

    setState(() {});
  }

  Future<void> _saveReconstitution(BuildContext context) async {
    if (_targetDoseController.text.isEmpty || _fluidAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final fluidAmount = double.parse(_fluidAmountController.text);
    final targetDose = double.parse(_targetDoseController.text);
    final concentration = widget.medication.quantity / fluidAmount;
    final syringeUnits = targetDose / concentration;

    final reconstitution = {
      'volume': fluidAmount,
      'concentration': concentration,
      'syringeUnits': syringeUnits,
      'targetDose': targetDose,
      'targetDoseUnit': _targetDoseUnit.displayName,
      'syringeSize': _syringeSize.value,
    };

    final updatedMedication = widget.medication.copyWith(
      reconstitutionVolume: fluidAmount,
      reconstitutionVolumeUnit: _fluidVolumeUnit.displayName,
      reconstitutionFluid: _reconstitutionFluidController.text,
      selectedReconstitution: reconstitution,
      reconstitutionOptions: [reconstitution],
    );

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.updateMedicationAsync(
          widget.medication.id, updatedMedication);
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reconstitution: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medication.type != MedicationType.injection) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: const Center(
            child: Text('Reconstitution is only available for injections')),
      );
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
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
                'Reconstitution for ${widget.medication.name}',
                style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reconstitutionFluidController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Reconstitution Fluid',
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a fluid' : null,
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a dose';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value)! <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<TargetDoseUnit>(
                      value: _targetDoseUnit,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: 'Unit',
                      ),
                      items: TargetDoseUnit.values
                          .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit.displayName),
                      ))
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value)! <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 120,
                    child: DropdownButtonFormField<FluidUnit>(
                      value: _fluidVolumeUnit,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: 'Unit',
                      ),
                      items: FluidUnit.values
                          .map((unit) => DropdownMenuItem(
                        value: unit,
                        child: Text(unit.displayName),
                      ))
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
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SyringeSize>(
                value: _syringeSize,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Syringe Size',
                ),
                items: SyringeSize.values
                    .map((size) => DropdownMenuItem(
                  value: size,
                  child: Text(size.displayName),
                ))
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
              const Text(
                'Reconstitution Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              ..._reconstitutionSuggestions.asMap().entries.map((entry) {
                final index = entry.key;
                final suggestion = entry.value;
                final isSelected =
                    _selectedReconstitution == suggestion;
                final label = index == 0
                    ? 'Target Dose'
                    : index == 1
                    ? 'Lower Dose'
                    : 'Higher Dose';
                return Card(
                  elevation: isSelected ? 4 : 1,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(
                      '$label: ${suggestion['syringeUnits']} IU (${suggestion['targetDose']} ${suggestion['targetDoseUnit']})',
                      style: TextStyle(
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      'Volume: ${suggestion['volume']} mL, Concentration: ${suggestion['concentration']} mg/mL',
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedReconstitution = suggestion;
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveReconstitution(context),
                  style: AppConstants.actionButtonStyle,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Reconstitution'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/calendar');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    );
  }
}