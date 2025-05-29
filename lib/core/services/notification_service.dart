// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService({
    FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin,
  }) : _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleNotification(Schedule schedule, List<Medication> medications, List<Dosage> dosages) async {
    try {
      final medication = medications.firstWhere(
            (m) => m.id == schedule.medicationId,
        orElse: () => Medication(
          id: '',
          name: 'Unknown',
          type: MedicationType.other,
          quantityUnit: QuantityUnit.mg,
          quantity: 0,
          remainingQuantity: 0,
          reconstitutionVolumeUnit: '',
          reconstitutionVolume: 0,
          reconstitutionFluid: '',
          notes: '',
        ),
      );
      final dosage = dosages.firstWhere(
            (d) => d.id == schedule.dosageId,
        orElse: () => Dosage(
          id: '',
          medicationId: '',
          name: 'Unknown Dosage',
          method: DosageMethod.oral,
          doseUnit: '',
          totalDose: 0.0,
          volume: 0.0,
          insulinUnits: 0.0,
        ),
      );
      if (medication.id.isEmpty || dosage.id.isEmpty) return;

      final notificationId = schedule.id.hashCode;
      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = _nextInstanceOfTime(schedule.time.hour, schedule.time.minute, schedule.frequencyType);
      if (schedule.notificationTime != null) {
        scheduledDate = scheduledDate.subtract(Duration(minutes: schedule.notificationTime!));
      }

      if (scheduledDate.isBefore(now)) return;

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Medication Reminder: ${medication.name}',
        '${dosage.name} - ${dosage.totalDose} ${dosage.doseUnit} at ${schedule.time.formatHourMinute()}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminder',
            'Medication Reminders',
            channelDescription: 'Reminders for taking your medication',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: _getMatchDateTimeComponents(schedule.frequencyType),
      );
    } catch (e) {
      throw Exception('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> rescheduleAllNotifications(List<Schedule> schedules, List<Medication> medications, List<Dosage> dosages) async {
    await cancelAllNotifications();
    for (final schedule in schedules) {
      await scheduleNotification(schedule, medications, dosages);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute, FrequencyType frequency) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(frequency.duration);
    }
    return scheduledDate;
  }

  DateTimeComponents _getMatchDateTimeComponents(FrequencyType frequency) {
    switch (frequency) {
      case FrequencyType.daily:
        return DateTimeComponents.time;
      case FrequencyType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case FrequencyType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      default:
        return DateTimeComponents.time;
    }
  }
}

extension TimeOfDayExtension on TimeOfDay {
  String formatHourMinute() {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}