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
  final _reconstitutionFluidController = TextEditingController();
  final _targetDoseController = TextEditingController();
  final _volumeController =
      TextEditingController(); // New controller for volume
  String _targetDoseUnit = 'mcg';
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _targetDose = 0;
  String? _reconstitutionError;
  double _syringeSize = 1.0;

  @override
  void initState() {
    super.initState();
    _reconstitutionFluidController.text =
        widget.medication.reconstitutionFluid.isNotEmpty
            ? widget.medication.reconstitutionFluid
            : 'Bac Water';
    _targetDose = 600 / 1000; // Default to 600mcg
    _targetDoseController.text = _targetDose.toStringAsFixed(2);
    _volumeController.text = '1.00'; // Default volume
    _calculateReconstitutionSuggestions();
  }

  @override
  void dispose() {
    _reconstitutionFluidController.dispose();
    _targetDoseController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  void _calculateReconstitutionSuggestions() {
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
    final concentration = result['selectedReconstitution'] != null
        ? (result['selectedReconstitution']['concentration'] as double?) ?? 0.0
        : 0.0;

    setState(() {
      _reconstitutionSuggestions = (result['suggestions'] as List<dynamic>?)
              ?.cast<Map<String, dynamic>>() ??
          [];
      _selectedReconstitution =
          result['selectedReconstitution'] as Map<String, dynamic>?;
      _targetDose = (result['targetDose'] as double?) ?? 0.0;
      _reconstitutionError = result['error'] as String? ??
          (concentration < 0.1 || concentration > 10
              ? 'Warning: Concentration is ${concentration.toStringAsFixed(2)} mg/mL, recommended range is 0.1–10 mg/mL.'
              : null);
    });
  }

  void _nudgeVolume(bool increase) {
    double currentVolume = double.tryParse(_volumeController.text) ?? 1.0;
    currentVolume = increase ? currentVolume + 0.1 : currentVolume - 0.1;
    if (currentVolume < 0.1) currentVolume = 0.1; // Minimum volume
    _volumeController.text = currentVolume.toStringAsFixed(2);
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
            shadows: [Shadow(color: Color(0xFFFFC107), blurRadius: 2)],
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
                    text: 'Fluid: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${_reconstitutionFluidController.text}\n'),
                const TextSpan(
                    text: 'Volume: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text:
                        '${_selectedReconstitution!['volume'].toStringAsFixed(2)} mL\n'),
                const TextSpan(
                    text: 'Concentration: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text:
                        '${_selectedReconstitution!['concentration'].toStringAsFixed(2)} mg/mL\n'),
                const TextSpan(
                    text: 'Target Dose: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text: '${(_targetDose * 1000).toStringAsFixed(0)} mcg'),
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
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
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
                  labelText: 'Fluid (e.g., Bac Water)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => _calculateReconstitutionSuggestions(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetDoseController,
                decoration: InputDecoration(
                  labelText: 'Target Dose (mg)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                  suffixText: _targetDoseUnit,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _calculateReconstitutionSuggestions(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _volumeController,
                      decoration: InputDecoration(
                        labelText: 'Reconstitution Volume (mL)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          _calculateReconstitutionSuggestions(),
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
                        DropdownMenuItem(value: size, child: Text('$size mL')))
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
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.black, fontSize: 16, height: 1.6),
                      children: [
                        TextSpan(
                            text:
                                'Reconstitute ${widget.medication.name} (${widget.medication.quantity.toStringAsFixed(2)}mg) with '),
                        TextSpan(
                          text:
                              '${_selectedReconstitution!['volume'].toStringAsFixed(2)} mL',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                            text:
                                ' of ${_reconstitutionFluidController.text}.\n'),
                        const TextSpan(text: 'Target Dose: '),
                        TextSpan(
                          text:
                              '${(_targetDose * 1000).toStringAsFixed(0)} mcg',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: '\nSyringe: '),
                        TextSpan(
                          text:
                              '${_syringeSize.toStringAsFixed(2)} mL (${_selectedReconstitution!['syringeUnits'].toStringAsFixed(2)} IU)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
