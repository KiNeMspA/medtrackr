// lib/screens/add_dosage_screen.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:uuid/uuid.dart';

class AddDosageScreen extends StatefulWidget {
  const AddDosageScreen({super.key});

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  String _dosageMethod = 'subcutaneous';
  String _doseUnit = 'mcg';
  final _totalDoseController = TextEditingController();
  final _volumeController = TextEditingController();
  final _insulinUnitsController = TextEditingController();

  @override
  void dispose() {
    _totalDoseController.dispose();
    _volumeController.dispose();
    _insulinUnitsController.dispose();
    super.dispose();
  }

  void _saveDosage() {
    if (_totalDoseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a total dose')),
      );
      return;
    }

    final dosage = Dosage(
      id: const Uuid().v4(),
      medicationId: '', // Will be set by HomeScreen
      method: DosageMethod.values.firstWhere((e) => e.toString().split('.').last == _dosageMethod),
      doseUnit: _doseUnit,
      totalDose: double.tryParse(_totalDoseController.text) ?? 0.0,
      volume: double.tryParse(_volumeController.text) ?? 0.0,
      insulinUnits: double.tryParse(_insulinUnitsController.text) ?? 0.0,
    );

    Navigator.pop(context, dosage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              DropdownButtonFormField<String>(
                value: _dosageMethod,
                decoration: InputDecoration(
                  labelText: 'Dosage Method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['subcutaneous', 'intramuscular', 'oral', 'other']
                    .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (value) => setState(() => _dosageMethod = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _totalDoseController,
                decoration: InputDecoration(
                  labelText: 'Total Dose *',
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
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _doseUnit,
                decoration: InputDecoration(
                  labelText: 'Dose Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['mcg', 'mg']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (value) => setState(() => _doseUnit = value!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _volumeController,
                decoration: InputDecoration(
                  labelText: 'Volume (mL)',
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
              const SizedBox(height: 16),
              TextField(
                controller: _insulinUnitsController,
                decoration: InputDecoration(
                  labelText: 'Insulin Units (IU)',
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveDosage,
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