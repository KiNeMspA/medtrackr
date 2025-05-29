// lib/features/medication/ui/views/medication_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/core/widgets/confirm_medication_dialog.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';

class MedicationFormView extends StatefulWidget {
  final Medication? medication;

  const MedicationFormView({super.key, this.medication});

  @override
  _MedicationFormViewState createState() => _MedicationFormViewState();
}

class _MedicationFormViewState extends State<MedicationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _dosePerTabletController = TextEditingController();
  final _dosePerCapsuleController = TextEditingController();
  final _notesController = TextEditingController();
  MedicationType? _type;
  QuantityUnit _quantityUnit = QuantityUnit.mg;
  QuantityUnit _dosePerTabletUnit = QuantityUnit.mg;
  QuantityUnit _dosePerCapsuleUnit = QuantityUnit.mg;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _quantityController.text = formatNumber(widget.medication!.quantity);
      _type = widget.medication!.type;
      _quantityUnit = widget.medication!.quantityUnit;
      _dosePerTabletController.text = widget.medication!.dosePerTablet != null
          ? formatNumber(widget.medication!.dosePerTablet!)
          : '';
      _dosePerTabletUnit =
          widget.medication!.dosePerTabletUnit ?? QuantityUnit.mg;
      _dosePerCapsuleController.text = widget.medication!.dosePerCapsule != null
          ? formatNumber(widget.medication!.dosePerCapsule!)
          : '';
      _dosePerCapsuleUnit =
          widget.medication!.dosePerCapsuleUnit ?? QuantityUnit.mg;
      _notesController.text = widget.medication!.notes;
    } else {
      _quantityUnit = QuantityUnit.mg;
      _dosePerTabletUnit = QuantityUnit.mg;
      _dosePerCapsuleUnit = QuantityUnit.mg;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _dosePerTabletController.dispose();
    _dosePerCapsuleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please correct the input errors')));
      return;
    }

    setState(() => _isSaving = true);
    final isDark = Provider
        .of<ThemeProvider>(context, listen: false)
        .isDarkMode;
    final navigationService = Provider.of<NavigationService>(
        context, listen: false);
    final isTabletOrCapsule = _type == MedicationType.tablet ||
        _type == MedicationType.capsule;
    QuantityUnit unit = isTabletOrCapsule
        ? QuantityUnit.tablets
        : _quantityUnit;

    final medication = Medication(
      id: widget.medication?.id ?? DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      name: _nameController.text,
      type: _type!,
      quantity: double.parse(_quantityController.text),
      quantityUnit: unit,
      remainingQuantity: widget.medication?.remainingQuantity ??
          double.parse(_quantityController.text),
      dosePerTablet: _type == MedicationType.tablet ? double.tryParse(
          _dosePerTabletController.text) : null,
      dosePerTabletUnit: _type == MedicationType.tablet
          ? _dosePerTabletUnit
          : null,
      dosePerCapsule: _type == MedicationType.capsule ? double.tryParse(
          _dosePerCapsuleController.text) : null,
      dosePerCapsuleUnit: _type == MedicationType.capsule
          ? _dosePerCapsuleUnit
          : null,
      notes: _notesController.text,
      reconstitutionFluid: widget.medication?.reconstitutionFluid ?? '',
      reconstitutionVolume: widget.medication?.reconstitutionVolume ?? 0.0,
      reconstitutionVolumeUnit: widget.medication?.reconstitutionVolumeUnit ??
          '',
      selectedReconstitution: widget.medication?.selectedReconstitution,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) =>
          ConfirmMedicationDialog(
            medication: medication,
            isTabletOrCapsule: isTabletOrCapsule,
            type: _type!,
            onConfirm: () => Navigator.pop(context, true),
            onCancel: () => Navigator.pop(context, false),
            isDark: isDark,
          ),
    );

    if (confirmed != true) {
      setState(() => _isSaving = false);
      return;
    }

    final medicationPresenter = Provider.of<MedicationPresenter>(
        context, listen: false);
    try {
      if (widget.medication == null) {
        await medicationPresenter.addMedication(medication);
      } else {
        await medicationPresenter.updateMedication(medication.id, medication);
      }
      if (context.mounted) {
        navigationService.replaceWith(
            '/medication_details', arguments: medication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider
        .of<ThemeProvider>(context)
        .isDarkMode;
    final navigationService = Provider.of<NavigationService>(
        context, listen: false);
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(
            widget.medication == null ? 'Add Medication' : 'Edit Medication',
            style: const TextStyle(fontFamily: 'Inter')),
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
                DropdownButtonFormField<MedicationType>(
                  value: _type,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Medication Type',
                    labelStyle: AppThemes.formLabelStyle(isDark),
                  ),
                  items: MedicationType.values
                      .map((type) =>
                      DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName, style: const TextStyle(
                            fontFamily: 'Inter')),
                      ))
                      .toList(),
                  onChanged: (value) => setState(() => _type = value),
                  validator: (value) =>
                  value == null
                      ? 'Please select a type'
                      : null,
                ),
                if (_type != null) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: AppConstants
                        .formFieldDecoration(isDark)
                        .copyWith(
                      labelText: 'Medication Name',
                      labelStyle: AppThemes.formLabelStyle(isDark),
                    ),
                    validator: Validators.required,
                  ),
                  const SizedBox(height: 16),
                  if (_type == MedicationType.injection) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: AppConstants.infoCardDecoration(isDark),
                      child: Text(
                        'Note: If you plan to reconstitute, the volume will be updated automatically. Otherwise, a volume in mL will be required.',
                        style: AppConstants.infoTextStyle(isDark),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: AppConstants
                              .formFieldDecoration(isDark)
                              .copyWith(
                            labelText: 'Quantity',
                            labelStyle: AppThemes.formLabelStyle(isDark),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validators.positiveNumber(value, 'Quantity'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<QuantityUnit>(
                          value: (_type == MedicationType.tablet ||
                              _type == MedicationType.capsule) ? QuantityUnit
                              .tablets : _quantityUnit,
                          decoration: AppConstants
                              .formFieldDecoration(isDark)
                              .copyWith(
                            labelText: 'Unit',
                            labelStyle: AppThemes.formLabelStyle(isDark),
                          ),
                          items: (_type == MedicationType.tablet ||
                              _type == MedicationType.capsule)
                              ? [QuantityUnit.tablets]
                              .map((unit) =>
                              DropdownMenuItem<QuantityUnit>(
                                value: unit,
                                child: Text(unit.displayName,
                                    style: const TextStyle(
                                        fontFamily: 'Inter')),
                              ))
                              .toList()
                              : [
                            QuantityUnit.mg,
                            QuantityUnit.g,
                            QuantityUnit.mcg,
                            QuantityUnit.mL
                          ]
                              .map((unit) =>
                              DropdownMenuItem<QuantityUnit>(
                                value: unit,
                                child: Text(unit.displayName,
                                    style: const TextStyle(
                                        fontFamily: 'Inter')),
                              ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() =>
                              _quantityUnit = value ?? _quantityUnit),
                          validator: (value) =>
                          value == null
                              ? 'Please select a unit'
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
                if (_type == MedicationType.tablet || _type == MedicationType.capsule) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _type == MedicationType.tablet ? _dosePerTabletController : _dosePerCapsuleController,
                          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                            labelText: _type == MedicationType.tablet ? 'Dose per Tablet' : 'Dose per Capsule',
                            labelStyle: AppThemes.formLabelStyle(isDark),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => Validators.positiveNumber(value, 'Dose'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<QuantityUnit>(
                          value: _type == MedicationType.tablet ? _dosePerTabletUnit : _dosePerCapsuleUnit,
                          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                            labelText: 'Unit',
                            labelStyle: AppThemes.formLabelStyle(isDark),
                          ),
                          items: [QuantityUnit.mg, QuantityUnit.g, QuantityUnit.mcg]
                              .map((unit) => DropdownMenuItem<QuantityUnit>(
                            value: unit,
                            child: Text(unit.displayName, style: const TextStyle(fontFamily: 'Inter')),
                          ))
                              .toList(),
                          onChanged: _type == MedicationType.tablet
                              ? (value) => setState(() => _dosePerTabletUnit = value ?? _dosePerTabletUnit)
                              : (value) => setState(() => _dosePerCapsuleUnit = value ?? _dosePerCapsuleUnit),
                          validator: (value) => value == null ? 'Please select a unit' : null,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Notes (Optional)',
                    labelStyle: AppThemes.formLabelStyle(isDark),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveMedication(context),
                    style: AppConstants.actionButtonStyle(),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Medication', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ),
              ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Notes (Optional)',
                    labelStyle: AppThemes.formLabelStyle(isDark),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () =>
                        _saveMedication(context),
                    style: AppConstants.actionButtonStyle(),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Medication',
                        style: TextStyle(fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
    ,
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