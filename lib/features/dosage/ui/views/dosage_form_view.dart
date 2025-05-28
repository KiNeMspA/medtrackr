// lib/features/dosage/ui/views/dosage_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.medication == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
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
      _amountController.text = widget.dosage!.totalDose.toString();
      _doseUnit = widget.dosage!.doseUnit;
      _method = widget.dosage!.method;
      _nameController.text = widget.dosage!.name;
      _tabletCountController.text = isTabletOrCapsule ? widget.dosage!.totalDose.toInt().toString() : '';
      _iuController.text = isInjection && isReconstituted ? widget.dosage!.insulinUnits.toString() : '';
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
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _tabletCountController.dispose();
    _iuController.dispose();
    super.dispose();
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isReconstituted = widget.medication!.reconstitutionVolume > 0;

    if (isInjection && !isReconstituted && widget.medication!.quantityUnit != QuantityUnit.mL) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppThemes.warningBackgroundColor,
          title: Text('Volume Required', style: AppThemes.warningTitleStyle),
          content: Text('Non-reconstituted injections require a volume in mL.', style: AppThemes.warningContentTextStyle),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: AppConstants.dialogButtonStyle,
              child: const Text('Edit Medication'),
            ),
          ],
        ),
      );
      setState(() => _isSaving = false);
      if (confirmed == true) {
        Navigator.pushNamed(context, '/medication_form', arguments: widget.medication);
      }
      return;
    }

    double amount = 0.0;
    double insulinUnits = 0.0;
    if (isTabletOrCapsule) {
      final tabletCount = double.tryParse(_tabletCountController.text) ?? 0.0;
      if (tabletCount <= 0 || widget.medication!.dosePerTablet == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid tablet count or dose per tablet')));
        setState(() => _isSaving = false);
        return;
      }
      amount = tabletCount * widget.medication!.dosePerTablet!;
    } else if (isInjection && isReconstituted) {
      insulinUnits = double.tryParse(_iuController.text) ?? 0.0;
      if (insulinUnits <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid IU amount')));
        setState(() => _isSaving = false);
        return;
      }
      amount = widget.medication!.selectedReconstitution != null
          ? insulinUnits * (widget.medication!.selectedReconstitution!['concentration']?.toDouble() ?? 1.0) / 100
          : 0.0;
    } else {
      amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid dosage amount')));
        setState(() => _isSaving = false);
        return;
      }
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
    if (widget.medication == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.dosage == null ? 'Add Dosage' : 'Edit Dosage'),
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
                  'Dosage Details for ${widget.medication!.name}',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
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
                  onSyringeSizeChanged: (_) {}, // No-op, handled by Medication
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveDosage(context),
                    style: AppConstants.actionButtonStyle,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Dosage'),
                  ),
                ),
              ],
            ),
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