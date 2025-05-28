// lib/features/dosage/data/repos/dosage_repository.dart
import 'package:medtrackr/core/services/database_service.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class DosageRepository {
  final DatabaseService _databaseService;

  DosageRepository(this._databaseService);

  Future<List<Dosage>> loadDosages() async {
    final data = await _databaseService.loadData();
    return data['dosages'] as List<Dosage>;
  }

  Future<void> addDosage(Dosage dosage) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    dosages.add(dosage);
    await _databaseService.saveData(
      medications: medications,
      dosages: dosages,
      schedules: schedules,
    );
  }

  Future<void> updateDosage(String id, Dosage dosage) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    final index = dosages.indexWhere((d) => d.id == id);
    if (index != -1) {
      dosages[index] = dosage;
      await _databaseService.saveData(
        medications: medications,
        dosages: dosages,
        schedules: schedules,
      );
    }
  }

  Future<void> deleteDosage(String id) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    dosages.removeWhere((d) => d.id == id);
    schedules.removeWhere((s) => s.dosageId == id);
    await _databaseService.saveData(
      medications: medications,
      dosages: dosages,
      schedules: schedules,
    );
  }
}