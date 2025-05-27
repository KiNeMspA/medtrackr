import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/widgets/forms/dosage_form_fields.dart';

class DosageFormScreen extends StatefulWidget {
  final Medication? medication;
  final Dosage? dosage;

  const DosageFormScreen({super.key, this.medication, this.dosage});

  @override
  _DosageFormScreenState createState() => _DosageFormScreenState();
}

class _DosageFormScreenState extends State<DosageFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _tabletCountController = TextEditingController();
  late bool isReconstituted;
  String _doseUnit = 'mg';
  DosageMethod _method = DosageMethod.oral;
  SyringeSize? _syringeSize;
  bool _isSaving = false;
  int _doseCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.medication == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return;
    }
    isReconstituted = widget.medication!.reconstitutionVolume > 0;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet ||
        widget.medication!.type == MedicationType.capsule;
    final recon = widget.medication!.selectedReconstitution;
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    _doseCount = dataProvider.getDosagesForMedication(widget.medication!.id).length + 1;

    if (widget.dosage != null) {
      _amountController.text = widget.dosage!.totalDose.toString();
      _doseUnit = widget.dosage!.doseUnit;
      _method = widget.dosage!.method;
      _nameController.text = widget.dosage!.name;
      _tabletCountController.text =
      isTabletOrCapsule ? widget.dosage!.totalDose.toInt().toString() : '';
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
        _doseUnit = recon['targetDoseUnit'] ?? 'mcg';
        _syringeSize = recon['syringeSize'] != null
            ? SyringeSize.values.firstWhere(
              (e) => e.value == recon['syringeSize'],
          orElse: () => SyringeSize.size1_0,
        )
            : SyringeSize.size1_0;
        _nameController.text = '$syringeUnits IU containing $targetDose $_doseUnit';
        _method = DosageMethod.subcutaneous;
      } else if (isTabletOrCapsule) {
        _doseUnit = 'tablets';
        _method = DosageMethod.oral;
        _nameController.text = 'Dose $_doseCount';
      } else {
        _doseUnit = 'mg';
        _method = isInjection ? DosageMethod.subcutaneous : DosageMethod.oral;
        _nameController.text = 'Dose $_doseCount';
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _tabletCountController.dispose();
    super.dispose();
  }

  String _formatNumber(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet ||
        widget.medication!.type == MedicationType.capsule;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isReconstituted = widget.medication!.reconstitutionVolume > 0;

    // Validate injection volume
    if (isInjection && !isReconstituted && widget.medication!.quantityUnit != QuantityUnit.mL) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Non-reconstituted injection requires a volume (mL) set in medication')),
      );
      setState(() => _isSaving = false);
      return;
    }

    // Parse amount
    double amount = 0.0;
    if (isTabletOrCapsule) {
      amount = double.tryParse(_tabletCountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid tablet count')),
        );
        setState(() => _isSaving = false);
        return;
      }
    } else {
      amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid dosage amount')),
        );
        setState(() => _isSaving = false);
        return;
      }
    }

    // Calculate volume for injections
    double volume = 0.0;
    if (isInjection && isReconstituted && widget.medication!.selectedReconstitution != null) {
      final concentration = widget.medication!.selectedReconstitution!['concentration']?.toDouble() ?? 1.0;
      volume = amount / concentration;
    } else if (isInjection) {
      volume = amount; // Dosage amount in mL for non-reconstituted
    }

    final dosage = Dosage(
      id: widget.dosage?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.medication!.id,
      name: _nameController.text.isEmpty ? 'Dose $_doseCount' : _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: amount,
      volume: volume,
      insulinUnits: isReconstituted && widget.medication!.selectedReconstitution != null
          ? (widget.medication!.selectedReconstitution!['syringeUnits'] as num?)?.toDouble() ?? 0.0
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
              if (isInjection) ...[
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
              TextSpan(text: widget.medication!.name),
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
    if (widget.medication == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet ||
        widget.medication!.type == MedicationType.capsule;

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
                  'Dosage Details for ${widget.medication!.name}',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                DosageFormFields(
                  nameController: _nameController,
                  amountController: _amountController,
                  tabletCountController: _tabletCountController,
                  doseUnit: _doseUnit,
                  method: _method,
                  syringeSize: _syringeSize,
                  isInjection: isInjection,
                  isTabletOrCapsule: isTabletOrCapsule,
                  isReconstituted: isReconstituted,
                  onDoseUnitChanged: (value) {
                    if (value != null) {
                      setState(() => _doseUnit = value);
                    }
                  },
                  onMethodChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _method = value;
                        if (!isInjection) _syringeSize = null;
                      });
                    }
                  },
                  onSyringeSizeChanged: (value) {
                    if (value != null) {
                      setState(() => _syringeSize = value);
                    }
                  },
                ),
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