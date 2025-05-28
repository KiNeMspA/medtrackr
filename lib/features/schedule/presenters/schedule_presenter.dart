// lib/features/schedule/presenters/schedule_presenter.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/features/schedule/data/repos/schedule_repository.dart';

class SchedulePresenter with ChangeNotifier {
  final ScheduleRepository _repository;
  final NotificationService _notificationService;
  List<Schedule> _schedules = [];
  List<Dosage> _dosages = [];
  List<Medication> _medications = [];

  SchedulePresenter(this._repository, this._notificationService);

  List<Map<String, dynamic>> get upcomingDoses {
    final now = DateTime.now();
    final upcoming = <Map<String, dynamic>>[];

    for (final medication in _medications) {
      final schedule = getScheduleForMedication(medication.id);
      final dosages = getDosagesForMedication(medication.id);

      if (schedule != null) {
        final hour = schedule.time.hour;
        final minute = schedule.time.minute;
        final scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
        final nextTime = scheduleTime.isBefore(now)
            ? scheduleTime.add(Duration(
            days: schedule.frequencyType == FrequencyType.daily ? 1 : 7))
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

  Future<void> loadSchedules() async {
    final data = await _repository.loadSchedules();
    _schedules = data;
    notifyListeners();
  }

  Future<void> setDependencies(List<Medication> medications, List<Dosage> dosages) async {
    _medications = medications;
    _dosages = dosages;
    notifyListeners();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _repository.addSchedule(schedule);
    _schedules.add(schedule);
    await _notificationService.scheduleNotification(schedule, _medications, _dosages);
    notifyListeners();
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    await _repository.updateSchedule(id, schedule);
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = schedule;
      await _notificationService.cancelNotification(id.hashCode);
      await _notificationService.scheduleNotification(schedule, _medications, _dosages);
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String id) async {
    await _repository.deleteSchedule(id);
    _schedules.removeWhere((s) => s.id == id);
    _notificationService.cancelNotification(id.hashCode);
    notifyListeners();
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

  Future<void> postponeDose(String scheduleId, String newTime) async {
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
        notificationTime: null,
      ),
    );
    if (schedule.id.isNotEmpty) {
      await updateSchedule(
        scheduleId,
        schedule.copyWith(notificationTime: int.tryParse(newTime)),
      );
    }
  }

  Future<void> cancelDose(String scheduleId) async {
    await deleteSchedule(scheduleId);
  }
}