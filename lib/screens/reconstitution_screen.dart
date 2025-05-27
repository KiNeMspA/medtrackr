import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/enums/syringe_size.dart';
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
  final _reconstitutionFluidController = TextEditingController();
  final _targetDoseController = TextEditingController();
  final _fluidAmountController = TextEditingController();
  String _targetDoseUnit = 'mcg';
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _targetDose = 0;
  String? _reconstitutionError;
  SyringeSize _syringeSize = SyringeSize.size1_0;

  @override
  void initState() {
    super.initState();
    _reconstitutionFluidController.text =
    widget.medication.reconstitutionFluid.isNotEmpty
        ? widget.medication.reconstitutionFluid
        : 'Bacteriostatic Water';
    _targetDose = 0;
    _targetDoseController.text = _formatNumber(_targetDose);
    _fluidAmountController.text = '1';
    _calculateReconstitutionSuggestions();
  }

  @override
  void dispose() {
    _reconstitutionFluidController.dispose();
    _targetDoseController.dispose();
    _fluidAmountController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  void _calculateReconstitutionSuggestions() {
    final volume = double.tryParse(_fluidAmountController.text) ?? 1.0;
    final calculator = ReconstitutionCalculator(
      quantityController: TextEditingController(text: widget.medication.quantity.toString()),
      targetDoseController: _targetDoseController,
      quantityUnit: widget.medication.quantityUnit,
      targetDoseUnit: _targetDoseUnit,
      medicationName: widget.medication.name,
      syringeSize: _syringeSize.value,
      fixedVolume: volume,
    );
    final result = calculator.calculate();

    setState(() {
      _targetDose = double.tryParse(_targetDoseController.text) ?? 0.0;
      _reconstitutionSuggestions = (result['suggestions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
      _selectedReconstitution = result['selectedReconstitution'] as Map<String, dynamic>?;
      _reconstitutionError = result['error'] as String?;
    });
  }

  void _nudgeVolume(bool increase) {
    double currentVolume = double.tryParse(_fluidAmountController.text) ?? 1.0;
    currentVolume = increase ? currentVolume + 0.1 : currentVolume - 0.1;
    if (currentVolume < 0.1) currentVolume = 0.1;
    _fluidAmountController.text = _formatNumber(currentVolume);
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
      reconstitutionFluid: _reconstitutionFluidController.text,
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
              style: const TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
              children: [
                const TextSpan(
                    text: 'Reconstitution Fluid: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${_reconstitutionFluidController.text}\n'),
                const TextSpan(
                    text: 'Fluid Amount: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${_formatNumber(_selectedReconstitution!['volume'])} mL\n'),
                const TextSpan(
                    text: 'Concentration: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL\n'),
                const TextSpan(
                    text: 'Target Dose: ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${_formatNumber(_targetDose)} $_targetDoseUnit\n'),
                const TextSpan(
                    text: 'Administer ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                  text: '${_formatNumber(_selectedReconstitution!['syringeUnits'])} IU',
                  style: const TextStyle(color: Colors.black),
                ),
                const TextSpan(
                    text: ' via ',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                  text: _syringeSize.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
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
                      color: AppConstants.primaryColor, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      await dataProvider.updateMedicationAsync(updatedMedication.id, updatedMedication);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/medication_details', arguments: updatedMedication);
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
    final targetDoseUnits = widget.medication.quantityUnit == 'mg' ? ['mg', 'mcg'] : ['mcg', 'mg'];

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
                controller: _reconstitutionFluidController,
                decoration: InputDecoration(
                  labelText: 'Reconstitution Fluid (e.g., Bacteriostatic Water)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: targetDoseUnits
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
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
                      controller: _fluidAmountController,
                      decoration: InputDecoration(
                        labelText: 'Fluid Amount (mL)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              DropdownButtonFormField<SyringeSize>(
                value: _syringeSize,
                decoration: InputDecoration(
                  labelText: 'Syringe Size',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: SyringeSize.values
                    .map((size) => DropdownMenuItem(value: size, child: Text(size.displayName)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _syringeSize = value;
                      _calculateReconstitutionSuggestions();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_selectedReconstitution != null) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formula: Units = (Target Dose (mg) / Concentration (mg/mL)) * 100',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      Text(
                        'Calculation: ${_formatNumber(_targetDose * (_targetDoseUnit == 'mg' ? 1 : 1/1000))} mg / ${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL * 100 = ${_formatNumber(_selectedReconstitution!['syringeUnits'])} IU',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(minWidth: double.infinity),
                  padding: const EdgeInsets.all(16),
                  decoration: AppConstants.cardDecoration,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 16, height: 1.8),
                      children: [
                        const TextSpan(text: 'Administer '),
                        TextSpan(
                          text: _formatNumber(_selectedReconstitution!['syringeUnits']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                            text: ' IU',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' on a '),
                        TextSpan(
                          text: _syringeSize.displayName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nfor a dosage of '),
                        TextSpan(
                          text: _formatNumber(_targetDose),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' $_targetDoseUnit\n'),
                        const TextSpan(text: 'by reconstituting '),
                        TextSpan(
                          text: _formatNumber(widget.medication.quantity),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' mg of '),
                        TextSpan(
                          text: widget.medication.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nwith '),
                        TextSpan(
                          text: _formatNumber(_selectedReconstitution!['volume']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(
                            text: ' mL',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(text: ' of '),
                        TextSpan(
                          text: _reconstitutionFluidController.text,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nConcentration: '),
                        TextSpan(
                          text: '${_formatNumber(_selectedReconstitution!['concentration'])} mg/mL',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              ],
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                ),
                child: const Text('Save',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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