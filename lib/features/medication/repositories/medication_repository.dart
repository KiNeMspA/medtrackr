// In lib/features/medication/repositories/medication_repository.dart

import 'package:medtrackr/core/services/database_service.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class MedicationRepository {
  final DatabaseService _databaseService;

  MedicationRepository(this._databaseService);

  Future<List<Medication>> loadMedications() async {
    final data = await _databaseService.loadData();
    return data['medications'] as List<Medication>;
  }

  Future<void> addMedication(Medication medication) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    medications.add(medication);
    await _databaseService.saveData(
      medications: medications,
      dosages: dosages,
      schedules: schedules,
    );
  }

  Future<void> updateMedication(String id, Medication medication) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    final index = medications.indexWhere((m) => m.id == id);
    if (index != -1) {
      medications[index] = medication;
      await _databaseService.saveData(
        medications: medications,
        dosages: dosages,
        schedules: schedules,
      );
    }
  }

  Future<void> deleteMedication(String id) async {
    final data = await _databaseService.loadData();
    final medications = data['medications'] as List<Medication>;
    final dosages = data['dosages'] as List<Dosage>;
    final schedules = data['schedules'] as List<Schedule>;
    medications.removeWhere((m) => m.id == id);
    dosages.removeWhere((d) => d.medicationId == id);
    schedules.removeWhere((s) => s.medicationId == id);
    await _databaseService.saveData(
      medications: medications,
      dosages: dosages,
      schedules: schedules,
    );
  }
}