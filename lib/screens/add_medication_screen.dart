// lib/screens/add_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/screens/add_dosage_screen.dart';
import 'package:medtrackr/screens/add_schedule_screen.dart';
import 'package:uuid/uuid.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  _AddMedicationScreenState createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  String _type = 'Injection';
  String _storageType = 'Vial';
  String _quantityUnit = 'mg';
  final _quantityController = TextEditingController();
  final _reconstitutionVolumeController = TextEditingController();
  bool _showReconstitute = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _reconstitutionVolumeController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication(BuildContext context) async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final medication = Medication(
      id: const Uuid().v4(),
      name: _nameController.text,
      type: _type,
      storageType: _type == 'Injection' || _type == 'Other' ? _storageType : '',
      quantityUnit: _quantityUnit,
      quantity: int.tryParse(_quantityController.text)?.toDouble() ?? 0.0,
      reconstitutionVolumeUnit: _showReconstitute ? 'mL' : '',
      reconstitutionVolume: _showReconstitute ? (double.tryParse(_reconstitutionVolumeController.text) ?? 0.0) : 0.0,
    );

    Navigator.pop(context, (medication, null, null));
  }

  @override
  Widget build(BuildContext context) {
    final isInjection = _type == 'Injection';
    final isTabletOrCapsule = _type == 'Tablet' || _type == 'Capsule';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
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
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medication Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Injection', 'Tablet', 'Capsule', 'Other']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _type = value!;
                  _storageType = isInjection ? 'Vial' : 'Other';
                }),
              ),
              if (!isTabletOrCapsule) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _storageType,
                  decoration: InputDecoration(
                    labelText: 'Storage Type${isInjection ? ' *' : ''}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFFFC107)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Vial', 'Pen', if (_type == 'Other') 'Other']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) => setState(() => _storageType = value!),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Total Storage Quantity *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _quantityUnit,
                decoration: InputDecoration(
                  labelText: 'Measure',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['mcg', 'mg', 'mL', 'IU']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (value) => setState(() => _quantityUnit = value!),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _showReconstitute = !_showReconstitute),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _showReconstitute ? 'Hide Reconstitution' : 'Reconstitute',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              if (_showReconstitute) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _reconstitutionVolumeController,
                  decoration: InputDecoration(
                    labelText: 'Reconstitution Volume (mL)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFFFFC107)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final dosage = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddDosageScreen()),
                  );
                  if (dosage != null) {
                    Navigator.pop(context, (null, null, dosage));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add Dosage', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final schedule = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
                  );
                  if (schedule != null) {
                    Navigator.pop(context, (null, schedule, null));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add Schedule', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveMedication(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Medication', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}