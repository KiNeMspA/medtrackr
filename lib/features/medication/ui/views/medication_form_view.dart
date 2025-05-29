import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/core/services/data_collection_service.dart'; // Added import
import 'package:medtrackr/core/widgets/confirm_medication_dialog.dart';
import 'package:medtrackr/core/widgets/medication_type_dropdown.dart';
import 'package:medtrackr/core/widgets/medication_name_field.dart';
import 'package:medtrackr/core/widgets/injection_warning_card.dart';
import 'package:medtrackr/core/widgets/quantity_input_row.dart';
import 'package:medtrackr/core/widgets/dose_input_row.dart';
import 'package:medtrackr/core/widgets/notes_field.dart';
import 'package:medtrackr/core/widgets/save_button.dart';
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
  late DataCollectionService _dataCollectionService; // Added
  final List<String> _collectedData = []; // Added

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

    // Initialize DataCollectionService
    _dataCollectionService = DataCollectionService();
    _dataCollectionService.setOnDataCollectedCallback((data) {
      setState(() {
        _collectedData.add(data);
      });
    });

    // Fetch initial data
    _fetchCollectedData();
  }

  Future<void> _fetchCollectedData() async {
    final data = await _dataCollectionService.getCollectedData();
    setState(() {
      _collectedData.addAll(data);
    });
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
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final isTabletOrCapsule = _type == MedicationType.tablet || _type == MedicationType.capsule;
    QuantityUnit unit = isTabletOrCapsule ? QuantityUnit.tablets : _quantityUnit;

    final medication = Medication(
      id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _type!,
      quantity: double.parse(_quantityController.text),
      quantityUnit: unit,
      remainingQuantity: widget.medication?.remainingQuantity ??
          double.parse(_quantityController.text),
      dosePerTablet: _type == MedicationType.tablet ? double.tryParse(_dosePerTabletController.text) : null,
      dosePerTabletUnit: _type == MedicationType.tablet ? _dosePerTabletUnit : null,
      dosePerCapsule: _type == MedicationType.capsule ? double.tryParse(_dosePerCapsuleController.text) : null,
      dosePerCapsuleUnit: _type == MedicationType.capsule ? _dosePerCapsuleUnit : null,
      notes: _notesController.text,
      reconstitutionFluid: widget.medication?.reconstitutionFluid ?? '',
      reconstitutionVolume: widget.medication?.reconstitutionVolume ?? 0.0,
      reconstitutionVolumeUnit: widget.medication?.reconstitutionVolumeUnit ?? '',
      selectedReconstitution: widget.medication?.selectedReconstitution,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmMedicationDialog(
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

    final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
    try {
      if (widget.medication == null) {
        await medicationPresenter.addMedication(medication);
      } else {
        await medicationPresenter.updateMedication(medication.id, medication);
      }
      if (context.mounted) {
        navigationService.replaceWith('/medication_details', arguments: medication);
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(
          widget.medication == null ? 'Add Medication' : 'Edit Medication',
          style: const TextStyle(fontFamily: 'Inter'),
        ),
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
                MedicationTypeDropdown(
                  value: _type,
                  onChanged: (value) => setState(() => _type = value),
                  validator: (value) => value == null ? 'Please select a type' : null,
                  isDark: isDark,
                ),
                if (_type != null) ...[
                  const SizedBox(height: 16),
                  MedicationNameField(
                    controller: _nameController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  if (_type == MedicationType.injection) ...[
                    InjectionWarningCard(isDark: isDark),
                    const SizedBox(height: 16),
                  ],
                  QuantityInputRow(
                    quantityController: _quantityController,
                    type: _type,
                    quantityUnit: _quantityUnit,
                    onUnitChanged: (value) => setState(() => _quantityUnit = value ?? _quantityUnit),
                    validator: (value) => value == null ? 'Please select a unit' : null,
                    isDark: isDark,
                  ),
                  if (_type == MedicationType.tablet || _type == MedicationType.capsule) ...[
                    const SizedBox(height: 16),
                    DoseInputRow(
                      type: _type!,
                      doseController: _type == MedicationType.tablet ? _dosePerTabletController : _dosePerCapsuleController,
                      doseUnit: _type == MedicationType.tablet ? _dosePerTabletUnit : _dosePerCapsuleUnit,
                      onUnitChanged: _type == MedicationType.tablet
                          ? (value) => setState(() => _dosePerTabletUnit = value ?? _dosePerTabletUnit)
                          : (value) => setState(() => _dosePerCapsuleUnit = value ?? _dosePerCapsuleUnit),
                      validator: (value) => value == null ? 'Please select a unit' : null,
                      isDark: isDark,
                    ),
                  ],
                  const SizedBox(height: 16),
                  NotesField(
                    controller: _notesController,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  // Display collected data (for demonstration)
                  const Text(
                    'Collected Data:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._collectedData.map((data) => Text(data)).toList(),
                  const SizedBox(height: 24),
                  SaveButton(
                    isSaving: _isSaving,
                    onPressed: () => _saveMedication(context),
                  ),
                ],
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