import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/enums/dosage_method.dart';
import 'package:medtrackr/widgets/forms/dosage_form_fields.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';

class AddDosageScreen extends StatefulWidget {
  final Medication medication;

  const AddDosageScreen({super.key, required this.medication});

  @override
  _AddDosageScreenState createState() => _AddDosageScreenState();
}

class _AddDosageScreenState extends State<AddDosageScreen> {
  late TextEditingController _nameController;
  late TextEditingController _doseController;
  late TextEditingController _volumeController;
  late TextEditingController _insulinUnitsController;
  late String _doseUnit;
  late DosageMethod _method;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final targetDose =
        widget.medication.selectedReconstitution?['doseVolume']?.toDouble() ??
            0;
    _nameController = TextEditingController(
      text: targetDose > 0 ? 'Dose ${targetDose * 1000}mcg' : 'Dose 1',
    );
    _doseController =
        TextEditingController(text: targetDose.toStringAsFixed(2));
    _volumeController = TextEditingController();
    _insulinUnitsController = TextEditingController();
    _doseUnit = widget.medication.quantityUnit;
    _method = DosageMethod.oral;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _volumeController.dispose();
    _insulinUnitsController.dispose();
    super.dispose();
  }

  Future<void> _saveDosage(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final dosage = Dosage(
      id: const Uuid().v4(),
      medicationId: widget.medication.id,
      name: _nameController.text,
      method: _method,
      doseUnit: _doseUnit,
      totalDose: double.tryParse(_doseController.text) ?? 0.0,
      volume: double.tryParse(_volumeController.text) ?? 0.0,
      insulinUnits: double.tryParse(_insulinUnitsController.text) ?? 0.0,
      time: TimeOfDay.now(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Confirm Dosage',
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
                    text: 'Name: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: '${dosage.name}\n'),
                const TextSpan(
                    text: 'Dose: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(
                    text:
                        '${dosage.totalDose.toStringAsFixed(2)} ${dosage.doseUnit}\n'),
                const TextSpan(
                    text: 'Method: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                TextSpan(text: dosage.method.toString().split('.').last),
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
      await dataProvider.addDosageAsync(dosage);
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/medication_details',
          arguments: widget.medication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving dosage: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add Dosage'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DosageFormFields(
                  nameController: _nameController,
                  doseController: _doseController,
                  volumeController: _volumeController,
                  insulinUnitsController: _insulinUnitsController,
                  doseUnit: _doseUnit,
                  doseUnits: ['g', 'mg', 'mcg', 'mL', 'IU', ''],
                  method: _method,
                  onDoseUnitChanged: (value) =>
                      setState(() => _doseUnit = value!),
                  onMethodChanged: (value) => setState(() => _method = value!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _saveDosage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: const Text('Save Dosage',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
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
