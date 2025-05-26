import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/forms/medication_form_fields.dart';
import 'package:uuid/uuid.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/models/enums/medication_type.dart';

class MedicationFormScreen extends StatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({super.key, this.medication});

  @override
  _MedicationFormScreenState createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();
  MedicationType? _type; // Start with null
  String _quantityUnit = 'mg';

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _type = widget.medication!.type; // MedicationType
      _quantityUnit = widget.medication!.quantityUnit;
      _quantityController.text = widget.medication!.quantity.toStringAsFixed(2);
      _notesController.text = widget.medication!.notes;
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
    if (_nameController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _type == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final medication = (widget.medication ??
            Medication(
              id: const Uuid().v4(),
              name: '',
              type: MedicationType.tablet,
              quantityUnit: '',
              quantity: 0,
              remainingQuantity: 0,
              reconstitutionVolumeUnit: '',
              reconstitutionVolume: 0,
              reconstitutionFluid: '',
              notes: '',
              isReconstituted: false,
              targetDosage: null,
              administerDosage: null,
              reconstitutionOptions: [],
              selectedReconstitution: null,
            ))
        .copyWith(
      name: _nameController.text,
      type: _type,
      quantityUnit: _quantityUnit,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      remainingQuantity: double.tryParse(_quantityController.text) ?? 0,
      reconstitutionVolumeUnit: '',
      reconstitutionVolume: 0,
      reconstitutionFluid: '',
      notes: _notesController.text,
      isReconstituted: false,
      targetDosage: null,
      administerDosage: null,
      reconstitutionOptions: [],
      selectedReconstitution: null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmationDialog(context, medication),
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

  Widget _buildConfirmationDialog(BuildContext context, Medication medication) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        widget.medication == null
            ? 'Confirm New Medication'
            : 'Confirm Medication Changes',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
          shadows: [Shadow(color: AppConstants.primaryColor, blurRadius: 2)],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: RichText(
          text: TextSpan(
            style:
                const TextStyle(color: Colors.grey, fontSize: 16, height: 1.8),
            children: [
              const TextSpan(
                  text: 'Name: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: '${medication.name}\n'),
              const TextSpan(
                  text: 'Type: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(text: '${medication.type}\n'),
              const TextSpan(
                  text: 'Quantity: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(
                  text:
                      '${medication.quantity.toStringAsFixed(2)} ${medication.quantityUnit}\n'),
              const TextSpan(
                  text: 'Notes: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)),
              TextSpan(
                  text:
                      medication.notes.isNotEmpty ? medication.notes : 'None'),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.medication == null
            ? 'Add Medication Stock'
            : 'Edit Medication'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 8),
              DropdownButtonFormField<MedicationType>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Medicine Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                hint: const Text('Select Type'),
                items: MedicationType.values
                    .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _type = value;
                  _quantityUnit = {
                        MedicationType.tablet: 'mg',
                        MedicationType.capsule: 'mg',
                        MedicationType.injection: 'mg',
                      }[value] ??
                      'mg';
                }),
                validator: (value) =>
                    value == null ? 'Please select a type' : null,
              ),
              if (_type != null) ...[
                const SizedBox(height: 16),
                MedicationFormFields(
                  nameController: _nameController,
                  quantityController: _quantityController,
                  quantityUnit: _quantityUnit,
                  type: _type!,
                  // Pass read-only type
                  notesController: _notesController,
                  onQuantityChanged: () {},
                  onNameChanged: (value) => setState(() {}),
                  onQuantityUnitChanged: (value) => setState(() {
                    _quantityUnit = value ?? 'mg';
                  }),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _saveMedication(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text('Save Medication',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
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
