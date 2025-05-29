// lib/features/medication/ui/views/reconstitution_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';
import 'package:medtrackr/features/medication/utils/reconstitution_calculator.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';

class ReconstitutionView extends StatefulWidget {
  final Medication medication;

  const ReconstitutionView({super.key, required this.medication});

  @override
  _ReconstitutionViewState createState() => _ReconstitutionViewState();
}

class _ReconstitutionViewState extends State<ReconstitutionView> {
  final _reconstitutionFluidController = TextEditingController();
  final _targetDoseController = TextEditingController();
  final _fluidAmountController = TextEditingController();
  double _targetDose = 0;
  TargetDoseUnit _targetDoseUnit = TargetDoseUnit.mcg;
  FluidUnit _fluidVolumeUnit = FluidUnit.mL;
  SyringeSize _syringeSize = SyringeSize.size1_0;
  Map<String, dynamic>? _selectedReconstitution;
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  bool _isSaving = false;
  String? _validationError;
  bool _isValid = true;

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
    _targetDose = widget.medication.selectedReconstitution?['targetDose']?.toDouble() ?? 500;
    _targetDoseController.text = formatNumber(_targetDose);
    _fluidAmountController.text = widget.medication.reconstitutionVolume > 0
        ? formatNumber(widget.medication.reconstitutionVolume)
        : '2';
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

