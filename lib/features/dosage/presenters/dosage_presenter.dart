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

  List<Dosage> getDosagesForMedication(String medicationId) {
    return _dosages.where((d) => d.medicationId == medicationId).toList();
  }

  Dosage? getDosageById(String id) {
    try {
      return _dosages.firstWhere((dosage) => dosage.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> loadDosages() async {
    try {
      final data = await _repository.loadDosages();
      _dosages = data;
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load dosages: $e');
    }
  }

  Future<void> addDosage(Dosage dosage) async {
    try {
      await _repository.addDosage(dosage);
      _dosages.add(dosage);
      if (dosage.takenTime != null) {
        await _updateMedicationQuantity(dosage);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add dosage: $e');
    }
  }

  Future<void> updateDosage(String id, Dosage dosage) async {
    try {
      await _repository.updateDosage(id, dosage);
      final index = _dosages.indexWhere((d) => d.id == id);
      if (index != -1) {
        _dosages[index] = dosage;
        if (dosage.takenTime != null) {
          await _updateMedicationQuantity(dosage);
        }
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update dosage: $e');
    }
  }

  Future<void> deleteDosage(String id) async {
    try {
      await _repository.deleteDosage(id);
      _dosages.removeWhere((d) => d.id == id);
      await _notificationService.cancelNotification(id.hashCode);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete dosage: $e');
    }
  }

  Future<void> takeDose(String medicationId, String scheduleId, String dosageId) async {
    try {
      final dosageIndex = _dosages.indexWhere((d) => d.id == dosageId);
      if (dosageIndex == -1) throw Exception('Dosage not found');
      final dosage = _dosages[dosageIndex];
      final updatedDosage = dosage.copyWith(takenTime: DateTime.now());
      await updateDosage(dosageId, updatedDosage);
      await _notificationService.cancelNotification(scheduleId.hashCode);
    } catch (e) {
      throw Exception('Failed to take dose: $e');
    }
  }

  Future<void> _updateMedicationQuantity(Dosage dosage) async {
    try {
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
      if (medication.id.isEmpty) throw Exception('Medication not found');
      double doseInMg = dosage.totalDose;
      if (dosage.doseUnit == 'mcg') {
        doseInMg = dosage.totalDose / 1000;
      } else if (dosage.doseUnit == 'g') {
        doseInMg = dosage.totalDose * 1000;
      }
      final newQuantity = medication.remainingQuantity - doseInMg;
      if (newQuantity < 0) throw Exception('Insufficient stock');
      await _medicationPresenter.updateMedication(
        medication.id,
        medication.copyWith(remainingQuantity: newQuantity),
      );
    } catch (e) {
      throw Exception('Failed to update medication quantity: $e');
    }
  }
}