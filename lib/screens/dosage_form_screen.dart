import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/enums/dosage_method.dart';
import 'package:medtrackr/models/enums/syringe_size.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';

class AddDosageScreen extends StatefulWidget {
  final Medication medication;
  final Dosage? dosage;

  const AddDosageScreen({super.key, required this.medication, this.dosage});

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  String _doseUnit = 'mcg';
  DosageMethod _method = DosageMethod.subcutaneous;
  SyringeSize? _syringeSize;
  bool _isSaving = false;
  int _doseCount = 0;

  @override
  void initState() {
    super.initState();
    final isReconstituted = widget.medication.reconstitutionVolume > 0;
    final recon = widget.medication.selectedReconstitution;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _doseCount = dataProvider.getDosagesForMedication(widget.medication.id).length + 1;

    if (widget.dosage != null) {
      _amountController.text = widget.dosage!.totalDose.toString();
      _doseUnit = widget.dosage!.doseUnit;
      _method = widget.dosage!.method;
      _nameController.text = widget.dosage!.name;
      _syringeSize = recon != null && recon['syringeSize'] != null
          ? SyringeSize.values.firstWhere(
            (e) => e.value == recon['syringeSize'],
        orElse: () => SyringeSize.size1_0,
      )
          : null;
    } else {
      if (isReconstituted && recon != null) {
        _amountController.text =
            _formatNumber(recon['targetDose']?.toDouble() ?? 0);
        _doseUnit = recon['targetDoseUnit'] ?? 'mcg';
        _syringeSize = recon['syringeSize'] != null
            ? SyringeSize.values.firstWhere(
              (e) => e.value == recon['syringeSize'],
          orElse: () => SyringeSize.size1_0,
        )
            : SyringeSize.size1_0;
        _nameController.text = 'Dose ${_formatNumber(recon['targetDose']?.toDouble() ?? 0)} ${_doseUnit}';
      } else {
        _nameController.text = 'Dose $_doseCount';
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final amount = double.parse(_amountController.text);
    final dosage = Dosage(
      id: widget.dosage?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: amount,
      volume: 0.0,
      insulinUnits: 0.0,
      time: TimeOfDay.now(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          widget.dosage == null ? 'Add Dosage' : 'Update Dosage',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [Shadow(color: AppConstants.primaryColor, blurRadius: 2)],
          ),
        ),
        content: Text(
          '${widget.dosage == null ? 'Add' : 'Update'} dosage "${_nameController.text}" of $amount $_doseUnit via ${_method.displayName}${_syringeSize != null ? ' with ${_syringeSize!.displayName}' : ''} for ${widget.medication.name}?',
          style: AppConstants.cardBodyStyle,
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
                style: AppConstants.dialogButtonStyle,
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) {
      setState(() => _isSaving = false);
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      if (widget.dosage == null) {
        await dataProvider.addDosageAsync(dosage);
      } else {
        await dataProvider.updateDosageAsync(dosage.id, dosage);
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving dosage: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInjection = [
      DosageMethod.subcutaneous,
      DosageMethod.intramuscular,
      DosageMethod.intravenous
    ].contains(_method);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(widget.dosage == null ? 'Add Dosage' : 'Edit Dosage'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dosage Details for ${widget.medication.name}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Dosage Name',
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Please enter a name' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: AppConstants.formFieldDecoration.copyWith(
                          labelText: 'Dosage Amount',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Please enter a valid positive number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child: DropdownButtonFormField<String>(
                        value: _doseUnit,
                        decoration: AppConstants.formFieldDecoration.copyWith(
                          labelText: 'Unit',
                        ),
                        items: ['mg', 'mcg', 'IU']
                            .map((unit) =>
                            DropdownMenuItem(value: unit, child: Text(unit)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _doseUnit = value);
                          }
                        },
                        validator: (value) =>
                        value == null ? 'Please select a unit' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<DosageMethod>(
                  value: _method,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Dosage Method',
                  ),
                  items: DosageMethod.values
                      .map((method) =>
                      DropdownMenuItem(value: method, child: Text(method.displayName)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _method = value;
                        if (!isInjection) _syringeSize = null;
                      });
                    }
                  },
                  validator: (value) =>
                  value == null ? 'Please select a method' : null,
                ),
                if (isInjection) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SyringeSize>(
                    value: _syringeSize,
                    decoration: AppConstants.formFieldDecoration.copyWith(
                      labelText: 'Syringe Size',
                    ),
                    items: SyringeSize.values
                        .map((size) =>
                        DropdownMenuItem(value: size, child: Text(size.displayName)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _syringeSize = value);
                      }
                    },
                    validator: (value) =>
                    value == null ? 'Please select a syringe size' : null,
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveDosage(context),
                  style: AppConstants.actionButtonStyle,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save'),
                ),
              ],
            ),
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