    // Add listeners for real-time validation
    _fluidAmountController.addListener(_validateInput);
    _targetDoseController.addListener(_validateInput);
    _calculateReconstitutionSuggestions();
  }

  @override
  void dispose() {
    _reconstitutionFluidController.dispose();
    _targetDoseController.dispose();
    _fluidAmountController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _validationError = null;
      _isValid = true;

      final fluidAmount = double.tryParse(_fluidAmountController.text) ?? 0.0;
      if (fluidAmount < 0.5 || fluidAmount > 99) {
        _validationError = 'Fluid amount must be between 0.5 and 99 mL';
        _isValid = false;
      }

      final targetDose = double.tryParse(_targetDoseController.text) ?? 0.0;
      if (targetDose > 0 && _selectedReconstitution != null) {
        final totalDoses = (widget.medication.quantity * 1000) / targetDose;
        if (totalDoses < 1) {
          _validationError = 'Target dose too high for available quantity';
          _isValid = false;
        }
      }
    });
  }

  Future<void> _saveReconstitution(BuildContext context) async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please correct the input errors')));
      return;
    }

    final fluidAmount = double.parse(_fluidAmountController.text) * _fluidVolumeUnit.toMLFactor;
    final totalDoses = (widget.medication.quantity * 1000) / (_selectedReconstitution!['targetDose'] ?? 1);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.dialogCardDecoration,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm Reconstitution',
                style: AppThemes.dialogTitleStyle,
              ),
              const SizedBox(height: 16),
              const Icon(Icons.science, size: 40, color: AppConstants.primaryColor),
              const SizedBox(height: 8),
              Text(
                'Syringe: ${formatNumber(_selectedReconstitution!['syringeUnits'])} IU (${formatNumber(_selectedReconstitution!['volume'])} mL)',
                style: AppThemes.dialogContentStyle,
              ),
              Text(
                'Total Doses Available: ${totalDoses.floor()}',
                style: AppThemes.dialogContentStyle,
              ),
              const SizedBox(height: 16),
              Text(
                'Please verify settings are correct before saving.',
                style: AppThemes.dialogContentStyle.copyWith(color: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppConstants.dialogButtonStyle,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);
    final updatedMedication = widget.medication.copyWith(
      reconstitutionVolume: fluidAmount,
      reconstitutionVolumeUnit: _fluidVolumeUnit.displayName,
      reconstitutionFluid: _reconstitutionFluidController.text,
      selectedReconstitution: _selectedReconstitution,
    );

    final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
    try {
      await medicationPresenter.updateMedication(widget.medication.id, updatedMedication);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/medication_details', arguments: updatedMedication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _calculateReconstitutionSuggestions() {
    final fluidAmount = double.tryParse(_fluidAmountController.text) ?? 0;
    if (fluidAmount < 0.5 || fluidAmount > 99) {
      setState(() {
        _validationError = 'Fluid amount must be between 0.5 and 99 mL';
        _isValid = false;
      });
      return;
    }
    setState(() => _validationError = null);

    final calculator = ReconstitutionCalculator(
      quantityController: TextEditingController(text: widget.medication.quantity.toString()),
      targetDoseController: _targetDoseController,
      quantityUnit: widget.medication.quantityUnit.displayName,
      targetDoseUnit: _targetDoseUnit.displayName,
      medicationName: widget.medication.name,
      syringeSize: _syringeSize == SyringeSize.size0_3
          ? 0.3
          : _syringeSize == SyringeSize.size0_5
          ? 0.5
          : 1.0,
      fixedVolume: fluidAmount,
      fixedVolumeUnit: _fluidVolumeUnit,
    );
    final result = calculator.calculate();
    setState(() {
      _reconstitutionSuggestions = result['suggestions'];
      _selectedReconstitution = result['selectedReconstitution'];
      if (result['error'] != null && context.mounted) {
        _validationError = result['error'];
        _isValid = false;
      }
    });
  }

  void _adjustFluidVolume(double delta) {
    final current = double.tryParse(_fluidAmountController.text) ?? 2;
    final newVolume = (current + delta).clamp(0.5, 99.0);
    _fluidAmountController.text = formatNumber(newVolume);
    _calculateReconstitutionSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medication.type != MedicationType.injection) {
      return Scaffold(
        backgroundColor: AppConstants.backgroundColor,
        body: const Center(child: Text('Reconstitution is only available for injections')),
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
                'Reconstitute ${widget.medication.name}',
                style: AppThemes.reconstitutionTitleStyle,
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  decoration: AppThemes.reconstitutionCardDecoration,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _reconstitutionFluidController,
                        decoration: AppConstants.formFieldDecoration.copyWith(
                          labelText: 'Reconstitution Fluid *',
                          labelStyle: AppThemes.formLabelStyle,
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter a fluid' : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _targetDoseController,
                              decoration: AppConstants.formFieldDecoration.copyWith(
                                labelText: 'Target Dose *',
                                labelStyle: AppThemes.formLabelStyle,
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _calculateReconstitutionSuggestions(),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter a dose';
                                if (double.tryParse(value) == null || double.parse(value)! <= 0) {
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
                                labelStyle: AppThemes.formLabelStyle,
                              ),
                              items: TargetDoseUnit.values
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
                                labelText: 'Fluid Amount *',
                                labelStyle: AppThemes.formLabelStyle,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _adjustFluidVolume(-0.5),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _adjustFluidVolume(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) => _calculateReconstitutionSuggestions(),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please enter an amount';
                                if (double.tryParse(value) == null || double.parse(value)! <= 0) {
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
                                labelStyle: AppThemes.formLabelStyle,
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
                        ],
                      ),
                      if (_validationError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _validationError!,
                          style: AppThemes.reconstitutionErrorStyle,
                        ),
                      ],
                      const SizedBox(height: 16),
                      DropdownButtonFormField<SyringeSize>(
                        value: _syringeSize,
                        decoration: AppConstants.formFieldDecoration.copyWith(
                          labelText: 'Syringe Size',
                          labelStyle: AppThemes.formLabelStyle,
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
                      Text(
                        'Formula: (${formatNumber(widget.medication.quantity)} ${widget.medication.quantityUnit.displayName} * 1000) / ${_fluidAmountController.text} ${_fluidVolumeUnit.displayName} = ${formatNumber((widget.medication.quantity * 1000) / ((double.tryParse(_fluidAmountController.text) ?? 1) * _fluidVolumeUnit.toMLFactor))} mcg/mL',
                        style: AppThemes.compactMedicationCardContentStyle.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Reconstitution Options',
                        style: AppThemes.reconstitutionTitleStyle,
                      ),
                      Text(
                        'Choose based on desired concentration:',
                        style: AppThemes.reconstitutionOptionSubtitleStyle,
                      ),
                      const SizedBox(height: 8),
                      ..._reconstitutionSuggestions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final suggestion = entry.value;
                        final isSelected = _selectedReconstitution == suggestion;
                        final label = index == 0
                            ? 'Target (Balanced)'
                            : index == 1
                            ? 'Lower (More Diluted)'
                            : 'Higher (More Concentrated)';
                        return Container(
                          decoration: isSelected
                              ? AppThemes.reconstitutionSelectedOptionCardDecoration
                              : AppThemes.reconstitutionOptionCardDecoration,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              '$label: ${formatNumber(suggestion['syringeUnits'])} IU',
                              style: AppThemes.reconstitutionOptionTitleStyle.copyWith(
                                color: isSelected ? AppConstants.primaryColor : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Volume: ${formatNumber(suggestion['volume'])} mL\nConcentration: ${formatNumber(suggestion['concentration'])} mcg/mL',
                              style: AppThemes.reconstitutionOptionSubtitleStyle,
                            ),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                            onTap: () {
                              setState(() {
                                _selectedReconstitution = suggestion;
                                _fluidAmountController.text = formatNumber(suggestion['volume']);
                                _targetDoseController.text = formatNumber(suggestion['targetDose']);
                                _targetDoseUnit = TargetDoseUnit.values.firstWhere(
                                      (e) => e.displayName == suggestion['targetDoseUnit'],
                                  orElse: () => TargetDoseUnit.mcg,
                                );
                                _syringeSize = SyringeSize.values.firstWhere(
                                      (e) => e.value == suggestion['syringeSize'],
                                  orElse: () => SyringeSize.size1_0,
                                );
                              });
                            },
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isSaving || !_isValid ? null : () => _saveReconstitution(context),
                          style: AppConstants.actionButtonStyle,
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
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
          if (index == 1) Navigator.pushNamed(context, '/calendar');
          if (index == 2) Navigator.pushNamed(context, '/history');
          if (index == 3) Navigator.pushNamed(context, '/settings');
        },
      ),
    );
  }
}