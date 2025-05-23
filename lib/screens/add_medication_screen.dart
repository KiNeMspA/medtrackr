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
  String _quantityUnit = 'mg';
  double _quantity = 0.0;
  String _reconstitutionVolumeUnit = 'mL';
  double _reconstitutionVolume = 0.0;
  double _totalVialVolume = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _name = widget.medication!.name;
      _type = widget.medication!.type;
      _storageType = widget.medication!.storageType;
      _quantityUnit = widget.medication!.quantityUnit;
      _quantity = widget.medication!.quantity;
      _reconstitutionVolumeUnit = widget.medication!.reconstitutionVolumeUnit;
      _reconstitutionVolume = widget.medication!.reconstitutionVolume;
      _totalVialVolume = widget.medication!.totalVialVolume;
    }
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
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextFormField(
                label: 'Medication Name',
                initialValue: _name,
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              _buildDropdownFormField(
                label: 'Medication Type',
                value: _type,
                items: ['Injectable'],
                onChanged: (value) => setState(() => _type = value!),
              ),
              _buildDropdownFormField(
                label: 'Storage Type',
                value: _storageType,
                items: ['Vial'],
                onChanged: (value) => setState(() => _storageType = value!),
              ),
              _buildDropdownFormField(
                label: 'Quantity Unit',
                value: _quantityUnit,
                items: ['mg', 'mcg'],
                onChanged: (value) => setState(() => _quantityUnit = value!),
              ),
              _buildTextFormField(
                label: 'Quantity ($_quantityUnit)',
                initialValue: _quantity.toString(),
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
              _buildDropdownFormField(
                label: 'Reconstitution Volume Unit',
                value: _reconstitutionVolumeUnit,
                items: ['mL'],
                onChanged: (value) => setState(() => _reconstitutionVolumeUnit = value!),
              ),
              _buildTextFormField(
                label: 'Reconstitution Volume (mL)',
                initialValue: _reconstitutionVolume.toString(),
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
              _buildTextFormField(
                label: 'Total Vial Volume (mL)',
                initialValue: _totalVialVolume.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a volume';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  if (num < _reconstitutionVolume) return 'Total volume must be >= reconstitution volume';
                  return null;
                },
                onChanged: (value) => setState(() => _totalVialVolume = double.tryParse(value) ?? 0.0),
                onSaved: (value) => _totalVialVolume = double.parse(value!),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Concentration for $_name:\n'
                        '${concentration.toStringAsFixed(2)} mcg/$_reconstitutionVolumeUnit\n'
                        '${concentrationMgPerML.toStringAsFixed(2)} mg/$_reconstitutionVolumeUnit',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
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
                      quantityUnit: _quantityUnit,
                      quantity: _quantity,
                      reconstitutionVolumeUnit: _reconstitutionVolumeUnit,
                      reconstitutionVolume: _reconstitutionVolume,
                      totalVialVolume: _totalVialVolume,
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Next: Dosage Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownFormField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}