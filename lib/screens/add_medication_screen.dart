import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/screens/dosage_schedule_screen.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;
  final void Function(Medication) onSave;

  const AddMedicationScreen({super.key, this.medication, required this.onSave});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _type = 'Injectable';
  String _storageType = 'Vial';
  String _stockUnit = 'mg';
  double _stockQuantity = 0.0;
  String _reconstitutionVolumeUnit = 'mL';
  double _reconstitutionVolume = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _name = widget.medication!.name;
      _type = widget.medication!.type;
      _storageType = widget.medication!.storageType;
      _stockUnit = widget.medication!.stockUnit;
      _stockQuantity = widget.medication!.stockQuantity;
      _reconstitutionVolumeUnit = widget.medication!.reconstitutionVolumeUnit;
      _reconstitutionVolume = widget.medication!.reconstitutionVolume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final concentration = _reconstitutionVolume != 0 ? _stockQuantity / _reconstitutionVolume : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication == null ? 'Add Medication' : 'Edit Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Medication Type'),
                items: ['Injectable'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              DropdownButtonFormField<String>(
                value: _storageType,
                decoration: const InputDecoration(labelText: 'Storage Type'),
                items: ['Vial'].map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _storageType = value!),
              ),
              DropdownButtonFormField<String>(
                value: _stockUnit,
                decoration: const InputDecoration(labelText: 'Stock Unit'),
                items: ['mg'].map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                onChanged: (value) => setState(() => _stockUnit = value!),
              ),
              TextFormField(
                initialValue: _stockQuantity.toString(),
                decoration: const InputDecoration(labelText: 'Stock Quantity (mg)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a quantity';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _stockQuantity = double.parse(value!),
              ),
              DropdownButtonFormField<String>(
                value: _reconstitutionVolumeUnit,
                decoration: const InputDecoration(labelText: 'Reconstitution Volume Unit'),
                items: ['mL'].map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                onChanged: (value) => setState(() => _reconstitutionVolumeUnit = value!),
              ),
              TextFormField(
                initialValue: _reconstitutionVolume.toString(),
                decoration: const InputDecoration(labelText: 'Reconstitution Volume (mL)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a volume';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _reconstitutionVolume = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Text(
                'Concentration: ${concentration.toStringAsFixed(2)} $_stockUnit/$_reconstitutionVolumeUnit',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final medication = Medication(
                      id: widget.medication?.id,
                      name: _name,
                      type: _type,
                      storageType: _storageType,
                      stockUnit: _stockUnit,
                      stockQuantity: _stockQuantity,
                      reconstitutionVolumeUnit: _reconstitutionVolumeUnit,
                      reconstitutionVolume: _reconstitutionVolume,
                    );
                    widget.onSave(medication);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DosageScheduleScreen(medication: medication),
                      ),
                    );
                  }
                },
                child: const Text('Next: Dosage Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}