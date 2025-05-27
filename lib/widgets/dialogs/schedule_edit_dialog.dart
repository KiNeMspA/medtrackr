import 'package:flutter/material.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/enums/frequency_type.dart';

class ScheduleEditDialog extends StatefulWidget {
  final Schedule schedule;
  final Function(Schedule) onSave;

  const ScheduleEditDialog({super.key, required this.schedule, required this.onSave});

  @override
  _ScheduleEditDialogState createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<ScheduleEditDialog> {
  late TextEditingController _dosageNameController;
  late TextEditingController _dosageAmountController;
  late TextEditingController _cyclePeriodController;
  late String _dosageUnit;
  late TimeOfDay _time;
  late FrequencyType _frequencyType;

  @override
  void initState() {
    super.initState();
    _dosageNameController = TextEditingController(text: widget.schedule.dosageName);
    _dosageAmountController = TextEditingController(text: widget.schedule.dosageAmount.toString());
    _cyclePeriodController = TextEditingController(text: widget.schedule.notificationTime?.toString() ?? '');
    _dosageUnit = widget.schedule.dosageUnit;
    _time = widget.schedule.time;
    _frequencyType = widget.schedule.frequencyType;
  }

  @override
  void dispose() {
    _dosageNameController.dispose();
    _dosageAmountController.dispose();
    _cyclePeriodController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() {
        _time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[50],
      title: const Text('Edit Schedule'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _dosageNameController,
              decoration: const InputDecoration(labelText: 'Dosage Name'),
            ),
            TextFormField(
              controller: _dosageAmountController,
              decoration: const InputDecoration(labelText: 'Dosage Amount'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _cyclePeriodController,
              decoration: const InputDecoration(labelText: 'Cycle Period (optional, days)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _dosageUnit,
              decoration: const InputDecoration(labelText: 'Dosage Unit'),
              items: ['g', 'mg', 'mcg', 'mL', 'IU', 'Unit']
                  .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                  .toList(),
              onChanged: (value) => setState(() => _dosageUnit = value!),
            ),
            ListTile(
              title: Text('Time: ${_time.format(context)}'),
              onTap: () => _selectTime(context),
            ),
            DropdownButtonFormField<String>(
              value: _frequencyType.toString().split('.').last,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: ['hourly', 'daily', 'weekly', 'monthly']
                  .map((freq) => DropdownMenuItem(value: freq, child: Text(freq)))
                  .toList(),
              onChanged: (value) => setState(() {
                _frequencyType = FrequencyType.values.firstWhere(
                      (e) => e.toString().split('.').last == value,
                  orElse: () => FrequencyType.daily,
                );
              }),
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
              id: widget.schedule.id.toString(),
              dosageName: _dosageNameController.text,
              dosageAmount: double.tryParse(_dosageAmountController.text) ?? widget.schedule.dosageAmount,
              dosageUnit: _dosageUnit,
              time: _time,
              frequencyType: _frequencyType,
              notificationTime: int.tryParse(_cyclePeriodController.text),
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