import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/providers/data_provider.dart';
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
      time: _selectedTime,
      frequencyType: FrequencyType.values.firstWhere(
            (e) => e.toString().split('.').last == _frequency.toLowerCase(),
        orElse: () => FrequencyType.daily,
      ),
      name: dataProvider.dosages.firstWhere((d) => d.id == _selectedDosageId).name,
      amount: dataProvider.dosages.firstWhere((d) => d.id == _selectedDosageId).amount,
      dosageUnit: dataProvider.dosages.firstWhere((d) => d.id == _selectedDosageId).dosageUnit,
      notificationTime: _cyclePeriodController.text.isNotEmpty
          ? int.tryParse(_cyclePeriodController.text)
          : null,
    );

    try {
      print('Saving schedule for medication: ${schedule.medicationId}');
      await dataProvider.addScheduleAsync(schedule);
      print('Schedule saved successfully');
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/medication_details',
          arguments: dataProvider.medications.firstWhere((m) => m.id == _selectedMedicationId),
        );
      }
    } catch (e) {
      print('Error saving schedule: $e');
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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add Schedule'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Schedule Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMedicationId,
                decoration: InputDecoration(
                  labelText: 'Medication',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: medications
                    .map((med) => DropdownMenuItem(
                  value: med.id,
                  child: Text(med.name),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMedicationId = value;
                    _selectedDosageId = null; // Reset dosage when medication changes
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDosageId,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: dataProvider.dosages
                    .where((dosage) => dosage.medicationId == _selectedMedicationId)
                    .map((dosage) => DropdownMenuItem(
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
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                trailing: const Icon(Icons.access_time, color: Color(0xFFFFC107)),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['hourly', 'daily', 'weekly', 'monthly']
                    .map((freq) => DropdownMenuItem(value: freq, child: Text(freq.capitalize())))
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
                decoration: InputDecoration(
                  labelText: 'Cycle Period (optional, days)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _saveSchedule(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: const Text('Save Schedule', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 0, // Home selected
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