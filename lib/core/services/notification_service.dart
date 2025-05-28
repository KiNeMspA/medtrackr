// In lib/core/services/notification_service.dart

import 'package:medtrackr/app/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  NotificationService(
      {FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin})
      : _flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin ??
            FlutterLocalNotificationsPlugin();

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
        ),
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
        ),
      );
      final notificationId = schedule.id.hashCode;
      // Placeholder for actual notification scheduling (e.g., flutter_local_notifications)
      print('Scheduled notification $notificationId for ${medication.name} at ${schedule.time.format(context)}');
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

  Future<void> rescheduleAllNotifications(List<Schedule> schedules,
      List<Medication> medications, List<Dosage> dosages) async {
    await cancelAllNotifications();
    for (final schedule in schedules) {
      await scheduleNotification(schedule, medications, dosages);
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
