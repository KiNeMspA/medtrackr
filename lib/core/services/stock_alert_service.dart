// lib/core/services/stock_alert_service.dart
import 'package:flutter/material.dart'; // For TimeOfDay
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/app/enums.dart'; // For FrequencyType
import 'package:medtrackr/features/schedule/models/schedule.dart';

class StockAlertService {
  static void scheduleStockAlert(Medication medication) async {
    final notificationService = NotificationService();
    await notificationService.init();
    if (medication.isLowStock) {
      await notificationService.scheduleNotification(
        Schedule(
          id: 'stock_alert_${medication.id}',
          medicationId: medication.id,
          dosageId: '',
          dosageName: 'Low Stock Alert',
          dosageAmount: 0,
          dosageUnit: '',
          time: TimeOfDay.fromDateTime(DateTime.now()),
          frequencyType: FrequencyType.once,
          nextDoseTime: DateTime.now().add(const Duration(minutes: 1)),
        ),
        [medication],
        [],
      );
    }
  }
}