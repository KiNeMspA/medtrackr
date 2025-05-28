// lib/features/dosage/presenters/dosage_presenter.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/dosage/data/repos/dosage_repository.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';

class DosagePresenter with ChangeNotifier {
  final DosageRepository _repository;
  final MedicationPresenter _medicationPresenter;
  final NotificationService _notificationService;
  List<Dosage> _dosages = [];

  DosagePresenter({
    required DosageRepository repository,
    required MedicationPresenter medicationPresenter,
    required NotificationService notificationService,
  })  : _repository = repository,
        _medicationPresenter = medicationPresenter,
        _notificationService = notificationService;

  List<Dosage> get dosages => _dosages;
  MedicationPresenter get medicationPresenter => _medicationPresenter; // Add this

  List<Dosage> getDosagesForMedication(String medicationId) {
    return _dosages.where((d) => d.medicationId == medicationId).toList();
  }

  Future<void> loadDosages() async {
    final data = await _repository.loadDosages();
    _dosages = data;
    notifyListeners();
  }

  Future<void> addDosage(Dosage dosage) async {
    await _repository.addDosage(dosage);
    _dosages.add(dosage);
    if (dosage.takenTime != null) {
      await _updateMedicationQuantity(dosage);
    }
    notifyListeners();
  }

  Future<void> updateDosage(String id, Dosage dosage) async {
    await _repository.updateDosage(id, dosage);
    final index = _dosages.indexWhere((d) => d.id == id);
    if (index != -1) {
      _dosages[index] = dosage;
      if (dosage.takenTime != null) {
        await _updateMedicationQuantity(dosage);
      }
      notifyListeners();
    }
  }

  Future<void> deleteDosage(String id) async {
    await _repository.deleteDosage(id);
    _dosages.removeWhere((d) => d.id == id);
    _notificationService.cancelNotification(id.hashCode);
    notifyListeners();
  }

  Future<void> takeDose(String medicationId, String scheduleId, String dosageId) async {
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
      final updatedDosage = dosage.copyWith(takenTime: DateTime.now());
      await addDosage(updatedDosage);
    }
  }

  Future<void> _updateMedicationQuantity(Dosage dosage) async {
    final medication = _medicationPresenter.medications.firstWhere(
          (m) => m.id == dosage.medicationId,
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
    if (medication.id.isNotEmpty) {
      double doseInMg = dosage.totalDose;
      if (dosage.doseUnit == 'mcg') {
        doseInMg = dosage.totalDose / 1000;
      } else if (dosage.doseUnit == 'g') {
        doseInMg = dosage.totalDose * 1000;
      }
      await _medicationPresenter.updateMedication(
        medication.id,
        medication.copyWith(remainingQuantity: medication.remainingQuantity - doseInMg),
      );
    }
  }
}