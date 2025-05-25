import 'package:flutter/material.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:uuid/uuid.dart';

class AddScheduleScreen extends StatefulWidget {
  final Medication? medication;
  final List<Dosage>? dosages;

  const AddScheduleScreen({super.key, this.medication, this.dosages});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  FrequencyType _frequencyType = FrequencyType.daily;
  TimeOfDay? _notificationTime;
  final _timeController = TextEditingController();
  List<String> _selectedDays = [];
  String? _selectedDosageId;

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
        _timeController.text = _formatTime(picked);
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Select Time';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      backgroundColor: Colors.grey[300],
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
            DropdownButtonFormField<FrequencyType>(
              value: _frequencyType,
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: FrequencyType.values
                  .map((freq) => DropdownMenuItem(
                value: freq,
                child: Text(freq == FrequencyType.daily ? 'Daily' : 'Weekly'),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _frequencyType = value!),
            ),
            const SizedBox(height: 16),
            if (_frequencyType == FrequencyType.weekly) ...[
              const Text('Select Days:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: daysOfWeek
                    .map((day) => FilterChip(
                  label: Text(day),
                  selected: _selectedDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedDays.add(day);
                      } else {
                        _selectedDays.remove(day);
                      }
                    });
                  },
                ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: () => _selectTime(context),
              decoration: InputDecoration(
                labelText: 'Notification Time *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Select Time',
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            if (widget.dosages != null && widget.dosages!.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                value: _selectedDosageId,
                decoration: InputDecoration(
                  labelText: 'Select Dosage *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: widget.dosages!
                    .map((dosage) => DropdownMenuItem(
                  value: dosage.id,
                  child: Text(dosage.name),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDosageId = value),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_notificationTime == null || (widget.dosages != null && _selectedDosageId == null)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }
                final schedule = Schedule(
                  id: const Uuid().v4(),
                  medicationId: widget.medication?.id ?? '',
                  dosageId: _selectedDosageId ?? '',
                  frequencyType: _frequencyType,
                  notificationTime: _formatTime(_notificationTime),
                  selectedDays: _selectedDays,
                );
                Navigator.pop(context, schedule);
              },
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