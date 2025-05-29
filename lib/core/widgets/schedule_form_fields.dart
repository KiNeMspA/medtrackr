// lib/core/widgets/schedule_form_fields.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';

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
  final bool isDark;

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
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<Dosage>(
          value: selectedDosage,
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Dosage *',
          ),
          items: dosages
              .map((dosage) => DropdownMenuItem(
            value: dosage,
            child: Text(
              '${dosage.name} (${formatNumber(dosage.totalDose)} ${dosage.doseUnit})',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
          ))
              .toList(),
          onChanged: onDosageChanged,
          validator: (value) => value == null ? 'Please select a dosage' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: dosageNameController,
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Schedule Name (Optional)',
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: Text('Time: ${time.format(context)}', style: AppThemes.cardBodyStyle(isDark)),
          trailing: const Icon(Icons.access_time, color: AppConstants.primaryColor),
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
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Frequency *',
          ),
          items: FrequencyType.values
              .map((freq) => DropdownMenuItem(
            value: freq,
            child: Text(freq.displayName, style: const TextStyle(fontFamily: 'Poppins')),
          ))
              .toList(),
          onChanged: onFrequencyChanged,
          validator: (value) => value == null ? 'Please select a frequency' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: notificationTime?.toString(),
          decoration: AppConstants.formFieldDecoration(isDark).copyWith(
            labelText: 'Reminder (Minutes Before, Optional)',
          ),
          keyboardType: TextInputType.number,
          validator: (value) => value != null && value.isNotEmpty ? Validators.positiveNumber(value, 'Reminder Time') : null,
          onChanged: (value) {
            onNotificationTimeChanged(int.tryParse(value));
          },
        ),
      ],
    );
  }
}