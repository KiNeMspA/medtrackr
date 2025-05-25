import 'package:flutter/material.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/dosage.dart';
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
  final _notificationTimeController = TextEditingController();
  List<String> _selectedDays = [];
  String? _selectedDosageId;

  @override
  void dispose() {
    _notificationTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
              controller: _notificationTimeController,
              decoration: InputDecoration(
                labelText: 'Notification Time (e.g., 8:00 AM) *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
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
                if (_notificationTimeController.text.isEmpty || (widget.dosages != null && _selectedDosageId == null)) {
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
                  notificationTime: _notificationTimeController.text,
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