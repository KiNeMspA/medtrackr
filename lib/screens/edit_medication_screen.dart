import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';

class EditMedicationScreen extends StatefulWidget {
  final Medication medication;

  const EditMedicationScreen({super.key, required this.medication});

  @override
  _EditMedicationScreenState createState() => _EditMedicationScreenState();
}

class _EditMedicationScreenState extends State<EditMedicationScreen> {
  final _nameController = TextEditingController();
  String _type = 'Injection';
  String _quantityUnit = 'mcg';
  final _quantityController = TextEditingController();
  bool _isReconstituting = false;
  final _targetDoseController = TextEditingController();
  String _targetDoseUnit = 'mcg';
  final _reconstitutionFluidController = TextEditingController();
  final _notesController = TextEditingController();
  List<Map<String, dynamic>> _reconstitutionSuggestions = [];
  Map<String, dynamic>? _selectedReconstitution;
  double _totalAmount = 0;
  double _targetDose = 0;
  String _medicationName = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.medication.name;
    _type = widget.medication.type;
    _quantityUnit = widget.medication.quantityUnit;
    _quantityController.text = widget.medication.quantity.toInt().toString();
    _isReconstituting = widget.medication.reconstitutionVolume > 0;
    _reconstitutionFluidController.text = widget.medication.reconstitutionFluid;
    _notesController.text = widget.medication.notes;
    _reconstitutionSuggestions = widget.medication.reconstitutionOptions;
    _selectedReconstitution = widget.medication.selectedReconstitution;
    _totalAmount = widget.medication.quantity;
    _medicationName = widget.medication.name;
    _targetDose = widget.medication.selectedReconstitution?['iu']?.toDouble() ?? 0;
    _targetDoseController.text = _targetDose.toInt().toString();
    _targetDoseUnit = 'mcg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _targetDoseController.dispose();
    _reconstitutionFluidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateReconstitutionSuggestions() {
    final totalAmount = int.tryParse(_quantityController.text) ?? 0;
    final targetDose = int.tryParse(_targetDoseController.text) ?? 0;
    print('Calculate: totalAmount=$totalAmount, targetDose=$targetDose, quantityUnit=$_quantityUnit, targetDoseUnit=$_targetDoseUnit');
    if (totalAmount <= 0 || targetDose <= 0) {
      print('Invalid input: totalAmount or targetDose is zero or negative');
      setState(() {
        _reconstitutionSuggestions = [];
        _selectedReconstitution = null;
        _totalAmount = 0;
        _targetDose = 0;
        _medicationName = '';
      });
      return;
    }

    final totalMcg = _quantityUnit == 'mg' ? totalAmount * 1000 : totalAmount;
    final targetMcg = _targetDoseUnit == 'mg' ? targetDose * 1000 : targetDose;

    setState(() {
      _totalAmount = _quantityUnit == 'mg' ? totalAmount.toDouble() : (totalMcg / 1000).toDouble();
      _targetDose = targetMcg.toDouble();
      _medicationName = _nameController.text.isNotEmpty ? _nameController.text : 'Medication';
    });

    const volumes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    final suggestions = <Map<String, dynamic>>[];
    for (final volume in volumes) {
      final concentration = totalMcg / volume;
      final iuPerDose = (targetMcg / concentration) * 100; // Assuming 100 IU per mL syringe
      if (iuPerDose >= 10 && iuPerDose <= 100) {
        suggestions.add({
          'volume': volume,
          'iu': iuPerDose.round(),
          'concentration': concentration.round(),
        });
      }
    }
    print('Suggestions generated: $suggestions');
    setState(() {
      _reconstitutionSuggestions = suggestions;
      if (_selectedReconstitution != null && !suggestions.any((s) => s['volume'] == _selectedReconstitution!['volume'])) {
        _selectedReconstitution = null;
      }
    });
  }

