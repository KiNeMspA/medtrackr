import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/enums/dosage_method.dart';
import 'package:medtrackr/models/enums/syringe_size.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';

class DosageFormScreen extends StatefulWidget {
  final Medication medication;
  final Dosage? dosage;

  const DosageFormScreen({super.key, required this.medication, this.dosage});

  @override
  _DosageFormScreenState createState() => _DosageFormScreenState();
}

class _DosageFormScreenState extends State<DosageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _tabletCountController = TextEditingController();
  final _volumeController = TextEditingController();
  late bool isReconstituted;
  String _doseUnit = 'mcg';
  DosageMethod _method = DosageMethod.oral;
  SyringeSize? _syringeSize;
  bool _isSaving = false;
  int _doseCount = 0;

  @override
  void initState() {
    super.initState();
    final isReconstituted = widget.medication.reconstitutionVolume > 0;
    final isInjection = widget.medication.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication.type == MedicationType.tablet ||
        widget.medication.type == MedicationType.capsule;
    final recon = widget.medication.selectedReconstitution;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _doseCount = dataProvider.getDosagesForMedication(widget.medication.id).length + 1;

    if (widget.dosage != null) {
      _amountController.text = widget.dosage!.totalDose.toString();
      _doseUnit = widget.dosage!.doseUnit;
      _method = widget.dosage!.method;
      _nameController.text = widget.dosage!.name;
      _tabletCountController.text =
      isTabletOrCapsule ? widget.dosage!.totalDose.toInt().toString() : '';
      _volumeController.text =
      isInjection ? widget.dosage!.volume.toStringAsFixed(2) : '';
      _syringeSize = recon != null && recon['syringeSize'] != null
          ? SyringeSize.values.firstWhere(
            (e) => e.value == recon['syringeSize'],
        orElse: () => SyringeSize.size1_0,
      )
          : null;
    } else {
      if (isInjection && isReconstituted && recon != null) {
        final targetDose = recon['targetDose']?.toDouble() ?? 0;
        final syringeUnits = recon['syringeUnits']?.toDouble() ?? 0;
        _amountController.text = _formatNumber(targetDose);
        _volumeController.text =
            _formatNumber(recon['volume']?.toDouble() ?? 0);
        _doseUnit = recon['targetDoseUnit'] ?? 'mcg';
        _syringeSize = recon['syringeSize'] != null
            ? SyringeSize.values.firstWhere(
              (e) => e.value == recon['syringeSize'],
          orElse: () => SyringeSize.size1_0,
        )
            : SyringeSize.size1_0;
        _nameController.text =
        '$syringeUnits IU containing ${targetDose} $_doseUnit';
        _method = DosageMethod.subcutaneous;
      } else if (isTabletOrCapsule) {
        _doseUnit = 'tablets';
        _method = DosageMethod.oral;
        _nameController.text = 'Dose $_doseCount';
      } else {
        _nameController.text = 'Dose $_doseCount';
      }
    }

    _amountController.addListener(_updateVolume);
    _volumeController.addListener(_updateAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateVolume);
    _volumeController.removeListener(_updateAmount);
    _amountController.dispose();
    _nameController.dispose();
    _tabletCountController.dispose();
    _volumeController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  void _updateVolume() {
    if (widget.medication.type != MedicationType.injection ||
        widget.medication.reconstitutionVolume == 0) return;
    final recon = widget.medication.selectedReconstitution;
    if (recon == null) return;
    final dose = double.tryParse(_amountController.text) ?? 0;
    final concentration = recon['concentration']?.toDouble() ?? 1;
    final volume = dose / concentration;
    _volumeController.text = _formatNumber(volume);
  }

  void _updateAmount() {
    if (widget.medication.type != MedicationType.injection ||
        widget.medication.reconstitutionVolume == 0) return;
    final recon = widget.medication.selectedReconstitution;
    if (recon == null) return;
    final volume = double.tryParse(_volumeController.text) ?? 0;
    final concentration = recon['concentration']?.toDouble() ?? 1;
    final dose = volume * concentration;
    _amountController.text = _formatNumber(dose);
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final isTabletOrCapsule = widget.medication.type == MedicationType.tablet ||
        widget.medication.type == MedicationType.capsule;
    final amount = isTabletOrCapsule
        ? double.parse(_tabletCountController.text)
        : double.parse(_amountController.text);
    final volume =
    widget.medication.type == MedicationType.injection &&
        widget.medication.reconstitutionVolume > 0
        ? double.parse(_volumeController.text)
        : widget.medication.type == MedicationType.injection
        ? double.parse(_volumeController.text)
        : 0.0;

    final dosage = Dosage(
      id: widget.dosage?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: amount,
      volume: volume,
      insulinUnits: widget.medication.type == MedicationType.injection &&
          widget.medication.reconstitutionVolume > 0 &&
          widget.medication.selectedReconstitution != null
          ? (widget.medication.selectedReconstitution!['syringeUnits'] as num?)?.toDouble() ?? 0.0
          : 0.0,
      time: TimeOfDay.now(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          widget.dosage == null ? 'Add Dosage' : 'Update Dosage',
          style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
        ),
        content: RichText(
          text: TextSpan(
            style: AppConstants.cardBodyStyle.copyWith(height: 1.5),
            children: [
              const TextSpan(
                text: 'Dosage: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: dosage.name),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: 'Amount: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: isTabletOrCapsule
                      ? '${_formatNumber(amount)} tablets'
                      : '${_formatNumber(amount)} $_doseUnit',
                  style: TextStyle(color: AppConstants.primaryColor)),
              if (widget.medication.type == MedicationType.injection) ...[
                const TextSpan(text: '\n'),
                const TextSpan(
                  text: 'Volume: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                    text: '${_formatNumber(volume)} mL',
                    style: TextStyle(color: AppConstants.primaryColor)),
                if (isReconstituted) ...[
                  const TextSpan(text: '\n'),
                  const TextSpan(
                    text: 'IU: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                      text: '${_formatNumber(dosage.insulinUnits)}',
                      style: TextStyle(color: AppConstants.primaryColor)),
                ],
              ],
              const TextSpan(text: '\n'),
              const TextSpan(
                text: 'Method: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: dosage.method.displayName),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: 'Medication: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: widget.medication.name),
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: AppConstants.cardBodyStyle.copyWith(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
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
      if (mounted) {
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
    final isInjection = widget.medication.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication.type == MedicationType.tablet ||
        widget.medication.type == MedicationType.capsule;
    final isReconstituted = widget.medication.reconstitutionVolume > 0;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
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
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
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
                if (isTabletOrCapsule) ...[
                  TextFormField(
                    controller: _tabletCountController,
                    decoration: AppConstants.formFieldDecoration.copyWith(
                      labelText: 'Number of Tablets/Capsules',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of tablets';
                      }
                      if (double.tryParse(value) == null || double.tryParse(value)! <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _doseUnit,
                    decoration: AppConstants.formFieldDecoration.copyWith(
                      labelText: 'Dose per Tablet',
                    ),
                    items: ['mg', 'mcg']
                        .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _doseUnit = value);
                      }
                    },
                    validator: (value) =>
                    value == null ? 'Please select a unit' : null,
                  ),
                ] else ...[
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
                                double.parse(value)! <= 0) {
                              return 'Please enter a valid positive number';
                            }
                            return null;
                          },
                          enabled: !isReconstituted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 120,
                        child: DropdownButtonFormField<String>(
                          value: _doseUnit,
                          decoration: AppConstants.formFieldDecoration.copyWith(
                            labelText: 'Unit',
                          ),
                          items: ['mg', 'mcg', 'IU']
                              .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                              .toList(),
                          onChanged: isReconstituted
                              ? null
                              : (value) {
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
                  if (isInjection) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _volumeController,
                      decoration: AppConstants.formFieldDecoration.copyWith(
                        labelText: isReconstituted ? 'Volume (mL)' : 'Total Volume (mL)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a volume';
                        }
                        if (double.tryParse(value) == null ||
                            double.parse(value)! <= 0) {
                          return 'Please enter a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
                const SizedBox(height: 16),
                DropdownButtonFormField<DosageMethod>(
                  value: _method,
                  decoration: AppConstants.formFieldDecoration.copyWith(
                    labelText: 'Dosage Method',
                  ),
                  items: DosageMethod.values
                      .map((method) => DropdownMenuItem(
                    value: method,
                    child: Text(method.displayName),
                  ))
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
                if (isInjection &&
                    [DosageMethod.subcutaneous, DosageMethod.intramuscular, DosageMethod.intravenous]
                        .contains(_method)) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<SyringeSize>(
                    value: _syringeSize,
                    decoration: AppConstants.formFieldDecoration.copyWith(
                      labelText: 'Syringe Size',
                    ),
                    items: SyringeSize.values
                        .map((size) => DropdownMenuItem(
                      value: size,
                      child: Text(size.displayName),
                    ))
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
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveDosage(context),
                    style: AppConstants.actionButtonStyle,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Dosage'),
                  ),
                ),
              ],
            ),
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