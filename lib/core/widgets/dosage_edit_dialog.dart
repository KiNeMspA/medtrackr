// lib/core/widgets/dosage_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/core/widgets/dosage_form_fields.dart';
import 'package:medtrackr/features/medication/models/medication.dart';

class DosageEditDialog extends StatefulWidget {
  final Dosage dosage;
  final Medication medication;
  final Function(Dosage) onSave;
  final bool isInjection;
  final bool isTabletOrCapsule;
  final bool isReconstituted;
  final bool isDark;

  const DosageEditDialog({
    super.key,
    required this.dosage,
    required this.medication,
    required this.onSave,
    required this.isInjection,
    required this.isTabletOrCapsule,
    required this.isReconstituted,
    required this.isDark,
  });

  @override
  _DosageEditDialogState createState() => _DosageEditDialogState();
}

class _DosageEditDialogState extends State<DosageEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _tabletCountController;
  late TextEditingController _iuController;
  late String _doseUnit;
  late DosageMethod _method;
  String? _validationError;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.dosage.name);
    _doseController = TextEditingController(text: formatNumber(widget.dosage.totalDose));
    _tabletCountController = TextEditingController(
      text: widget.isTabletOrCapsule ? widget.dosage.totalDose.toInt().toString() : '',
    );
    _iuController = TextEditingController(
      text: widget.isInjection && widget.isReconstituted ? formatNumber(widget.dosage.insulinUnits) : '',
    );
    _doseUnit = widget.dosage.doseUnit;
    _method = widget.dosage.method;

    _tabletCountController.addListener(_validateInput);
    _iuController.addListener(_validateInput);
    _doseController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _tabletCountController.dispose();
    _iuController.dispose();
    super.dispose();
  }

  void _validateInput() {
    setState(() {
      _validationError = null;
      _isValid = true;

      if (widget.isTabletOrCapsule && _tabletCountController.text.isNotEmpty) {
        final tabletCount = double.tryParse(_tabletCountController.text) ?? 0.0;
        if (tabletCount <= 0) {
          _validationError = 'Please enter a valid positive number';
          _isValid = false;
        } else if (tabletCount > widget.medication.remainingQuantity) {
          _validationError = 'Dosage exceeds remaining stock (${formatNumber(widget.medication.remainingQuantity)} ${widget.medication.quantityUnit.displayName})';
          _isValid = false;
        }
      } else if (widget.isInjection && widget.isReconstituted && _iuController.text.isNotEmpty) {
        final insulinUnits = double.tryParse(_iuController.text) ?? 0.0;
        if (insulinUnits <= 0) {
          _validationError = 'Invalid IU amount';
          _isValid = false;
        } else {
          final amount = widget.medication.selectedReconstitution != null
              ? insulinUnits * (widget.medication.selectedReconstitution!['concentration']?.toDouble() ?? 1.0) / 100
              : 0.0;
          if (amount > widget.medication.remainingQuantity) {
            _validationError = 'Dosage exceeds remaining stock (${formatNumber(widget.medication.remainingQuantity)} mg)';
            _isValid = false;
          }
        }
      } else if (widget.isInjection && !widget.isReconstituted && _doseController.text.isNotEmpty) {
        final amount = double.tryParse(_doseController.text) ?? 0.0;
        if (amount <= 0) {
          _validationError = 'Invalid dosage amount';
          _isValid = false;
        } else if (amount > widget.medication.remainingQuantity) {
          _validationError = 'Dosage exceeds remaining stock (${formatNumber(widget.medication.remainingQuantity)} ${widget.medication.quantityUnit.displayName})';
          _isValid = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.backgroundColor(widget.isDark),
      title: const Text('Edit Dosage', style: TextStyle(fontFamily: 'Poppins')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DosageFormFields(
                nameController: _nameController,
                amountController: _doseController,
                tabletCountController: _tabletCountController,
                iuController: _iuController,
                doseUnit: _doseUnit,
                method: _method,
                syringeSize: widget.medication.selectedReconstitution?['syringeSize'] != null
                    ? SyringeSize.values.firstWhere(
                      (e) => e.value == widget.medication.selectedReconstitution!['syringeSize'],
                  orElse: () => SyringeSize.size1_0,
                )
                    : null,
                isInjection: widget.isInjection,
                isTabletOrCapsule: widget.isTabletOrCapsule,
                isReconstituted: widget.isReconstituted,
                medication: widget.medication,
                onDoseUnitChanged: (value) => setState(() => _doseUnit = value ?? _doseUnit),
                onMethodChanged: (value) => setState(() => _method = value ?? _method),
                onSyringeSizeChanged: (_) {},
                isDark: widget.isDark,
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _validationError!,
                  style: const TextStyle(fontSize: 14, color: AppConstants.errorColor, fontFamily: 'Poppins'),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor(widget.isDark), fontFamily: 'Poppins')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _isValid) {
              final amount = widget.isTabletOrCapsule
                  ? double.tryParse(_tabletCountController.text) ?? widget.dosage.totalDose
                  : double.tryParse(_doseController.text) ?? widget.dosage.totalDose;
              final insulinUnits = widget.isInjection && widget.isReconstituted
                  ? double.tryParse(_iuController.text) ?? widget.dosage.insulinUnits
                  : widget.dosage.insulinUnits;
              final updatedDosage = widget.dosage.copyWith(
                name: _nameController.text,
                doseUnit: _doseUnit,
                totalDose: amount,
                volume: widget.isInjection
                    ? (widget.isReconstituted && widget.medication.selectedReconstitution != null
                    ? insulinUnits / (widget.medication.selectedReconstitution!['concentration']?.toDouble() ?? 1.0) * 100
                    : amount)
                    : 0.0,
                insulinUnits: insulinUnits,
                method: _method,
              );
              widget.onSave(updatedDosage);
              Navigator.pop(context);
            }
          },
          style: AppConstants.dialogButtonStyle(),
          child: const Text('Save', style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}