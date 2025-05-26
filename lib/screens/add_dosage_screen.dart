import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/utils/calculators/reconstitution_calculator.dart';
import 'package:medtrackr/widgets/forms/form_field.dart';
import 'package:uuid/uuid.dart';

class AddDosageScreen extends StatefulWidget {
  const AddDosageScreen({super.key, required this.medication, this.dosage});
  final Medication medication;
  final Dosage? dosage;

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _DosageScreenState extends State<AddDosageScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(); // For dosage amount
  final _peptideController = TextEditingController(); // For reconstitution quantity
  final _targetDoseController = TextEditingController(); // For reconstitution dose
  String _unit = 'mcg';
  String _quantityUnit = 'mg';
  String _targetDoseUnit = 'mcg';
  Dosage? _dosage;
  Medication? _medication;
  Map<String, dynamic>? _calcResult;
  double _syringeSize = 1.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _medication = widget.medication;
    _dosage = widget.dosage;
    if (_dosage != null) {
      _nameController.text = _dosage.name;
      _quantityController.text = _dosage.totalDose.toStringAsFixed(2);
      _unit = _dosage.doseUnit;
    }
    _peptideController.text = _medication?.quantity.toString() ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _peptideController.dispose();
    _targetDoseController.dispose();
    super.dispose();
  }

  void _calculateReconstitution() {
    final calculator = ReconstitutionCalculator(
      quantityController: _peptideController,
      targetDoseController: _targetDoseController,
      quantityUnit: _quantityUnit,
      targetDoseUnit: _targetDoseUnit,
      medicationName: _medication?.name ?? 'Medication',
      syringeSize: _syringeSize,
    );
    setState(() {
      _calcResult = calculator.calculate();
    });
    if (_calcResult?['error'] != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error', style: TextStyle(color: AppConstants.primaryColor)),
          content: Text(_calcResult!['error']),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: AppConstants.primaryColor)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      final selected = _calcResult?['selectedReconstitution'];
      if (selected != null) {
        _quantityController.text = selected['doseVolume'].toStringAsFixed(2);
        _unit = 'mL';
      }
    }
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty || _medication == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    final totalDose = double.tryParse(_quantityController.text);
    if (totalDose == null || totalDose <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dose must be a positive number'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    final dosage = Dosage(
      id: const Uuid().v4(),
      medicationId: _medication!.id,
      name: _nameController.text,
      method: DosageMethod.unspecified,
      doseUnit: _unit,
      totalDose: totalDose,
      volume: _calcResult?['selectedReconstitution']?['doseVolume'] ?? 0.0,
      insulinUnits: _calcResult?['selectedReconstitution']?['syringeUnits'] ?? 0.0,
      time: TimeOfDay.now(),
    );

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.addDosageAsync(dosage);
      if (context.mounted) {
        Navigator.pop(context, dosage);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving dosage: $e'),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Add Dosage', style: TextStyle(color: Colors.black)),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dosage Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Dosage Name',
                isRequired: true,
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _quantityController,
                labelText: 'Dose Amount',
                isRequired: true,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              CustomDropdown<String>(
                value: _unit,
                labelText: 'Unit',
                items: ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (value) => setState(() => _unit = value ?? 'mcg'),
              ),
              SizedBox(height: 24),
              Text(
                'Reconstitution Calculator',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _peptideController,
                labelText: 'Peptide Quantity',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              CustomDropdown<String>(
                value: _quantityUnit,
                labelText: 'Quantity Unit',
                items: ['g', 'mg', 'mcg', 'IU']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (value) => setState(() => _quantityUnit = value ?? 'mg'),
              ),
              SizedBox(height: 16),
              CustomTextField(
                controller: _targetDoseController,
                labelText: 'Desired Dosage',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              CustomDropdown<String>(
                value: _targetDoseUnit,
                labelText: 'Dose Unit',
                items: ['mg', 'mcg']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                    .toList(),
                onChanged: (value) => setState(() => _targetDoseUnit = value ?? 'mcg'),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Syringe Size (mL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _syringeSize = double.tryParse(value) ?? 1.0,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateReconstitution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Calculate', style: TextStyle(color: Colors.black)),
              ),
              if (_calcResult != null && _calcResult!['error'] == null)
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reconstitution Result',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (_calcResult!['selectedReconstitution'] != null)
                            Text(
                              'Volume: ${_calcResult!['selectedReconstitution']['volume']} mL\n'
                                  'Dose Volume: ${_calcResult!['selectedReconstitution']['doseVolume']} mL\n'
                                  'Syringe Units: ${_calcResult!['selectedReconstitution']['syringeUnits']} units',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 24),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dosage Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Name: ${_nameController.text.isEmpty ? 'N/A' : _nameController.text}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Dose: ${_quantityController.text.isEmpty ? 'N/A' : _quantityController.text} $_unit',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Medication: ${_medication?.name ?? 'N/A'}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveDosage(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Save Dosage', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
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