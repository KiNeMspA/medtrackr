// lib/features/schedule/data/repos/schedule_repository.dart
import 'package:medtrackr/core/services/database_service.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class ScheduleRepository {
  final DatabaseService _databaseService;

  ScheduleRepository(this._databaseService);

  Future<List<Schedule>> loadSchedules() async {
    final data = await _databaseService.loadData();
    return data['schedules'] as List<Schedule>;
  }

  Future<void> addSchedule(Schedule schedule) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    schedules.add(schedule);
    await _databaseService.saveData(
      medications: medications,
      dosages: dosages,
      schedules: schedules,
    );
  }

  Future<void> updateSchedule(String id, Schedule schedule) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    final index = schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      schedules[index] = schedule;
      await _databaseService.saveData(
        medications: medications,
        dosages: dosages,
        schedules: schedules,
      );
    }
  }

  Future<void> deleteSchedule(String id) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    schedules.removeWhere((s) => s.id == id);
    await _databaseService.saveData(
      medications: medications,
      dosages: dosages,
      schedules: schedules,
    );
  }
}