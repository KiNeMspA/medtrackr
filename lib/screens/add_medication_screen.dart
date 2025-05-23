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
  String _type = 'Injection';
  String _storageType = 'Vial';
  String _quantityUnit = 'mg';
  double _quantity = 0.0;
  String _reconstitutionVolumeUnit = 'mL';
  double _reconstitutionVolume = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _name = widget.medication!.name;
      _type = widget.medication!.type == 'Injection' ? 'Injection' : 'Injection';
      _storageType = widget.medication!.storageType == 'Vial' ? 'Vial' : 'Vial';
      _quantityUnit = ['mg', 'mcg'].contains(widget.medication!.quantityUnit)
          ? widget.medication!.quantityUnit
          : 'mg';
      _quantity = widget.medication!.quantity;
      _reconstitutionVolumeUnit = widget.medication!.reconstitutionVolumeUnit == 'mL' ? 'mL' : 'mL';
      _reconstitutionVolume = widget.medication!.reconstitutionVolume;
    }
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.(\d)0+$'), r'.$1');
  }

  @override
  Widget build(BuildContext context) {
    final concentration = _reconstitutionVolume != 0
        ? (_quantityUnit == 'mg' ? _quantity * 1000 : _quantity) / _reconstitutionVolume
        : 0.0;
    final concentrationMgPerML = concentration / 1000;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication == null ? 'Add Medication' : 'Edit Medication',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Medication Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: ['Injection'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _storageType,
                decoration: InputDecoration(
                  labelText: 'Storage Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: ['Vial'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => _storageType = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _quantityUnit,
                decoration: InputDecoration(
                  labelText: 'Quantity Unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: ['mg', 'mcg'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => _quantityUnit = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _quantity.toString(),
                decoration: InputDecoration(
                  labelText: 'Quantity ($_quantityUnit)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a quantity';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onChanged: (value) => setState(() => _quantity = double.tryParse(value) ?? 0.0),
                onSaved: (value) => _quantity = double.parse(value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _reconstitutionVolumeUnit,
                decoration: InputDecoration(
                  labelText: 'Reconstitution Volume Unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: ['mL'].map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
                onChanged: (value) => setState(() => _reconstitutionVolumeUnit = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _reconstitutionVolume.toString(),
                decoration: InputDecoration(
                  labelText: 'Reconstitution Volume (mL)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a volume';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onChanged: (value) => setState(() => _reconstitutionVolume = double.tryParse(value) ?? 0.0),
                onSaved: (value) => _reconstitutionVolume = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Concentration for $_name:\n'
                        '${_formatNumber(concentration)} mcg/$_reconstitutionVolumeUnit\n'
                        '${_formatNumber(concentrationMgPerML)} mg/$_reconstitutionVolumeUnit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final medication = Medication(
                      id: widget.medication?.id,
                      name: _name,
                      type: _type,
                      storageType: _storageType,
                      quantityUnit: _quantityUnit,
                      quantity: _quantity,
                      reconstitutionVolumeUnit: _reconstitutionVolumeUnit,
                      reconstitutionVolume: _reconstitutionVolume,
                    );
                    print('Saving medication: ${medication.name}'); // Debug log
                    widget.onSave(medication);
                    Navigator.pop(context, medication); // Return to HomeScreen
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save and Set Dosage',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}