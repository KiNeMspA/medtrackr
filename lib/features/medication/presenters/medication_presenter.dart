// lib/features/medication/presenters/medication_presenter.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/core/services/stock_alert_service.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/data/repos/medication_repository.dart';

class MedicationPresenter with ChangeNotifier {
  final MedicationRepository _repository;
  final NotificationService _notificationService;
  List<Medication> _medications = [];

  MedicationPresenter(this._repository, this._notificationService);

  List<Medication> get medications => _medications;

  Future<void> loadMedications() async {
    try {
      final data = await _repository.loadMedications();
      _medications = data;
      _checkLowStock();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to load medications: $e');
    }
  }

  Future<void> addMedication(Medication medication) async {
    try {
      if (_medications.any((m) => m.name.toLowerCase() == medication.name.toLowerCase() && m.type == medication.type)) {
        throw Exception('A medication with this name and type already exists');
      }
      await _repository.addMedication(medication);
      _medications.add(medication);
      _checkLowStock();
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to add medication: $e');
    }
  }

  Future<void> updateMedication(String id, Medication medication) async {
    try {
      await _repository.updateMedication(id, medication);
      final index = _medications.indexWhere((m) => m.id == id);
      if (index != -1) {
        _medications[index] = medication;
        _checkLowStock();
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update medication: $e');
    }
  }

  Future<void> deleteMedication(String id) async {
    try {
      await _repository.deleteMedication(id);
      _medications.removeWhere((m) => m.id == id);
      await _notificationService.cancelNotification(id.hashCode);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }

  void _checkLowStock() {
    for (var med in _medications) {
      if (med.isLowStock) {
        // Trigger stock alert (handled by WorkManager in new service)
        StockAlertService.scheduleStockAlert(med);
      }
    }
  }
}