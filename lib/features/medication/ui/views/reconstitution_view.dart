// lib/features/medication/ui/views/reconstitution_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
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
  String? _selectedFluidType;

  @override
  void initState() {
    super.initState();
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (widget.medication.type != MedicationType.injection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationService.replaceWith('/home');
      });
      return;
    }
    _reconstitutionFluidController.text = widget.medication.reconstitutionFluid.isNotEmpty
        ? widget.medication.reconstitutionFluid
        : 'Bacteriostatic Water';
    _selectedFluidType = _reconstitutionFluidController.text;
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

    _fluidAmountController.addListener(_validateInput);
    _targetDoseController.addListener(() {
      final value = double.tryParse(_targetDoseController.text);
      if (value != null) {
        _targetDose = value;
        _calculateReconstitutionSuggestions();
      }
    });
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

      if (_fluidAmountController.text.isNotEmpty && _selectedReconstitution != null) {
        final fluidAmount = double.tryParse(_fluidAmountController.text) ?? 0.0;
        final syringeUnits = _selectedReconstitution!['syringeUnits']?.toDouble() ?? 0.0;
        final maxIU = _syringeSize.maxIU;
        final minIU = maxIU * 0.05;

        if (fluidAmount < 0.5 || fluidAmount > 99) {
          _validationError = 'Fluid amount must be between 0.5 and 99 mL';
          _isValid = false;
        } else if (syringeUnits > maxIU) {
          _validationError = 'IU (${formatNumber(syringeUnits)}) exceeds syringe capacity (${formatNumber(maxIU)} IU)';
          _isValid = false;
        } else if (syringeUnits < minIU) {
          _validationError = 'IU (${formatNumber(syringeUnits)}) below minimum (${formatNumber(minIU)} IU)';
          _isValid = false;
        }
      }
    });
  }

  Future<void> _saveReconstitution(BuildContext context) async {
    if (!_isValid || _targetDoseController.text.isEmpty || _fluidAmountController.text.isEmpty || _selectedReconstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please correct the input errors')));
      return;
    }

    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final fluidAmount = double.parse(_fluidAmountController.text) * _fluidVolumeUnit.toMLFactor;
    final totalDoses = (widget.medication.quantity * 1000) / (_selectedReconstitution!['targetDose'] ?? 1);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.dialogCardDecoration(isDark),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Confirm Reconstitution',
                style: AppThemes.dialogTitleStyle(isDark),
              ),
              const SizedBox(height: 12),
              Icon(Icons.science, size: 36, color: AppConstants.primaryColor),
              const SizedBox(height: 8),
              Text(
                'Syringe: ${formatNumber(_selectedReconstitution!['syringeUnits'])} IU (${formatNumber(_selectedReconstitution!['volume'])} mL)',
                style: AppThemes.dialogContentStyle(isDark),
              ),
              Text(
                'Total Doses: ${totalDoses.floor()}',
                style: AppThemes.dialogContentStyle(isDark),
              ),
              const SizedBox(height: 12),
              Text(
                'Verify settings before saving.',
                style: AppThemes.dialogContentStyle(isDark).copyWith(color: AppConstants.errorColor),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppConstants.accentColor(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: AppConstants.dialogButtonStyle(),
                    child: const Text('Confirm', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        navigationService.replaceWith('/medication_details', arguments: updatedMedication);
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
    try {
      final fluidAmount = double.tryParse(_fluidAmountController.text);
      if (fluidAmount == null || fluidAmount <= 0 || fluidAmount.isNaN || fluidAmount.isInfinite) {
        setState(() {
          _validationError = 'Please enter a valid fluid amount';
          _isValid = false;
        });
        return;
      }
      if (fluidAmount < 0.5 || fluidAmount > 99) {
        setState(() {
          _validationError = 'Fluid amount must be between 0.5 and 99 mL';
          _isValid = false;
        });
        return;
      }

      final calculator = ReconstitutionCalculator(
        quantityController: TextEditingController(text: widget.medication.quantity.toString()),
        targetDoseController: _targetDoseController,
        quantityUnit: widget.medication.quantityUnit.displayName,
        targetDoseUnit: _targetDoseUnit,
        fluidAmount: fluidAmount,
      );

      final suggestions = calculator.calculateReconstitutions();
      // Ensure 5.0 mL syringe appears by manually adding if missing
      final hasFiveMLSyringe = suggestions.any((s) => SyringeSize.values.firstWhere((e) => e.value == s['syringeSize']).maxVolume == 5.0);
      if (!hasFiveMLSyringe && fluidAmount >= 5.0) {
        final fiveMLSyringe = SyringeSize.values.firstWhere((e) => e.maxVolume == 5.0);
        final maxIU = fiveMLSyringe.maxIU;
        double volume = _targetDose / ((widget.medication.quantity * 1000) / fluidAmount);
        double syringeUnits = (volume / fiveMLSyringe.maxVolume) * maxIU;
        if (syringeUnits <= maxIU && syringeUnits >= maxIU * 0.05) {
          suggestions.add({
            'syringeSize': fiveMLSyringe.value,
            'syringeUnits': syringeUnits,
            'volume': volume,
            'targetDose': _targetDose,
            'targetDoseUnit': _targetDoseUnit.displayName,
            'concentration': (widget.medication.quantity * 1000) / fluidAmount,
          });
        }
      }

      // Sort suggestions by syringe size
      suggestions.sort((a, b) => (a['syringeUnits'] as double).compareTo(b['syringeUnits'] as double));
      setState(() {
        _reconstitutionSuggestions = suggestions;
        _validationError = null;
        _isValid = true;
      });
    } catch (e) {
      setState(() {
        _validationError = 'Error calculating reconstitution: $e';
        _isValid = false;
      });
    }
  }

  void _incrementField(TextEditingController controller, {double step = 1.0}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue + step).clamp(0.0, 999.0);
    controller.text = formatNumber(newValue);
    _calculateReconstitutionSuggestions();
  }

  void _decrementField(TextEditingController controller, {double step = 1.0}) {
    final currentValue = double.tryParse(controller.text) ?? 0.0;
    final newValue = (currentValue - step).clamp(0.0, 999.0);
    controller.text = formatNumber(newValue);
    _calculateReconstitutionSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (widget.medication.type != MedicationType.injection) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: const Text('Reconstitute Medication', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reconstitute ${widget.medication.name}',
                style: AppThemes.reconstitutionTitleStyle(isDark),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: AppThemes.reconstitutionCardDecoration(isDark),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reconstitution Fluid Name
                    TextFormField(
                      controller: _reconstitutionFluidController,
                      decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                        labelText: 'Reconstitution Fluid Name',
                        labelStyle: AppThemes.formLabelStyle(isDark),
                        hintText: 'e.g., Bacteriostatic Water',
                      ),
                      validator: Validators.required,
                      onChanged: (value) => setState(() => _selectedFluidType = value),
                    ),
                    const SizedBox(height: 16),
                    // Fluid Type Tracker (Dropdown for common fluids)
                    DropdownButtonFormField<String>(
                      value: _selectedFluidType,
                      decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                        labelText: 'Fluid Type',
                        labelStyle: AppThemes.formLabelStyle(isDark),
                      ),
                      items: ['Bacteriostatic Water', 'Saline', 'Sterile Water']
                          .map((fluid) => DropdownMenuItem(
                        value: fluid,
                        child: Text(fluid, style: const TextStyle(fontFamily: 'Inter')),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedFluidType = value;
                            _reconstitutionFluidController.text = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Target Dose with Up/Down Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _targetDoseController,
                            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                              labelText: 'Target Dose',
                              labelStyle: AppThemes.formLabelStyle(isDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => Validators.positiveNumber(value, 'Target Dose'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_up, size: 20),
                              color: AppConstants.primaryColor,
                              onPressed: () => _incrementField(_targetDoseController, step: 10.0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              color: AppConstants.primaryColor,
                              onPressed: () => _decrementField(_targetDoseController, step: 10.0),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<TargetDoseUnit>(
                            value: _targetDoseUnit,
                            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                              labelText: 'Unit',
                              labelStyle: AppThemes.formLabelStyle(isDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            items: TargetDoseUnit.values
                                .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Inter')),
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
                            validator: (value) => value == null ? 'Please select a unit' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Fluid Amount with Up/Down Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fluidAmountController,
                            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                              labelText: 'Fluid Amount',
                              labelStyle: AppThemes.formLabelStyle(isDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => Validators.rangeNumber(value, 0.5, 99, 'Fluid Amount'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_up, size: 20),
                              color: AppConstants.primaryColor,
                              onPressed: () => _incrementField(_fluidAmountController, step: 0.5),
                            ),
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              color: AppConstants.primaryColor,
                              onPressed: () => _decrementField(_fluidAmountController, step: 0.5),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 100,
                          child: DropdownButtonFormField<FluidUnit>(
                            value: _fluidVolumeUnit,
                            decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                              labelText: 'Unit',
                              labelStyle: AppThemes.formLabelStyle(isDark),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            items: FluidUnit.values
                                .map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Inter')),
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
                            validator: (value) => value == null ? 'Please select a unit' : null,
                          ),
                        ),
                      ],
                    ),
                    if (_validationError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _validationError!,
                        style: AppThemes.reconstitutionErrorStyle(isDark),
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SyringeSize>(
                      value: _syringeSize,
                      decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                        labelText: 'Syringe Size',
                        labelStyle: AppThemes.formLabelStyle(isDark),
                      ),
                      items: SyringeSize.values
                          .map((size) => DropdownMenuItem(
                        value: size,
                        child: Text(size.displayName, style: const TextStyle(fontFamily: 'Inter')),
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
                      validator: (value) => value == null ? 'Please select a syringe size' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: AppThemes.compactMedicationCardDecoration(isDark),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.medication.name,
                          style: AppThemes.reconstitutionTitleStyle(isDark),
                        ),
                        Text(
                          'Reconstituted Medication',
                          style: AppThemes.compactMedicationCardContentStyle(isDark).copyWith(color: AppConstants.textSecondary(isDark)),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Dosage Options',
                          style: AppThemes.reconstitutionOptionSubtitleStyle(isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_reconstitutionSuggestions.isNotEmpty) ...[
                Text(
                  'Dosage Options',
                  style: AppConstants.cardTitleStyle(isDark),
                ),
                const SizedBox(height: 8),
                ..._reconstitutionSuggestions.map((suggestion) {
                  final isSelected = _selectedReconstitution == suggestion;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedReconstitution = suggestion;
                        _validateInput();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: isSelected
                          ? AppThemes.reconstitutionSelectedOptionCardDecoration(isDark)
                          : AppThemes.reconstitutionOptionCardDecoration(isDark),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${formatNumber(suggestion['syringeUnits'])} IU',
                            style: AppThemes.reconstitutionOptionTitleStyle(isDark).copyWith(
                              color: isSelected ? AppConstants.primaryColor : AppConstants.textPrimary(isDark),
                            ),
                          ),
                          Text(
                            '${formatNumber(suggestion['volume'])} mL',
                            style: AppThemes.reconstitutionOptionSubtitleStyle(isDark),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ] else ...[
                Text(
                  'No dosage options available.',
                  style: AppConstants.cardBodyStyle(isDark),
                ),
              ],
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving || !_isValid ? null : () => _saveReconstitution(context),
                  style: AppConstants.actionButtonStyle(),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Reconstitution', style: TextStyle(fontFamily: 'Inter')),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == 0) navigationService.replaceWith('/home');
            if (index == 1) navigationService.navigateTo('/calendar');
            if (index == 2) navigationService.navigateTo('/history');
            if (index == 3) navigationService.navigateTo('/settings');
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        backgroundColor: isDark ? AppConstants.cardColorDark : Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight,
      ),
    );
  }
}d