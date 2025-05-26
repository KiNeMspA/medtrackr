import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/models/schedule.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medtrackr/services/notification_service.dart';
import 'package:medtrackr/models/dosage_method.dart';

class DataProvider with ChangeNotifier {
  final List<Medication> _medications = [];
  final List<Schedule> _schedules = [];
  final List<Dosage> _dosages = [];
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
        final notificationTime = schedule.notificationTime?.toString() ?? '';
        final hour = schedule.time.hour;
        final minute = schedule.time.minute;

        final scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
        final nextTime = scheduleTime.isBefore(now)
            ? scheduleTime.add(Duration(days: schedule.frequencyType == FrequencyType.daily ? 1 : 7))
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

  Future<void> addScheduleAsync(Schedule schedule) async {
    _schedules.add(schedule);
    await _notificationService.scheduleNotification(schedule, _medications, _dosages);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateScheduleAsync(String id, Schedule updatedSchedule) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      await _notificationService.cancelNotification(id.hashCode);
      await _notificationService.scheduleNotification(updatedSchedule, _medications, _dosages);
      await _saveData();
      notifyListeners();
    }
  }

  void addDosage(Dosage dosage) {
    addDosageAsync(dosage);
  }

  Future<void> addDosageAsync(Dosage dosage) async {
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
        await updateMedicationAsync(
          medication.id,
          medication.copyWith(
            remainingQuantity: medication.remainingQuantity - dosage.totalDose,
          ),
        );
      }
    }
    await _saveData();
    notifyListeners();
  }

  Future<void> updateDosageAsync(String id, Dosage updatedDosage) async {
    final index = _dosages.indexWhere((d) => d.id == id);
    if (index != -1) {
      _dosages[index] = updatedDosage;
      if (updatedDosage.takenTime != null) {
        final medication = _medications.firstWhere(
              (m) => m.id == updatedDosage.medicationId,
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
          await updateMedicationAsync(
            medication.id,
            medication.copyWith(
              remainingQuantity: medication.remainingQuantity - updatedDosage.totalDose,
            ),
          );
        }
      }
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> addMedicationAsync(Medication medication) async {
    if (_medications.any((m) => m.name.toLowerCase() == medication.name.toLowerCase())) {
      return;
    }
    _medications.add(medication);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateMedicationAsync(String id, Medication updatedMedication) async {
    final index = _medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      _medications[index] = updatedMedication;
      await _saveData();
      notifyListeners();
    }
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
        updateMedicationAsync(
          medication.id,
          medication.copyWith(
            remainingQuantity: medication.remainingQuantity - dosage.totalDose,
          ),
        );
      }
      addDosageAsync(dosage.copyWith(takenTime: DateTime.now()));
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
        dosageName: '',
        time: TimeOfDay.now(),
        dosageAmount: 0.0,
        dosageUnit: '',
        frequencyType: FrequencyType.daily,
        notificationTime: '',
      ),
    );
    if (schedule.id.isNotEmpty) {
      updateScheduleAsync(
        scheduleId,
        schedule.copyWith(notificationTime: newTime),
      );
    }
  }

  Schedule? getScheduleForMedication(String medicationId) {
    try {
      return _schedules.firstWhere((s) => s.medicationId == medicationId);
    } catch (e) {
      return null;
    }
  }

  List<Dosage> getDosagesForMedication(String medicationId) {
    return _dosages.where((d) => d.medicationId == medicationId).toList();
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
        _medications.clear();
        _medications.addAll((data['medications'] as List).map((m) => Medication.fromJson(m)));
        _schedules.clear();
        _schedules.addAll((data['schedules'] as List).map((s) => Schedule.fromJson(s)));
        _dosages.clear();
        _dosages.addAll((data['dosages'] as List).map((d) => Dosage.fromJson(d)));
        notifyListeners();
      }
    } catch (e) {
      print('Error loading data: $e');
    }
  }
}