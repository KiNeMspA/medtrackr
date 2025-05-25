// lib/providers/data_provider.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrackr/main.dart'; // Import main.dart for flutterLocalNotificationsPlugin

class DataProvider with ChangeNotifier {
  List<Medication> _medications = [];
  List<Schedule> _schedules = [];
  List<Dosage> _dosages = [];

  List<Medication> get medications => _medications;
  List<Schedule> get schedules => _schedules;
  List<Dosage> get dosages => _dosages;

  DataProvider() {
    _loadData();
  }

  void addMedication(Medication medication) {
    _medications.add(medication);
    _saveData();
    notifyListeners();
  }

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    _scheduleNotification(schedule);
    _saveData();
    notifyListeners();
  }

  void addDosage(Dosage dosage) {
    _dosages.add(dosage);
    _saveData();
    notifyListeners();
  }

  Future<void> _scheduleNotification(Schedule schedule) async {
    try {
      final timeParts = schedule.notificationTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].split(' ')[0]);
      final isPM = timeParts[1].contains('PM');
      final adjustedHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        schedule.id.hashCode,
        'Medication Reminder',
        'Time to take your medication', // Generic message
        _nextInstanceOfTime(adjustedHour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medtrackr_channel',
            'Medication Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: schedule.frequencyType == FrequencyType.daily
            ? DateTimeComponents.time
            : DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  DateTime _nextInstanceOfTime(int hour, int minute) {
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> _saveData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medtrackr_data.json');
    final data = {
      'medications': _medications.map((m) => m.toJson()).toList(),
      'schedules': _schedules.map((s) => s.toJson()).toList(),
      'dosages': _dosages.map((d) => d.toJson()).toList(),
    };
    await file.writeAsString(json.encode(data));
  }

  Future<void> _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medtrackr_data.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        _medications = (data['medications'] as List)
            .map((m) => Medication.fromJson(m))
            .toList();
        _schedules = (data['schedules'] as List)
            .map((s) => Schedule.fromJson(s))
            .toList();
        _dosages = (data['dosages'] as List)
            .map((d) => Dosage.fromJson(d))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }
}