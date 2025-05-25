import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';

class AddDosageScreen extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const AddDosageScreen({super.key, required this.arguments});

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  final _nameController = TextEditingController();
  String _doseUnit = 'IU';
  final _doseController = TextEditingController();
  DosageMethod _method = DosageMethod.subcutaneous;
  double _targetDoseMcg = 0;

  @override
  void initState() {
    super.initState();
    final medication = widget.arguments['medication'] as Medication;
    _targetDoseMcg = widget.arguments['targetDoseMcg'] as double? ?? 0;
    final selectedIU = widget.arguments['selectedIU'] as double? ?? 0;
    _doseController.text = selectedIU.toString();
    _nameController.text = '${medication.name} Dose';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  void _saveDosage(BuildContext context) {
    if (_nameController.text.isEmpty || _doseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final medication = widget.arguments['medication'] as Medication;
    final dosage = Dosage(
      id: const Uuid().v4(),
      medicationId: medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: (double.tryParse(_doseController.text) ?? 0),
      volume: 0.0,
      insulinUnits: (double.tryParse(_doseController.text) ?? 0),
      takenTime: null,
    );

    Provider.of<DataProvider>(context, listen: false).addDosage(dosage);
    Navigator.of(context).pop(dosage);
  }

  @override
  Widget build(BuildContext context) {
    final medication = widget.arguments['medication'] as Medication;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Add Dosage for ${medication.name}'),
        backgroundColor: const Color(0xFFFFC107),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Dosage Name *',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
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
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFFFC107)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _doseUnit,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      labelStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFFFC107)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: ['IU', 'mcg', 'mg', 'mL']
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: (value) => setState(() {
                      _doseUnit = value!;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Target Dose: ${_targetDoseMcg.toInt()} mcg',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DosageMethod>(
              value: _method,
              decoration: InputDecoration(
                labelText: 'Method',
                labelStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: DosageMethod.values
                  .map((method) => DropdownMenuItem(
                value: method,
                child: Text(method.toString().split('.').last),
              ))
                  .toList(),
              onChanged: (value) => setState(() {
                _method = value!;
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveDosage(context),
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
    );
  }
}