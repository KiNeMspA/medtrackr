import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:medtrackr/main.dart';

class DataProvider with ChangeNotifier {
  List<Medication> _medications = [];
  List<Schedule> _schedules = [];
  List<Dosage> _dosages = [];

  List<Medication> get medications => _medications;
  List<Schedule> get schedules => _schedules;
  List<Dosage> get dosages => _dosages;

  List<Map<String, dynamic>> get upcomingDoses {
    final now = DateTime.now();
    final upcoming = <Map<String, dynamic>>[];

    for (final medication in _medications) {
      final schedule = getScheduleForMedication(medication.id);
      final dosages = getDosagesForMedication(medication.id);

      if (schedule != null) {
        final timeParts = schedule.notificationTime.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1].split(' ')[0]);
        final isPM = timeParts[1].contains('PM');
        final adjustedHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

        final scheduleTime = DateTime(now.year, now.month, now.day, adjustedHour, minute);
        final nextTime = scheduleTime.isBefore(now) ? scheduleTime.add(const Duration(days: 1)) : scheduleTime;

        upcoming.add({
          'medication': medication,
          'schedule': schedule,
          'dosages': dosages,
          'nextTime': nextTime,
        });
      } else {
        upcoming.add({
          'medication': medication,
          'schedule': null,
          'dosages': dosages,
          'nextTime': DateTime.now().add(const Duration(days: 365)),
        });
      }
    }

    upcoming.sort((a, b) => a['nextTime'].compareTo(b['nextTime']));
    return upcoming;
  }

  DataProvider() {
    _loadData();
  }

  void addMedication(Medication medication) {
    if (_medications.any((m) => m.name.toLowerCase() == medication.name.toLowerCase())) {
      return;
    }
    _medications.add(medication);
    _saveData();
    notifyListeners();
  }

  void updateMedication(String id, Medication updatedMedication) {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index] = updatedMedication;
      _saveData();
      notifyListeners();
    }
  }

  void deleteMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    _schedules.removeWhere((s) => s.medicationId == id);
    _dosages.removeWhere((d) => d.medicationId == id);
    flutterLocalNotificationsPlugin.cancel(id.hashCode);
    _saveData();
    notifyListeners();
  }

  void deleteDosage(String id) {
    _dosages.removeWhere((d) => d.id == id);
    _schedules.removeWhere((s) => s.dosageId == id);
    flutterLocalNotificationsPlugin.cancel(id.hashCode);
    _saveData();
    notifyListeners();
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    flutterLocalNotificationsPlugin.cancel(id.hashCode);
    _saveData();
    notifyListeners();
  }

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    _scheduleNotification(schedule);
    _saveData();
    notifyListeners();
  }

  void updateSchedule(String id, Schedule updatedSchedule) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      flutterLocalNotificationsPlugin.cancel(id.hashCode);
      _scheduleNotification(updatedSchedule);
      _saveData();
      notifyListeners();
    }
  }

  void addDosage(Dosage dosage) {
    _dosages.add(dosage);
    if (dosage.takenTime != null) {
      final medication = _medications.firstWhere(
            (m) => m.id == dosage.medicationId,
        orElse: () => Medication(
          id: '',
          name: '',
          type: '',
          quantityUnit: '',
          quantity: 0.0,
          remainingQuantity: 0.0,
          reconstitutionVolumeUnit: '',
          reconstitutionVolume: 0.0,
          reconstitutionFluid: '',
          notes: '',
        ),
      );
      if (medication.id.isNotEmpty) {
        updateMedication(
          medication.id,
          medication.copyWith(
            remainingQuantity: medication.remainingQuantity - dosage.totalDose,
          ),
        );
      }
    }
    _saveData();
    notifyListeners();
  }

  void takeDose(String medicationId, String scheduleId, String dosageId) {
    final dosage = _dosages.firstWhere(
          (d) => d.id == dosageId,
      orElse: () => Dosage(
        id: '',
        medicationId: '',
        name: '',
        method: DosageMethod.subcutaneous,
        doseUnit: '',
        totalDose: 0.0,
        volume: 0.0,
        insulinUnits: 0.0,
      ),
    );
    if (dosage.id.isNotEmpty) {
      final medication = _medications.firstWhere(
            (m) => m.id == medicationId,
        orElse: () => Medication(
          id: '',
          name: '',
          type: '',
          quantityUnit: '',
          quantity: 0.0,
          remainingQuantity: 0.0,
          reconstitutionVolumeUnit: '',
          reconstitutionVolume: 0.0,
          reconstitutionFluid: '',
          notes: '',
        ),
      );
      if (medication.id.isNotEmpty) {
        updateMedication(
          medication.id,
          medication.copyWith(
            remainingQuantity: medication.remainingQuantity - dosage.totalDose,
          ),
        );
      }
      addDosage(dosage.copyWith(takenTime: DateTime.now()));
    }
    deleteSchedule(scheduleId);
  }

  void cancelDose(String scheduleId) {
    deleteSchedule(scheduleId);
  }

  void postponeDose(String scheduleId, String newTime) {
    final schedule = _schedules.firstWhere(
          (s) => s.id == scheduleId,
      orElse: () => Schedule(
        id: '',
        medicationId: '',
        dosageId: '',
        notificationTime: '',
        frequencyType: FrequencyType.daily,
      ),
    );
    if (schedule.id.isNotEmpty) {
      updateSchedule(
        scheduleId,
        schedule.copyWith(notificationTime: newTime),
      );
    }
  }

  Schedule? getScheduleForMedication(String medicationId) {
    return _schedules.firstWhere(
          (s) => s.medicationId == medicationId,
      orElse: () => Schedule(
        id: '',
        medicationId: '',
        dosageId: '',
        notificationTime: '',
        frequencyType: FrequencyType.daily,
      ),
    ).id.isNotEmpty
        ? _schedules.firstWhere((s) => s.medicationId == medicationId)
        : null;
  }

  List<Dosage> getDosagesForMedication(String medicationId) {
    return _dosages.where((d) => d.medicationId == medicationId).toList();
  }

  Future<void> _scheduleNotification(Schedule schedule) async {
    try {
      final medication = _medications.firstWhere(
            (m) => m.id == schedule.medicationId,
        orElse: () => Medication(
          id: '',
          name: 'Unknown Medication',
          type: '',
          quantityUnit: '',
          quantity: 0.0,
          remainingQuantity: 0.0,
          reconstitutionVolumeUnit: '',
          reconstitutionVolume: 0.0,
          reconstitutionFluid: '',
          notes: '',
        ),
      );
      final dosage = _dosages.firstWhere(
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
    } catch (e) {
      print('Error scheduling notification: $e');
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