  void _editReconstitution(Map<String, dynamic> suggestion) async {
    final volumeController = TextEditingController(text: suggestion['volume'].toString());
    final iuController = TextEditingController(text: suggestion['iu'].toString());
    final fluidController = TextEditingController(text: _reconstitutionFluidController.text);

    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[50],
        title: const Text('Edit Reconstitution'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: volumeController,
                decoration: InputDecoration(
                  labelText: 'Volume (mL)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iuController,
                decoration: InputDecoration(
                  labelText: 'IU per Dose',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: fluidController,
                decoration: InputDecoration(
                  labelText: 'Reconstitution Fluid',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final volume = int.tryParse(volumeController.text) ?? suggestion['volume'];
              final iu = int.tryParse(iuController.text) ?? suggestion['iu'];
              Navigator.pop(context, {
                'volume': volume,
                'iu': iu,
                'concentration': suggestion['concentration'],
              });
              _reconstitutionFluidController.text = fluidController.text;
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null) {
      setState(() {
        _selectedReconstitution = updated;
      });
    }
  }

  Future<void> _saveMedication(BuildContext context) async {
    if (_nameController.text.isEmpty || _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (_isReconstituting && _selectedReconstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a reconstitution option')),
      );
      return;
    }

    final medication = widget.medication.copyWith(
      name: _nameController.text,
      type: _type,
      quantityUnit: _quantityUnit,
      quantity: (int.tryParse(_quantityController.text) ?? 0).toDouble(),
      remainingQuantity: (int.tryParse(_quantityController.text) ?? 0).toDouble(),
      reconstitutionVolumeUnit: _isReconstituting ? 'mL' : '',
      reconstitutionVolume: _isReconstituting ? (_selectedReconstitution != null ? _selectedReconstitution!['volume'].toDouble() : 0) : 0,
      reconstitutionFluid: _isReconstituting ? _reconstitutionFluidController.text : '',
      notes: _notesController.text,
      reconstitutionOptions: _isReconstituting ? _reconstitutionSuggestions : [],
      selectedReconstitution: _isReconstituting ? _selectedReconstitution : null,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[100],
        title: Text(
          'Confirm Medication Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.green[900],
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Name: ${medication.name}\n'
                'Type: ${medication.type}\n'
                'Quantity: ${medication.quantity.toInt()} ${medication.quantityUnit}\n'
                '${medication.reconstitutionVolume > 0 ? 'Reconstituted with ${medication.reconstitutionVolume.toInt()} mL\nIU per Dose: ${_selectedReconstitution?['iu'] ?? 0} IU\nFluid: ${medication.reconstitutionFluid.isNotEmpty ? medication.reconstitutionFluid : 'None'}\n' : ''}'
                'Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.green[900],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    Provider.of<DataProvider>(context, listen: false).updateMedication(widget.medication.id, medication);

    // Pass reconstitution data to AddDosageScreen
    await Navigator.pushNamed(
      context,
      '/add_dosage',
      arguments: {
        'medication': medication,
        'targetDoseMcg': _targetDose,
        'selectedIU': _selectedReconstitution?['iu']?.toDouble() ?? 0,
      },
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isTabletOrCapsule = _type == 'Tablet' || _type == 'Capsule';

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Edit Medication'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medication Details',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Medication Name *',
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
                onChanged: (value) => setState(() {
                  _medicationName = value.isNotEmpty ? value : 'Medication';
                  _calculateReconstitutionSuggestions();
                }),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(
                  labelText: 'Type',
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
                items: ['Injection', 'Tablet', 'Capsule', 'Other']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _type = value!;
                  _calculateReconstitutionSuggestions();
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
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
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Total Medication Amount *',
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
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (_) => setState(() {
                        _calculateReconstitutionSuggestions();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _quantityUnit,
                      decoration: InputDecoration(
                        labelText: 'Measure',
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
                      items: ['mcg', 'mg', 'mL', 'IU']
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) => setState(() {
                        _quantityUnit = value!;
                        _calculateReconstitutionSuggestions();
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Text(
                    'Reconstitute this medication?',
                    style: TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  Switch(
                    value: _isReconstituting,
                    activeColor: const Color(0xFFFFC107),
                    onChanged: (value) => setState(() {
                      _isReconstituting = value;
                      if (!value) {
                        _reconstitutionSuggestions = [];
                        _selectedReconstitution = null;
                        _totalAmount = 0;
                        _targetDose = 0;
                        _medicationName = _nameController.text.isNotEmpty ? _nameController.text : 'Medication';
                        _reconstitutionFluidController.text = '';
                      }
                      _calculateReconstitutionSuggestions();
                    }),
                  ),
                ],
              ),
              if (_isReconstituting) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _reconstitutionFluidController,
                  decoration: InputDecoration(
                    labelText: 'Reconstitution Fluid (e.g., Saline, Water)',
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
                  onChanged: (_) => _calculateReconstitutionSuggestions(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _targetDoseController,
                        decoration: InputDecoration(
                          labelText: 'Target Single Dosage *',
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
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => setState(() {
                          _calculateReconstitutionSuggestions();
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _targetDoseUnit,
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
                        items: ['mcg', 'mg']
                            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                        onChanged: (value) => setState(() {
                          _targetDoseUnit = value!;
                          _calculateReconstitutionSuggestions();
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_reconstitutionSuggestions.isNotEmpty && _selectedReconstitution == null) ...[
                  const Text(
                    'Reconstitution Options:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._reconstitutionSuggestions.take(4).map((suggestion) => Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFFFC107), width: 2),
                    ),
                    elevation: 4,
                    color: Colors.grey[50],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            const TextSpan(text: 'Option: '),
                            TextSpan(
                              text: '${suggestion['volume']} mL',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                            const TextSpan(text: ' = '),
                            TextSpan(
                              text: '${suggestion['iu']} IU',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                          ],
                        ),
                        softWrap: true,
                      ),
                      subtitle: Text(
                        'For ${_totalAmount.toInt()} $_quantityUnit of “$_medicationName” at ${_targetDose.toInt()} mcg',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFFFFC107)),
                        onPressed: () {
                          setState(() {
                            _selectedReconstitution = suggestion;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Selected ${suggestion['volume']} mL reconstitution')),
                          );
                        },
                      ),
                    ),
                  )),
                ],
                if (_selectedReconstitution != null) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Selected Reconstitution:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green[900]!, width: 2),
                    ),
                    elevation: 4,
                    color: Colors.green[100],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[900]),
                          children: [
                            const TextSpan(text: 'Option: '),
                            TextSpan(
                              text: '${_selectedReconstitution!['volume']} mL',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' = '),
                            TextSpan(
                              text: '${_selectedReconstitution!['iu']} IU',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        softWrap: true,
                      ),
                      subtitle: Text(
                        'For ${_totalAmount.toInt()} $_quantityUnit of “$_medicationName” at ${_targetDose.toInt()} mcg\n'
                            'Fluid: ${_reconstitutionFluidController.text.isNotEmpty ? _reconstitutionFluidController.text : 'None'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.green[900]),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.green[900]),
                            onPressed: () => _editReconstitution(_selectedReconstitution!),
                          ),
                          IconButton(
                            icon: Icon(Icons.clear, color: Colors.green[900]),
                            onPressed: () {
                              setState(() {
                                _selectedReconstitution = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveMedication(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Medication', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}