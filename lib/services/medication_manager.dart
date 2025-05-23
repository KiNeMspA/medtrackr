import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:medtrackr/services/notification_service.dart';

class MedicationManager {
  static List<Medication> _medications = [];
  static List<DosageSchedule> _schedules = [];

  static List<Medication> get medications => _medications;
  static List<DosageSchedule> get schedules => _schedules;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final medsJson = prefs.getString('medications');
    final schedsJson = prefs.getString('schedules');
    if (medsJson != null) {
      _medications = (jsonDecode(medsJson) as List)
          .map((e) => Medication.fromJson(e))
          .toList();
    }
    if (schedsJson != null) {
      _schedules = (jsonDecode(schedsJson) as List)
          .map((e) => DosageSchedule.fromJson(e))
          .toList();
    }
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('medications', jsonEncode(_medications.map((e) => e.toJson()).toList()));
    await prefs.setString('schedules', jsonEncode(_schedules.map((e) => e.toJson()).toList()));
  }

  static void addMedication(Medication medication) {
    _medications.add(medication);
    save();
  }

  static void updateMedication(Medication medication) {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      save();
    }
  }

  static void addSchedule(DosageSchedule schedule) {
    _schedules.add(schedule);
    _scheduleNotifications(schedule);
    save();
  }

  static void markDoseTaken(Medication medication, DosageSchedule schedule, DateTime time) {
    final doseInMcg = schedule.doseUnit == 'mg' ? schedule.totalDose * 1000 : schedule.totalDose;
    final doseInQuantityUnit = medication.quantityUnit == 'mg' ? doseInMcg / 1000 : doseInMcg;
    final newRemaining = medication.remainingQuantity - doseInQuantityUnit;
    if (newRemaining >= 0) {
      updateMedication(medication.copyWith(remainingQuantity: newRemaining));
      final updatedSchedule = schedule.copyWith(takenDoses: [...schedule.takenDoses, time]);
      final index = _schedules.indexWhere((s) => s.medicationId == schedule.medicationId);
      if (index != -1) {
        _schedules[index] = updatedSchedule;
        save();
      }
    }
  }

  static Future<void> _scheduleNotifications(DosageSchedule schedule) async {
    final timeParts = schedule.notificationTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1].split(' ')[0]);
    final now = DateTime.now();
    for (int cycle = 0; cycle < schedule.totalCycles; cycle++) {
      for (int day = 0; day < schedule.cycleOn; day++) {
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day + day + (cycle * (schedule.cycleOn + schedule.cycleOff)),
          hour,
          minute,
        );
        await NotificationService.scheduleNotification(
          id: (schedule.medicationId.hashCode + day + cycle * 100),
          title: 'MedTrackr Reminder',
          body: 'Time to take ${schedule.totalDose} ${schedule.doseUnit} of medication',
          scheduledTime: scheduledTime,
        );
      }
    }
  }
}