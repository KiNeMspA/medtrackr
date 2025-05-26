import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/utils/calculators/reconstitution_calculator.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';

class ReconstitutionScreen extends StatefulWidget {
  final Medication medication;

  const ReconstitutionScreen({super.key, required this.medication});

  @override
  _ReconstitutionScreenState createState() => _ReconstitutionScreenState();
}

class _ReconstitutionScreenState extends State<ReconstitutionScreen> {
  final _reconstitutionDiluentController = TextEditingController();
  final _targetDoseController = TextEditingController();
  final _diluentAmountController = TextEditingController();
  String _targetDoseUnit = 'mcg';
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _targetDose = 0;
  String? _reconstitutionError;
  double _syringeSize = 1.0;

  @override
  void initState() {
    super.initState();
    _reconstitutionDiluentController.text =
    widget.medication.reconstitutionFluid.isNotEmpty
        ? widget.medication.reconstitutionFluid
        : 'Bacteriostatic Water';
    _targetDose = 600 / 1000; // Default to 600mcg
    _targetDoseController.text = _formatNumber(_targetDose);
    _diluentAmountController.text = '1';
    _calculateReconstitutionSuggestions();
  }

  @override
  void dispose() {
    _reconstitutionDiluentController.dispose();
    _targetDoseController.dispose();
    _diluentAmountController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  void _calculateReconstitutionSuggestions() {
    final volume = double.tryParse(_diluentAmountController.text) ?? 1.0;
    if (_selectedReconstitution != null) {
      _selectedReconstitution!['volume'] = volume;
      _selectedReconstitution!['concentration'] =
          widget.medication.quantity / volume;
      _selectedReconstitution!['syringeUnits'] =
          (_targetDose * 1000) / (_selectedReconstitution!['concentration'] * _syringeSize);
    }

    final calculator = ReconstitutionCalculator(
      quantityController:
      TextEditingController(text: widget.medication.quantity.toString()),
      targetDoseController: _targetDoseController,
      quantityUnit: widget.medication.quantityUnit,
      targetDoseUnit: _targetDoseUnit,
      medicationName: widget.medication.name,
      syringeSize: _syringeSize,
    );
    final result = calculator.calculate();
    final concentration = _selectedReconstitution != null
        ? (_selectedReconstitution!['concentration'] as double?) ?? 0.0
        : 0.0;

    setState(() {
      _reconstitutionSuggestions = (result['suggestions'] as List<dynamic>?)
          ?.cast<Map<String, dynamic>>() ??
          [];
      if (_selectedReconstitution == null) {
        _selectedReconstitution =
        result['selectedReconstitution'] as Map<String, dynamic>?;
      }
      _targetDose = (result['targetDose'] as double?) ?? 0.0;
      _reconstitutionError = result['error'] as String? ??
          (concentration < 0.1 || concentration > 10
              ? 'Warning: Concentration is ${_formatNumber(concentration)} mg/mL, recommended range is 0.1–10 mg/mL.'
              : null);
    });
  }

  void _nudgeVolume(bool increase) {
    double currentVolume = double.tryParse(_diluentAmountController.text) ?? 1.0;
    currentVolume = increase ? currentVolume + 0.1 : currentVolume - 0.1;
    if (currentVolume < 0.1) currentVolume = 0.1; // Minimum volume
    _diluentAmountController.text = _formatNumber(currentVolume);
    _calculateReconstitutionSuggestions();
  }

  Future<void> _saveReconstitution(BuildContext context) async {
    if (_selectedReconstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reconstitution option')),
      );
      return;
    }

    final updatedMedication = widget.medication.copyWith(
      reconstitutionVolumeUnit: 'mL',
      reconstitutionVolume: _selectedReconstitution!['volume']?.toDouble() ?? 0,
      reconstitutionFluid: _reconstitutionDiluentController.text,
      reconstitutionOptions: _reconstitutionSuggestions,
      selectedReconstitution: _selectedReconstitution,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Confirm Reconstitution',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [Shadow(color: AppConstants.primaryColor, blurRadius: 2)],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Colors.grey, fontSize: 16, height: 1.5),
              children: [
                const TextSpan(
                    text: 'Diluent: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${_reconstitutionDiluentController.text}\n'),
                const TextSpan(
                    text: 'Diluent Amount: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text:
                    '${_formatNumber(_selectedReconstitution!['volume'])} mL\n'),
                const TextSpan(
                    text: 'Concentration: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text:
                    '${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL\n'),
                const TextSpan(
                    text: 'Target Dose: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text: '${_formatNumber(_targetDose * 1000)} $_targetDoseUnit'),
              ],
            ),
          ),
        ),
        actions: [
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
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.updateMedicationAsync(
          updatedMedication.id, updatedMedication);
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/medication_details',
          arguments: updatedMedication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reconstitution: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetDoseUnits = widget.medication.quantityUnit == 'mg'
        ? ['mg', 'mcg']
        : ['mcg', 'mg']; // Adjust based on quantityUnit

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Reconstitute Medication'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reconstitution Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reconstitutionDiluentController,
                decoration: InputDecoration(
                  labelText: 'Reconstitution Diluent (e.g., Bacteriostatic Water)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _calculateReconstitutionSuggestions(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetDoseController,
                      decoration: InputDecoration(
                        labelText: 'Target Dose',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateReconstitutionSuggestions(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: _targetDoseUnit,
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: targetDoseUnits
                          .map((unit) =>
                          DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _targetDoseUnit = value;
                            _calculateReconstitutionSuggestions();
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _diluentAmountController,
                      decoration: InputDecoration(
                        labelText: 'Diluent Amount (mL)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _calculateReconstitutionSuggestions(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _nudgeVolume(false),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _nudgeVolume(true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<double>(
                value: _syringeSize,
                decoration: InputDecoration(
                  labelText: 'Syringe Size (mL)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [0.3, 0.5, 1.0, 3.0, 5.0]
                    .map((size) =>
                    DropdownMenuItem(value: size, child: Text(_formatNumber(size))))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _syringeSize = value;
                      _selectedReconstitution = null;
                      _reconstitutionSuggestions = [];
                      _calculateReconstitutionSuggestions();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedReconstitution != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppConstants.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.black, fontSize: 16, height: 1.8),
                      children: [
                        const TextSpan(
                            text: 'Reconstitute ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: widget.medication.name),
                        const TextSpan(text: '\nwith '),
                        TextSpan(
                          text: _formatNumber(_selectedReconstitution!['volume']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' mL of '),
                        TextSpan(text: _reconstitutionDiluentController.text),
                        const TextSpan(text: '\nto Target a Dose of '),
                        TextSpan(
                          text: _formatNumber(_targetDose * (_targetDoseUnit == 'mg' ? 1 : 1000)),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' $_targetDoseUnit'),
                        const TextSpan(text: '\non '),
                        TextSpan(
                          text: _formatNumber(_syringeSize),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' mL Syringe'),
                        const TextSpan(text: '\nfor a Syringe Dosage of '),
                        TextSpan(
                          text: _formatNumber(_selectedReconstitution!['syringeUnits']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' IU'),
                      ],
                    ),
                  ),
                ),
              if (_reconstitutionError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _reconstitutionError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveReconstitution(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                child: const Text('Save',
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
        onTap: (int index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/calendar');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    );
  }
}