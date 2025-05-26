import 'package:flutter/material.dart';
import 'package:medtrackr/models/schedule.dart';

class ScheduleEditDialog extends StatefulWidget {
  final Schedule schedule;
  final Function(Schedule) onSave;

  const ScheduleEditDialog({super.key, required this.schedule, required this.onSave});

  @override
  _ScheduleEditDialogState createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<ScheduleEditDialog> {
  late TextEditingController _timeController;
  late FrequencyType _frequency;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(text: widget.schedule.notificationTime);
    _frequency = widget.schedule.frequencyType;
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[50],
      title: const Text('Edit Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _timeController,
              decoration: InputDecoration(
                labelText: 'Notification Time (e.g., 8:00 AM)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<FrequencyType>(
              value: _frequency,
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFFC107)),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: FrequencyType.values
                  .map((f) => DropdownMenuItem(
                value: f,
                child: Text(f.toString().split('.').last),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _frequency = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final updatedSchedule = widget.schedule.copyWith(
              notificationTime: _timeController.text,
              frequencyType: _frequency,
            );
            widget.onSave(updatedSchedule);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}