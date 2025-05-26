import 'package:flutter/material.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/dosage_method.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  TimeOfDay _time = TimeOfDay.now();
  FrequencyType _frequencyType = FrequencyType.daily;
  int _cyclePeriod = 1;
  String? _selectedMedicationId;
  String? _selectedDosageId;

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time && context.mounted) {
      setState(() {
        _time = picked;
      });
    }
  }

  void _saveSchedule(BuildContext context) async {
    if (_selectedMedicationId == null || _selectedDosageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a medication and dosage')),
      );
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final dosage = dataProvider.dosages.firstWhere(
          (d) => d.id == _selectedDosageId,
      orElse: () => Dosage(
        id: '',
        medicationId: '',
        name: '',
        method: DosageMethod.subcutaneous,
        doseUnit: '',
        totalDose: 0.0,
        volume: 0.0,
        insulinUnits: 0.0,
      ),
    );

    if (dosage.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid dosage selected')),
      );
      return;
    }

    final schedule = Schedule(
      id: const Uuid().v4(),
      medicationId: _selectedMedicationId!,
      dosageId: _selectedDosageId!,
      dosageName: dosage.name,
      time: _time,
      dosageAmount: dosage.totalDose,
      dosageUnit: dosage.doseUnit,
      frequencyType: _frequencyType,
      notificationTime: '${_time.hour}:${_time.minute}',
    );

    try {
      print('Saving schedule: ${schedule.dosageName}');
      await dataProvider.addScheduleAsync(schedule);
      if (context.mounted) {
        Navigator.pop(context);
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
    final dosages = _selectedMedicationId != null
        ? dataProvider.getDosagesForMedication(_selectedMedicationId!)
        : [];

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
              Text(
                'Schedule Details',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
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
                    .map((m) => DropdownMenuItem<String>(
                  value: m.id,
                  child: Text(m.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedMedicationId = value;
                  _selectedDosageId = null;
                }),
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
                items: dosages
                    .map((d) => DropdownMenuItem<String>(
                  value: d.id,
                  child: Text(d.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDosageId = value),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Time: ${_time.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FrequencyType>(
                value: _frequencyType,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: FrequencyType.values
                    .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last.capitalize()),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _frequencyType = value!),
              ),
              const SizedBox(height: 16),
              if (_frequencyType == FrequencyType.daily || _frequencyType == FrequencyType.weekly) ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Cycle Period (${_frequencyType == FrequencyType.daily ? 'days' : 'weeks'})',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {
                    _cyclePeriod = int.tryParse(value) ?? 1;
                  }),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: () => _saveSchedule(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Schedule', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}