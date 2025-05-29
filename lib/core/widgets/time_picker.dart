// lib/core/widgets/time_picker.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class CustomTimePicker extends StatelessWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final bool isDark;

  const CustomTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    int hour = initialTime.hour;
    int minute = initialTime.minute;

    return AlertDialog(
      title: const Text('Select Time', style: TextStyle(fontFamily: 'Poppins')),
      backgroundColor: AppConstants.backgroundColor(isDark),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: hour,
                items: List.generate(
                    24,
                        (index) => DropdownMenuItem(
                      value: index,
                      child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontFamily: 'Poppins')),
                    )),
                onChanged: (value) {
                  if (value != null) {
                    hour = value;
                    onTimeSelected(TimeOfDay(hour: hour, minute: minute));
                  }
                },
              ),
              const Text(':', style: TextStyle(fontFamily: 'Poppins')),
              DropdownButton<int>(
                value: minute,
                items: List.generate(
                    60,
                        (index) => DropdownMenuItem(
                      value: index,
                      child: Text(index.toString().padLeft(2, '0'), style: const TextStyle(fontFamily: 'Poppins')),
                    )),
                onChanged: (value) {
                  if (value != null) {
                    minute = value;
                    onTimeSelected(TimeOfDay(hour: hour, minute: minute));
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor(isDark), fontFamily: 'Poppins')),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: AppConstants.dialogButtonStyle(),
          child: const Text('OK', style: TextStyle(fontFamily: 'Poppins')),
        ),
      ],
    );
  }
}