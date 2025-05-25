import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medtrackr/providers/notification_service.dart';
import 'package:medtrackr/providers/storage_service.dart';

class DataProvider with ChangeNotifier {
  List<Medication> _medications = [];
  List<Schedule> _schedules = [];
  List<Dosage> _dosages = [];
  final NotificationService _notificationService;

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
        final adjustedHour =
        isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

        final scheduleTime =
        DateTime(now.year, now.month, now.day, adjustedHour, minute);
        final nextTime = scheduleTime.isBefore(now)
            ? scheduleTime.add(const Duration(days: 1))
            : scheduleTime;

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

  DataProvider({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService() {
    _loadData();
  }

  void addMedication(Medication medication) {
    if (_medications
        .any((m) => m.name.toLowerCase() == medication.name.toLowerCase())) {
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
    _notificationService.cancelNotification(id.hashCode);
    _saveData();
    notifyListeners();
  }

  void deleteDosage(String id) {
    _dosages.removeWhere((d) => d.id == id);
    _schedules.removeWhere((s) => s.dosageId == id);
    _notificationService.cancelNotification(id.hashCode);
    _saveData();
    notifyListeners();
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    _notificationService.cancelNotification(id.hashCode);
    _saveData();
    notifyListeners();
  }

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    _notificationService.scheduleNotification(schedule, _medications, _dosages);
    _saveData();
    notifyListeners();
  }

  void updateSchedule(String id, Schedule updatedSchedule) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      _notificationService.cancelNotification(id.hashCode);
      _notificationService.scheduleNotification(
          updatedSchedule, _medications, _dosages);
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

  final StorageService _storageService;

  DataProvider({NotificationService? notificationService, StorageService? storageService})
      : _notificationService = notificationService ?? NotificationService(),
        _storageService = storageService ?? StorageService() {
    _loadData();
  }

  Future<void> _saveData() async {
    await _storageService.saveData(_medications, _schedules, _dosages);
  }

  Future<void> _loadData() async {
    final data = await _storageService.loadData();
    _medications = data['medications'] ?? [];
    _schedules = data['schedules'] ?? [];
    _dosages = data['dosages'] ?? [];
    notifyListeners();
  }
}