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
  bool _isDisposed = false;

  SchedulePresenter(this._repository, this._notificationService);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  List<Map<String, dynamic>> get upcomingDoses {
    final now = DateTime.now();
    final upcoming = <String, Map<String, dynamic>>{};

    for (final schedule in _schedules) {
      final medication = _medications.firstWhere(
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
      if (medication.id.isEmpty) continue;

      var nextTime = schedule.nextDoseTime;
      while (nextTime.isBefore(now)) {
        nextTime = nextTime.add(schedule.frequencyType.duration);
      }
      upcoming[schedule.id] = {
        'medication': medication,
        'schedule': schedule.copyWith(nextDoseTime: nextTime),
        'nextTime': nextTime,
      };
    }

    final sorted = upcoming.values.toList()..sort((a, b) => a['nextTime'].compareTo(b['nextTime']));
    return sorted;
  }

  Future<void> loadSchedules() async {
    if (!_isDisposed) {
      final data = await _repository.loadSchedules();
      _schedules = data;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> setDependencies(List<Medication> medications, List<Dosage> dosages) async {
    _medications = medications;
    _dosages = dosages;
    notifyListeners();
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _repository.addSchedule(schedule);
      _schedules.add(schedule);
      await _notificationService.scheduleNotification(schedule, _medications, _dosages);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add schedule: $e');
    }
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    try {
      await _repository.updateSchedule(id, schedule);
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) {
        _schedules[index] = schedule;
        await _notificationService.cancelNotification(id.hashCode);
        await _notificationService.scheduleNotification(schedule, _medications, _dosages);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _repository.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      await _notificationService.cancelNotification(id.hashCode);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  Schedule? getScheduleForMedication(String medicationId) {
    try {
      return _schedules.firstWhere((s) => s.medicationId == medicationId);
    } catch (e) {
      return null;
    }
  }

  Future<void> postponeDose(String scheduleId, String minutes) async {
    try {
      final scheduleIndex = _schedules.indexWhere((s) => s.id == scheduleId);
      if (scheduleIndex == -1) throw Exception('Schedule not found');
      final schedule = _schedules[scheduleIndex];
      final newNextDoseTime = schedule.nextDoseTime.add(Duration(minutes: int.parse(minutes)));
      final updatedSchedule = schedule.copyWith(nextDoseTime: newNextDoseTime, notificationTime: int.parse(minutes));
      await updateSchedule(scheduleId, updatedSchedule);
    } catch (e) {
      throw Exception('Failed to postpone dose: $e');
    }
  }

  Future<void> cancelDose(String scheduleId) async {
    await deleteSchedule(scheduleId);
  }
}