import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:uuid/uuid.dart';


extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _cyclePeriodController = TextEditingController();
  String? _selectedMedicationId;
  String? _selectedDosageId;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _frequency = 'Daily';
  Medication? _preselectedMedication;
  Dosage? _preselectedDosage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _preselectedMedication = args['medication'] as Medication?;
      _preselectedDosage = args['dosage'] as Dosage?;
      if (_preselectedMedication != null) {
        _selectedMedicationId = _preselectedMedication!.id;
      }
      if (_preselectedDosage != null) {
        _selectedDosageId = _preselectedDosage!.id;
      }
    }
  }

  @override
  void dispose() {
    _cyclePeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveSchedule(BuildContext context) async {
    if (_selectedMedicationId == null || _selectedDosageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medication and dosage')),
      );
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final schedule = Schedule(
      id: const Uuid().v4(),
      medicationId: _selectedMedicationId!,
      dosageId: _selectedDosageId!,
      dosageName: dataProvider.dosages.firstWhere((d) => d.id == _selectedDosageId).name,
      dosageAmount: dataProvider.dosages.firstWhere((d) => d.id == _selectedDosageId).totalDose,
      dosageUnit: dataProvider.dosages.firstWhere((d) => d.id == _selectedDosageId).doseUnit,
      time: _selectedTime,
      frequencyType: FrequencyType.values.firstWhere(
            (e) => e.toString().split('.').last == _frequency.toLowerCase(),
        orElse: () => FrequencyType.daily,
      ),
      notificationTime: _cyclePeriodController.text.isNotEmpty
          ? int.tryParse(_cyclePeriodController.text)
          : null,
    );

    try {
      await dataProvider.addScheduleAsync(schedule);
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/medication_details',
          arguments: dataProvider.medications.firstWhere((m) => m.id == _selectedMedicationId),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final medications = dataProvider.medications;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Schedule'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule Details',
                style: AppConstants.cardTitleStyle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMedicationId,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Medication',
                ),
                items: medications
                    .map<DropdownMenuItem<String>>((med) => DropdownMenuItem(
                  value: med.id,
                  child: Text(med.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMedicationId = value;
                    _selectedDosageId = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDosageId,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Dosage',
                ),
                items: dataProvider.dosages
                    .where((dosage) => dosage.medicationId == _selectedMedicationId)
                    .map<DropdownMenuItem<String>>((dosage) => DropdownMenuItem(
                  value: dosage.id,
                  child: Text(dosage.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDosageId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Time: ${_selectedTime.format(context)}',
                  style: AppConstants.cardBodyStyle,
                ),
                trailing: Icon(Icons.access_time, color: AppConstants.primaryColor),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Frequency',
                ),
                items: ['hourly', 'daily', 'weekly', 'monthly']
                    .map<DropdownMenuItem<String>>((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq.capitalize()),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _frequency = value ?? 'Daily';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cyclePeriodController,
                decoration: AppConstants.formFieldDecoration.copyWith(
                  labelText: 'Cycle Period (optional, days)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => _saveSchedule(context),
                  style: AppConstants.actionButtonStyle,
                  child: const Text('Save Schedule'),
                ),
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