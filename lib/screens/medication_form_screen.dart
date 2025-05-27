import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/constants/themes.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/widgets/forms/medication_form_fields.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({super.key, this.medication});

  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _tabletCountController;
  late TextEditingController _volumeController;
  late TextEditingController _dosePerTabletController;
  late TextEditingController _notesController;
  MedicationType _type = MedicationType.injection;
  QuantityUnit _quantityUnit = QuantityUnit.mg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.medication != null &&
            widget.medication!.type == MedicationType.injection &&
            widget.medication!.quantityUnit != QuantityUnit.mL
            ? widget.medication!.quantity.toStringAsFixed(2)
            : '');
    _tabletCountController = TextEditingController(
        text: widget.medication != null &&
            (widget.medication!.type == MedicationType.tablet ||
                widget.medication!.type == MedicationType.capsule)
            ? widget.medication!.quantity.toInt().toString()
            : '');
    _volumeController = TextEditingController(
        text: widget.medication != null &&
            widget.medication!.type == MedicationType.injection
            ? widget.medication!.quantity.toStringAsFixed(2)
            : '');
    _dosePerTabletController = TextEditingController(
        text: widget.medication != null &&
            (widget.medication!.type == MedicationType.tablet ||
                widget.medication!.type == MedicationType.capsule)
            ? widget.medication!.dosePerTablet?.toStringAsFixed(2) ?? ''
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

    if (isInjection && unit != QuantityUnit.mL && widget.medication?.reconstitutionVolume == 0) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: DialogThemes.warning.backgroundColor,
          title: Text('Set Volume or Reconstitute', style: DialogThemes.warning.titleTextStyle),
          content: Text(
            'Non-reconstituted injections require a volume in mL. Enter a volume or reconstitute the medication.',
            style: DialogThemes.warning.contentTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Enter Volume'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: AppConstants.dialogButtonStyle,
              child: const Text('Reconstitute'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        final medication = Medication(
          id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text,
          type: _type,
          quantityUnit: unit,
          quantity: quantity,
          remainingQuantity: quantity,
          reconstitutionVolumeUnit: '',
          reconstitutionVolume: 0.0,
          reconstitutionFluid: '',
          notes: _notesController.text,
          dosePerTablet: isTabletOrCapsule
              ? double.tryParse(_dosePerTabletController.text) ?? 0.0
              : null,
        );
        Navigator.pushNamed(context, '/reconstitute', arguments: medication);
        return;
      } else {
        unit = QuantityUnit.mL;
        quantity = double.tryParse(_volumeController.text) ?? 0.0;
        if (quantity <= 0 && _volumeController.text.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a valid volume')),
          );
          return;
        }
      }
    }

    final medication = Medication(
      id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _type,
      quantityUnit: unit,
      quantity: quantity,
      remainingQuantity: quantity,
      reconstitutionVolumeUnit: '',
      reconstitutionVolume: 0.0,
      reconstitutionFluid: '',
      notes: _notesController.text,
      dosePerTablet: isTabletOrCapsule
          ? double.tryParse(_dosePerTabletController.text) ?? 0.0
          : null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DialogThemes.information.backgroundColor,
        title: Text('Confirm Medication', style: DialogThemes.information.titleTextStyle),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: RichText(
            text: TextSpan(
              style: DialogThemes.information.contentTextStyle?.copyWith(height: 1.8),
              children: [
                const TextSpan(
                  text: 'Name: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: medication.name),
                const TextSpan(
                  text: '\nType: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: medication.type.displayName),
                const TextSpan(
                  text: '\nQuantity: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text:
                    '${medication.quantity % 1 == 0 ? medication.quantity.toInt() : medication.quantity.toStringAsFixed(2)} ${medication.quantityUnit.displayName}'),
                if (isTabletOrCapsule && medication.dosePerTablet != null) ...[
                  const TextSpan(
                    text: '\nDose per Tablet: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '${medication.dosePerTablet} mg/mcg'),
                ],
                const TextSpan(
                  text: '\nNotes: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: medication.notes.isNotEmpty ? medication.notes : 'None'),
              ],
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppConstants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      if (widget.medication == null) {
        await dataProvider.addMedicationAsync(medication);
      } else {
        await dataProvider.updateMedicationAsync(medication.id, medication);
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
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                MedicationFormFields(
                  nameController: _nameController,
                  quantityController: _quantityController,
                  tabletCountController: _tabletCountController,
                  volumeController: _volumeController,
                  dosePerTabletController: _dosePerTabletController,
                  notesController: _notesController,
                  quantityUnit: _quantityUnit,
                  type: _type,
                  onNameChanged: (value) {},
                  onTypeChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                        _quantityUnit = value == MedicationType.tablet || value == MedicationType.capsule
                            ? QuantityUnit.tablets
                            : QuantityUnit.mg;
                      });
                    }
                  },
                  onQuantityUnitChanged: (value) {
                    if (value != null) {
                      setState(() => _quantityUnit = value);
                    }
                  },
                  onQuantityChanged: () {},
                ),
                if (widget.medication == null) ...[
                  const SizedBox(height: 24),
                  Container(
                    decoration: AppConstants.infoCardDecoration,
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _type == MedicationType.injection
                          ? 'Proceed to the Medication Overview to set up dosages, reconstitution (if applicable), and schedules.'
                          : 'Proceed to the Medication Overview to set up dosages and schedules.',
                      style: AppConstants.infoTextStyle,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => _saveMedication(context),
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