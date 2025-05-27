import 'package:medtrackr/models/enums/frequency_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:medtrackr/models/enums/dosage_method.dart';
import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService({FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin})
      : _flutterLocalNotificationsPlugin =
      flutterLocalNotificationsPlugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> scheduleNotification(
      Schedule schedule, List<Medication> medications, List<Dosage> dosages) async {
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
        )
      );
      final dosage = dosages.firstWhere(
            (d) => d.id == schedule.dosageId,
        orElse: () => Dosage(
          id: '',
          medicationId: '',
          name: 'Unknown Dosage',
          method: DosageMethod.subcutaneous,
          doseUnit: '',
          totalDose: 0.0,
          volume: 0.0,
          insulinUnits: 0.0,
          time: TimeOfDay.now(),
        ),
      );

      final hour = schedule.time.hour;
      final minute = schedule.time.minute;

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        schedule.id.hashCode,
        'Reminder: ${medication.name} - ${dosage.name}',
        'Time to take ${dosage.totalDose} ${dosage.doseUnit} of ${medication.name}',
        _nextInstanceOfTime(hour, minute),
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
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> rescheduleAllNotifications(
      List<Schedule> schedules, List<Medication> medications, List<Dosage> dosages) async {
    await cancelAllNotifications();
    for (final schedule in schedules) {
      await scheduleNotification(schedule, medications, dosages);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}