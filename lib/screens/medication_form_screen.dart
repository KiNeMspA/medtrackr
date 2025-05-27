import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/widgets/forms/medication_form_fields.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

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
  late TextEditingController _notesController;
  MedicationType _type = MedicationType.injection;
  QuantityUnit _quantityUnit = QuantityUnit.mg;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.medication?.name ?? '');
    _quantityController = TextEditingController(
        text: widget.medication != null
            ? (widget.medication!.quantity % 1 == 0
            ? widget.medication!.quantity.toInt().toString()
            : widget.medication!.quantity.toStringAsFixed(2))
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

    final medication = Medication(
      id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: _type,
      quantityUnit: _quantityUnit,
      quantity: double.tryParse(_quantityController.text) ?? 0.0,
      remainingQuantity: double.tryParse(_quantityController.text) ?? 0.0,
      reconstitutionVolumeUnit: '',
      reconstitutionVolume: 0.0,
      reconstitutionFluid: '',
      notes: _notesController.text,
      reconstitutionOptions: [],
      selectedReconstitution: null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Confirm Medication',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: RichText(
            text: TextSpan(
              style: AppConstants.cardBodyStyle.copyWith(height: 1.8),
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
      backgroundColor: Colors.grey[200],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medication Details',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                MedicationFormFields(
                  nameController: _nameController,
                  quantityController: _quantityController,
                  quantityUnit: _quantityUnit,
                  type: _type,
                  notesController: _notesController,
                  onNameChanged: (value) {},
                  onTypeChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _type = value;
                        if (_type == MedicationType.injection) {
                          _quantityUnit = QuantityUnit.mg;
                        }
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
                ElevatedButton(
                  onPressed: () => _saveMedication(context),
                  style: AppConstants.actionButtonStyle,
                  child: const Text(
                    'Add Medication',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}