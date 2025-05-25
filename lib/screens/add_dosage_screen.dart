import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:uuid/uuid.dart';

class AddDosageScreen extends StatefulWidget {
  final Medication? medication;

  const AddDosageScreen({super.key, this.medication});

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  final _nameController = TextEditingController();
  DosageMethod _method = DosageMethod.subcutaneous;
  String _doseUnit = 'mcg';
  final _doseController = TextEditingController();
  double _volume = 0.0;
  double _insulinUnits = 0.0;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = '${widget.medication!.name} Dose';
      _doseUnit = widget.medication!.quantityUnit;
      if (widget.medication!.reconstitutionVolume > 0) {
        final concentration = (widget.medication!.quantity * (widget.medication!.quantityUnit == 'mg' ? 1000 : 1)) / widget.medication!.reconstitutionVolume;
        _doseController.text = '100';
        _volume = (double.tryParse(_doseController.text) ?? 0) / concentration;
        _insulinUnits = (_volume / widget.medication!.reconstitutionVolume) * 100;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _updateReconstitutionCalculations() {
    if (widget.medication != null && widget.medication!.reconstitutionVolume > 0) {
      final concentration = (widget.medication!.quantity * (widget.medication!.quantityUnit == 'mg' ? 1000 : 1)) / widget.medication!.reconstitutionVolume;
      final dose = double.tryParse(_doseController.text) ?? 0;
      setState(() {
        _volume = dose / concentration;
        _insulinUnits = (_volume / widget.medication!.reconstitutionVolume) * 100;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isReconstituted = widget.medication != null && widget.medication!.reconstitutionVolume > 0;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add Dosage'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dosage Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Dosage Name *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DosageMethod>(
                value: _method,
                decoration: InputDecoration(
                  labelText: 'Method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: DosageMethod.values
                    .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method.toString().split('.').last.capitalize()),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _method = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _doseController,
                      decoration: InputDecoration(
                        labelText: 'Dose Amount *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _updateReconstitutionCalculations(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _doseUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Color(0xFFFFC107)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['mcg', 'mg', 'mL', 'IU']
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) => setState(() => _doseUnit = value!),
                    ),
                  ),
                ],
              ),
              if (isReconstituted) ...[
                const SizedBox(height: 16),
                Text(
                  'Calculated Volume: ${_volume.toStringAsFixed(2)} mL',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Insulin Units: ${_insulinUnits.toStringAsFixed(1)} IU',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isEmpty || _doseController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all required fields')),
                    );
                    return;
                  }
                  final dosage = Dosage(
                    id: const Uuid().v4(),
                    medicationId: widget.medication?.id ?? '',
                    name: _nameController.text,
                    method: _method,
                    doseUnit: _doseUnit,
                    totalDose: double.tryParse(_doseController.text) ?? 0.0,
                    volume: _volume,
                    insulinUnits: _insulinUnits,
                  );
                  Navigator.pop(context, dosage);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Dosage', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}