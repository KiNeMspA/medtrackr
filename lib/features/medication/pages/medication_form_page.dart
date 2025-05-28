// In lib/features/medication/pages/medication_form_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/widgets/dialogs/confirm_medication_dialog.dart';
import 'package:medtrackr/core/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/core/widgets/forms/medication_form_fields.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/providers/medication_provider.dart';


class MedicationFormPage extends StatefulWidget {
  final Medication? medication;

  const MedicationFormPage({super.key, this.medication});

  @override
  _MedicationFormPageState createState() => _MedicationFormPageState();
}

class _MedicationFormPageState extends State<MedicationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _tabletCountController;
  late TextEditingController _volumeController;
  late TextEditingController _dosePerTabletController;
  late TextEditingController _notesController;

  String _formatNumber(double value) => formatNumber(value);
  MedicationType? _type;
  QuantityUnit _quantityUnit = QuantityUnit.mg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.medication?.quantity != null &&
            widget.medication!.type == MedicationType.injection &&
            widget.medication!.quantityUnit != QuantityUnit.mL
            ? widget.medication!.quantity.toStringAsFixed(2)
            : '');
    _tabletCountController = TextEditingController(
        text: widget.medication?.quantity != null &&
            (widget.medication!.type == MedicationType.tablet ||
                widget.medication!.type == MedicationType.capsule)
            ? widget.medication!.quantity.toInt().toString()
            : '');
    _volumeController = TextEditingController(
        text: widget.medication?.quantity != null &&
            widget.medication!.type == MedicationType.injection
            ? widget.medication!.quantity.toStringAsFixed(2)
            : '');
    _dosePerTabletController = TextEditingController(
        text: widget.medication != null &&
            (widget.medication!.type == MedicationType.tablet ||
                widget.medication!.type == MedicationType.capsule)
            ? formatNumber(widget.medication!.dosePerTablet ??
            widget.medication!.dosePerCapsule ??
            0.0)
            : '');
    _notesController = TextEditingController(text: widget.medication?.notes ?? '');
    if (widget.medication != null) {
      _type = widget.medication!.type;
      _quantityUnit = widget.medication!.quantityUnit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _tabletCountController.dispose();
    _volumeController.dispose();
    _dosePerTabletController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final isTabletOrCapsule =
        _type == MedicationType.tablet || _type == MedicationType.capsule;
    final isInjection = _type == MedicationType.injection;
    double quantity = isTabletOrCapsule
        ? double.tryParse(_tabletCountController.text) ?? 0.0
        : isInjection && _quantityUnit == QuantityUnit.mL
        ? double.tryParse(_volumeController.text) ?? 0.0
        : double.tryParse(_quantityController.text) ?? 0.0;
    QuantityUnit unit = isTabletOrCapsule ? QuantityUnit.tablets : _quantityUnit;

    final medication = Medication(
      id: widget.medication?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _type!,
      quantityUnit: unit,
      quantity: quantity,
      remainingQuantity: quantity,
      reconstitutionVolumeUnit: '',
      reconstitutionVolume: 0.0,
      reconstitutionFluid: '',
      notes: _notesController.text,
      dosePerTablet: isTabletOrCapsule && _type == MedicationType.tablet
          ? double.tryParse(_dosePerTabletController.text) ?? 0.0
          : null,
      dosePerCapsule: isTabletOrCapsule && _type == MedicationType.capsule
          ? double.tryParse(_dosePerTabletController.text) ?? 0.0
          : null,
      dosePerTabletUnit: isTabletOrCapsule && _type == MedicationType.tablet
          ? _quantityUnit
          : null,
      dosePerCapsuleUnit: isTabletOrCapsule && _type == MedicationType.capsule
          ? _quantityUnit
          : null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmMedicationDialog(
        medication: medication,
        isTabletOrCapsule: isTabletOrCapsule,
        type: _type,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (confirmed != true) return;

    final medicationProvider =
    Provider.of<MedicationProvider>(context, listen: false);
    try {
      if (widget.medication == null) {
        await medicationProvider.addMedication(medication);
      } else {
        await medicationProvider.updateMedication(medication.id, medication);
      }
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/medication_details',
          arguments: medication,
        );
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
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.medication == null
            ? 'Add Medication'
            : 'Edit Medication'),
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
                DropdownButtonFormField<MedicationType>(
                  value: _type,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Select a Medication Type *',
                  ),
                  items: [
                    MedicationType.tablet,
                    MedicationType.capsule,
                    MedicationType.injection,
                  ]
                      .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _type = value;
                      _quantityUnit = value == MedicationType.tablet ||
                          value == MedicationType.capsule
                          ? QuantityUnit.mg
                          : QuantityUnit.mg;
                    });
                  },
                  validator: (value) =>
                  value == null ? 'Please select a type' : null,
                ),
                if (_type != null) ...[
                  const SizedBox(height: 16),
                  MedicationFormFields(
                    nameController: _nameController,
                    quantityController: _quantityController,
                    tabletCountController: _tabletCountController,
                    volumeController: _volumeController,
                    dosePerTabletController: _dosePerTabletController,
                    notesController: _notesController,
                    quantityUnit: _quantityUnit,
                    type: _type!,
                    onNameChanged: (value) {},
                    onTypeChanged: (value) {},
                    onQuantityUnitChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _quantityUnit = value;
                        });
                      }
                    },
                    onQuantityChanged: () {},
                  ),
                  if (widget.medication == null) ...[
                    const SizedBox(height: 24),
                    Container(
                      decoration: AppThemes.informationCardDecoration,
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _type == MedicationType.injection
                            ? 'Save Medication to proceed to Medication Overview where you can calculate reconstitution, add dosages and setup schedules.'
                            : 'Save Medication to proceed to Medication Overview where you can add dosages and setup schedules.',
                        style: AppConstants.infoTextStyle,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed:
                    _type == null ? null : () => _saveMedication(context),
                    style: AppConstants.actionButtonStyle,
                    child: const Text('Save Medication'),
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