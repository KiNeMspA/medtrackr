import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:uuid/uuid.dart';

class AddScheduleScreen extends StatefulWidget {
  final Medication? medication;
  final Dosage? dosage;

  const AddScheduleScreen({super.key, this.medication, this.dosage});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  FrequencyType _frequencyType = FrequencyType.daily;
  List<String> _selectedDays = [];

  void _saveSchedule(BuildContext context) {
    if (widget.medication == null || widget.dosage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medication and dosage required')),
      );
      return;
    }

    final schedule = Schedule(
      id: const Uuid().v4(),
      medicationId: widget.medication!.id,
      dosageId: widget.dosage!.id,
      frequencyType: _frequencyType,
      notificationTime:
      '${_selectedTime.hour % 12 == 0 ? 12 : _selectedTime.hour % 12}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}',
      selectedDays: _frequencyType == FrequencyType.weekly ? _selectedDays : [],
    );

    Provider.of<DataProvider>(context, listen: false).addSchedule(schedule);
    Navigator.pop(context);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Add Schedule'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                'Time: ${_selectedTime.format(context)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              trailing: const Icon(Icons.access_time, color: Color(0xFFFFC107)),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FrequencyType>(
              value: _frequencyType,
              decoration: InputDecoration(
                labelText: 'Frequency',
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
              items: FrequencyType.values
                  .map((f) => DropdownMenuItem(
                value: f,
                child: Text(f.toString().split('.').last),
              ))
                  .toList(),
              onChanged: (value) => setState(() {
                _frequencyType = value!;
                if (_frequencyType == FrequencyType.daily) {
                  _selectedDays = [];
                }
              }),
            ),
            if (_frequencyType == FrequencyType.weekly) ...[
              const SizedBox(height: 16),
              const Text(
                'Select Days:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Wrap(
                spacing: 8,
                children: [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ].map((day) {
                  final isSelected = _selectedDays.contains(day);
                  return ChoiceChip(
                    label: Text(day),
                    selected: isSelected,
                    selectedColor: const Color(0xFFFFC107),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(day);
                        } else {
                          _selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveSchedule(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Schedule', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}