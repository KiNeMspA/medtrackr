// lib/core/widgets/schedule_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class ScheduleEditDialog extends StatefulWidget {
  final Schedule schedule;
  final Function(Schedule) onSave;
  final bool isDark;

  const ScheduleEditDialog({
    super.key,
    required this.schedule,
    required this.onSave,
    required this.isDark,
  });

  @override
  _ScheduleEditDialogState createState() => _ScheduleEditDialogState();
}

class _ScheduleEditDialogState extends State<ScheduleEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dosageNameController;
  late TextEditingController _dosageAmountController;
  late TextEditingController _notificationTimeController;
  late String _dosageUnit;
  late TimeOfDay _time;
  late FrequencyType _frequencyType;

  @override
  void initState() {
    super.initState();
    _dosageNameController = TextEditingController(text: widget.schedule.dosageName);
    _dosageAmountController = TextEditingController(text: formatNumber(widget.schedule.dosageAmount));
    _notificationTimeController = TextEditingController(text: widget.schedule.notificationTime?.toString() ?? '');
    _dosageUnit = widget.schedule.dosageUnit;
    _time = widget.schedule.time;
    _frequencyType = widget.schedule.frequencyType;
  }

  @override
  void dispose() {
    _dosageNameController.dispose();
    _dosageAmountController.dispose();
    _notificationTimeController.dispose();
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
      backgroundColor: AppConstants.backgroundColor(widget.isDark),
      title: const Text('Edit Schedule', style: TextStyle(fontFamily: 'Poppins')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _dosageNameController,
                decoration: AppConstants.formFieldDecoration(widget.isDark).copyWith(labelText: 'Dosage Name'),
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageAmountController,
                decoration: AppConstants.formFieldDecoration(widget.isDark).copyWith(labelText: 'Dosage Amount'),
                keyboardType: TextInputType.number,
                validator: (value) => Validators.positiveNumber(value, 'Dosage Amount'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notificationTimeController,
                decoration: AppConstants.formFieldDecoration(widget.isDark).copyWith(
                    labelText: 'Reminder (Minutes Before, Optional)'),
                keyboardType: TextInputType.number,
                validator: (value) => value != null && value.isNotEmpty ? Validators.positiveNumber(value, 'Reminder Time') : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _dosageUnit,
                decoration: AppConstants.formFieldDecoration(widget.isDark).copyWith(labelText: 'Dosage Unit'),
                items: ['g', 'mg', 'mcg', 'mL', 'IU', 'unit']
                    .map((unit) => DropdownMenuItem(value: unit, child: Text(unit, style: const TextStyle(fontFamily: 'Poppins'))))
                    .toList(),
                onChanged: (value) => setState(() => _dosageUnit = value ?? _dosageUnit),
                validator: (value) => value == null ? 'Please select a unit' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('Time: ${_time.format(context)}', style: AppThemes.cardBodyStyle(widget.isDark)),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FrequencyType>(
                value: _frequencyType,
                decoration: AppConstants.formFieldDecoration(widget.isDark).copyWith(labelText: 'Frequency'),
                items: FrequencyType.values
                    .map((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq.displayName, style: const TextStyle(fontFamily: 'Poppins')),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _frequencyType = value ?? _frequencyType),
                validator: (value) => value == null ? 'Please select a frequency' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor(widget.isDark), fontFamily: 'Poppins')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final updatedSchedule = widget.schedule.copyWith(
                dosageName: _dosageNameController.text,
                dosageAmount: double.tryParse(_dosageAmountController.text) ?? widget.schedule.dosageAmount,
                dosageUnit: _dosageUnit,
                time: _time,
                frequencyType: _frequencyType,
                notificationTime: int.tryParse(_notificationTimeController.text),
              );
              widget.onSave(updatedSchedule);
              Navigator.pop(context);
            }
          },
          style: AppConstants.dialogButtonStyle(),
          child: const Text('Save', style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}