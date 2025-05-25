// lib/screens/add_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:uuid/uuid.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  String _frequencyType = 'Daily';
  final _notificationTimeController = TextEditingController();
  final List<int> _selectedDays = [];

  @override
  void dispose() {
    _notificationTimeController.dispose();
    super.dispose();
  }

  void _toggleDay(int day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _saveSchedule() {
    if (_notificationTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a notification time')),
      );
      return;
    }

    final schedule = Schedule(
      id: const Uuid().v4(),
      medicationId: '', // Will be set by HomeScreen
      frequencyType: _frequencyType == 'Daily' ? FrequencyType.daily : FrequencyType.selectedDays,
      selectedDays: _frequencyType == 'Selected Days' ? _selectedDays : null,
      notificationTime: _notificationTimeController.text,
    );

    Navigator.pop(context, schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notificationTimeController,
                decoration: InputDecoration(
                  labelText: 'Notification Time (e.g., 8:00 AM) *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _frequencyType,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFFFC107)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: ['Daily', 'Selected Days']
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() {
                  _frequencyType = value!;
                  if (value == 'Daily') _selectedDays.clear();
                }),
              ),
              if (_frequencyType == 'Selected Days') ...[
                const SizedBox(height: 16),
                Text(
                  'Select Days',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var i = 1; i <= 7; i++)
                      ChoiceChip(
                        label: Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i - 1]),
                        selected: _selectedDays.contains(i),
                        onSelected: (_) => _toggleDay(i),
                        selectedColor: const Color(0xFFFFC107),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSchedule,
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
      ),
    );
  }
}