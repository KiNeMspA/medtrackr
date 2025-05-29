// lib/features/dosage/ui/views/dosage_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/core/widgets/dosage_form_fields.dart';
import 'package:medtrackr/core/widgets/confirm_dosage_dialog.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';

class DosageFormView extends StatefulWidget {
  final Medication? medication;
  final Dosage? dosage;

  const DosageFormView({super.key, this.medication, this.dosage});

  @override
  _DosageFormViewState createState() => _DosageFormViewState();
}

class _DosageFormViewState extends State<DosageFormView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _tabletCountController = TextEditingController();
  final _iuController = TextEditingController();
  late bool isReconstituted;
  String _doseUnit = 'mg';
  DosageMethod _method = DosageMethod.oral;
  bool _isSaving = false;
  int _doseCount = 0;
  String? _validationError;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (widget.medication == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationService.replaceWith('/home');
      });
      return;
    }
    isReconstituted = widget.medication!.reconstitutionVolume > 0;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;
    final recon = widget.medication!.selectedReconstitution;
    final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
    _doseCount = dosagePresenter.getDosagesForMedication(widget.medication!.id).length + 1;

    if (widget.dosage != null) {
      _amountController.text = formatNumber(widget.dosage!.totalDose);
      _doseUnit = widget.dosage!.doseUnit;
      _method = widget.dosage!.method;
      _nameController.text = widget.dosage!.name;
      _tabletCountController.text = isTabletOrCapsule ? widget.dosage!.totalDose.toInt().toString() : '';
      _iuController.text = isInjection && isReconstituted ? formatNumber(widget.dosage!.insulinUnits) : '';
    } else {
      if (isInjection && isReconstituted && recon != null) {
        final targetDose = recon['targetDose']?.toDouble() ?? 0;
        final syringeUnits = recon['syringeUnits']?.toDouble() ?? 0;
        _amountController.text = formatNumber(targetDose);
        _iuController.text = formatNumber(syringeUnits);
        _doseUnit = recon['targetDoseUnit'] ?? 'mcg';
        _nameController.text = '$syringeUnits IU containing $targetDose $_doseUnit';
        _method = DosageMethod.subcutaneous;
      } else if (isTabletOrCapsule) {
        _doseUnit = 'mg';
        _method = DosageMethod.oral;
        _nameController.text = 'Dose $_doseCount';
      } else {
        _doseUnit = 'mg';
        _method = isInjection ? DosageMethod.subcutaneous : DosageMethod.oral;
        _nameController.text = 'Dose $_doseCount';
      }
    }

    _tabletCountController.addListener(_validateInput);
    _iuController.addListener(_validateInput);
    _amountController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _tabletCountController.dispose();
    _iuController.dispose();
    super.dispose();
  }

  void _validateInput() {
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isReconstituted = widget.medication!.reconstitutionVolume > 0;
    setState(() {
      _validationError = null;
      _isValid = true;

      if (isTabletOrCapsule && _tabletCountController.text.isNotEmpty) {
        final tabletCount = double.tryParse(_tabletCountController.text) ?? 0.0;
        if (tabletCount <= 0) {
          _validationError = 'Please enter a valid positive number';
          _isValid = false;
        } else if (tabletCount > widget.medication!.remainingQuantity) {
          _validationError = 'Dosage exceeds remaining stock (${formatNumber(widget.medication!.remainingQuantity)} ${widget.medication!.quantityUnit.displayName})';
          _isValid = false;
        }
      } else if (isInjection && isReconstituted && _iuController.text.isNotEmpty) {
        final insulinUnits = double.tryParse(_iuController.text) ?? 0.0;
        if (insulinUnits <= 0) {
          _validationError = 'Invalid IU amount';
          _isValid = false;
        } else {
          final amount = widget.medication!.selectedReconstitution != null
              ? insulinUnits * (widget.medication!.selectedReconstitution!['concentration']?.toDouble() ?? 1.0) / 100
              : 0.0;
          if (amount > widget.medication!.remainingQuantity) {
            _validationError = 'Dosage exceeds remaining stock (${formatNumber(widget.medication!.remainingQuantity)} mg)';
            _isValid = false;
          }
        }
      } else if (isInjection && !isReconstituted && _amountController.text.isNotEmpty) {
        final amount = double.tryParse(_amountController.text) ?? 0.0;
        if (amount <= 0) {
          _validationError = 'Invalid dosage amount';
          _isValid = false;
        } else if (amount > widget.medication!.remainingQuantity) {
          _validationError = 'Dosage exceeds remaining stock (${formatNumber(widget.medication!.remainingQuantity)} ${widget.medication!.quantityUnit.displayName})';
          _isValid = false;
        }
      }
    });
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (!_formKey.currentState!.validate() || !_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please correct the input errors')));
      return;
    }

    setState(() => _isSaving = true);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isReconstituted = widget.medication!.reconstitutionVolume > 0;

    if (isInjection && !isReconstituted && widget.medication!.quantityUnit != QuantityUnit.mL) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Volume Required',
                  style: AppThemes.dialogTitleStyle(isDark),
                ),
                const SizedBox(height: 12),
                Text(
                  'Non-reconstituted injections require a volume in mL.',
                  style: AppThemes.dialogContentStyle(isDark),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppConstants.accentColor(isDark), fontFamily: 'Inter'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: AppConstants.dialogButtonStyle(),
                      child: const Text('Edit Medication', style: TextStyle(fontFamily: 'Inter')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      setState(() => _isSaving = false);
      if (confirmed == true) {
        navigationService.navigateTo('/medication_form', arguments: widget.medication);
      }
      return;
    }

    double amount = 0.0;
    double insulinUnits = 0.0;
    if (isTabletOrCapsule) {
      final tabletCount = double.tryParse(_tabletCountController.text) ?? 0.0;
      amount = tabletCount;
    } else if (isInjection && isReconstituted) {
      insulinUnits = double.tryParse(_iuController.text) ?? 0.0;
      amount = widget.medication!.selectedReconstitution != null
          ? insulinUnits * (widget.medication!.selectedReconstitution!['concentration']?.toDouble() ?? 1.0) / 100
          : 0.0;
    } else {
      amount = double.tryParse(_amountController.text) ?? 0.0;
    }

    double volume = 0.0;
    if (isInjection && isReconstituted && widget.medication!.selectedReconstitution != null) {
      final concentration = widget.medication!.selectedReconstitution!['concentration']?.toDouble() ?? 1.0;
      volume = insulinUnits / concentration * 100;
    } else if (isInjection) {
      volume = amount;
    }

    final dosage = Dosage(
      id: widget.dosage?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.medication!.id,
      name: _nameController.text.isEmpty ? 'Dose $_doseCount' : _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: amount,
      volume: volume,
      insulinUnits: insulinUnits,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDosageDialog(
        dosage: dosage,
        isTabletOrCapsule: isTabletOrCapsule,
        isInjection: isInjection,
        isReconstituted: isReconstituted,
        medication: widget.medication!,
        insulinUnits: insulinUnits,
        amount: amount,
        volume: volume,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
        isDark: isDark,
      ),
    );

    if (confirmed != true) {
      setState(() => _isSaving = false);
      return;
    }

    final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
    try {
      if (widget.dosage == null) {
        await dosagePresenter.addDosage(dosage);
      } else {
        await dosagePresenter.updateDosage(dosage.id, dosage);
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (widget.medication == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(widget.dosage == null ? 'Add Dosage' : 'Edit Dosage', style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
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
                  'Dosage Details for ${widget.medication!.name}',
                  style: AppConstants.cardTitleStyle(isDark).copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  'Remaining Stock: ${formatNumber(widget.medication!.remainingQuantity)} ${widget.medication!.quantityUnit.displayName}',
                  style: AppConstants.secondaryTextStyle(isDark).copyWith(color: AppConstants.textPrimary(isDark)),
                ),
                const SizedBox(height: 16),
                DosageFormFields(
                  nameController: _nameController,
                  amountController: _amountController,
                  tabletCountController: _tabletCountController,
                  iuController: _iuController,
                  doseUnit: _doseUnit,
                  method: _method,
                  syringeSize: widget.medication!.selectedReconstitution?['syringeSize'] != null
                      ? SyringeSize.values.firstWhere(
                        (e) => e.value == widget.medication!.selectedReconstitution!['syringeSize'],
                    orElse: () => SyringeSize.size1_0,
                  )
                      : null,
                  isInjection: isInjection,
                  isTabletOrCapsule: isTabletOrCapsule,
                  isReconstituted: isReconstituted,
                  medication: widget.medication!,
                  onDoseUnitChanged: (value) {
                    if (value != null) setState(() => _doseUnit = value);
                  },
                  onMethodChanged: (value) => setState(() => _method = value ?? _method),
                  onSyringeSizeChanged: (_) {},
                  isDark: isDark,
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _validationError!,
                    style: AppThemes.reconstitutionErrorStyle(isDark),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving || !_isValid ? null : () => _saveDosage(context),
                    style: AppConstants.actionButtonStyle(),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Dosage', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
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
}