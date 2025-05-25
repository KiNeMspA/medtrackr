// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:medtrackr/main.dart';
import 'package:medtrackr/models/medication.dart';



class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _toggleNotifications(bool enabled) async {
    if (!enabled) {
      await flutterLocalNotificationsPlugin.cancelAll();
    } else {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      for (final schedule in dataProvider.schedules) {
        final medication = dataProvider.medications.firstWhere(
              (m) => m.id == schedule.medicationId,
          orElse: () => Medication(
            id: '',
            name: 'Unknown Medication',
            type: '',
            storageType: '',
            quantityUnit: '',
            quantity: 0.0,
            remainingQuantity: 0.0,
            reconstitutionVolumeUnit: '',
            reconstitutionVolume: 0.0,
          ),
        );
        final dosage = dataProvider.dosages.firstWhere(
              (d) => d.id == schedule.dosageId,
          orElse: () => Dosage(
            id: '',
            medicationId: '',
            name: 'Unknown Dosage',
            method: DosageMethod.other,
            doseUnit: '',
            totalDose: 0.0,
            volume: 0.0,
            insulinUnits: 0.0,
          ),
        );

        final timeParts = schedule.notificationTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1].split(' ')[0]);
        final isPM = timeParts[1].contains('PM');
        final adjustedHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          schedule.id.hashCode,
          'Reminder: ${medication.name} - ${dosage.name}',
          'Time to take ${dosage.totalDose} ${dosage.doseUnit} of ${medication.name}',
          _nextInstanceOfTime(adjustedHour, minute),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medtrackr_channel',
              'Medication Reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: schedule.frequencyType == FrequencyType.daily
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Enable Notifications'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: const Color(0xFFFFC107),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dark Mode coming soon!')),
                    );
                  },
                  activeColor: const Color(0xFFFFC107),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}