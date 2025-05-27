import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/enums/enums.dart';

class ScheduleFormFields extends StatelessWidget {
  final TextEditingController dosageNameController;
  final Dosage? selectedDosage;
  final List<Dosage> dosages;
  final TimeOfDay time;
  final FrequencyType frequencyType;
  final int? notificationTime;
  final ValueChanged<Dosage?> onDosageChanged;
  final ValueChanged<TimeOfDay?> onTimeChanged;
  final ValueChanged<FrequencyType?> onFrequencyChanged;
  final ValueChanged<int?> onNotificationTimeChanged;

  const ScheduleFormFields({
    super.key,
    required this.dosageNameController,
    required this.selectedDosage,
    required this.dosages,
    required this.time,
    required this.frequencyType,
    required this.notificationTime,
    required this.onDosageChanged,
    required this.onTimeChanged,
    required this.onFrequencyChanged,
    required this.onNotificationTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Dosage>(
          value: selectedDosage,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Dosage *',
          ),
          items: dosages
              .map((dosage) => DropdownMenuItem(
            value: dosage,
            child: Text(dosage.name),
          ))
              .toList(),
          onChanged: onDosageChanged,
          validator: (value) => value == null ? 'Please select a dosage' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: dosageNameController,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Schedule Name (Optional)',
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: Text('Time: ${time.format(context)}'),
          trailing: const Icon(Icons.access_time),
          onTap: () async {
            final selectedTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            onTimeChanged(selectedTime);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<FrequencyType>(
          value: frequencyType,
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Frequency *',
          ),
          items: FrequencyType.values
              .map((freq) => DropdownMenuItem(
            value: freq,
            child: Text(freq.displayName),
          ))
              .toList(),
          onChanged: onFrequencyChanged,
          validator: (value) => value == null ? 'Please select a frequency' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: notificationTime?.toString(),
          decoration: AppConstants.formFieldDecoration.copyWith(
            labelText: 'Notification Time (Minutes Before, Optional)',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            onNotificationTimeChanged(int.tryParse(value));
          },
        ),
      ],
    );
  }
}