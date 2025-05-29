// lib/core/services/database_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class DatabaseService {
  static const String _key = 'medtrackr_data';

  Future<Map<String, List<dynamic>>> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dataString = prefs.getString(_key);

      if (dataString == null || dataString.isEmpty) {
        // Initialize with empty lists if no data exists
        final initialData = {
          'medications': <Medication>[],
          'dosages': <Dosage>[],
          'schedules': <Schedule>[],
        };
        await prefs.setString(_key, jsonEncode(initialData));
        return initialData;
      }

      final Map<String, dynamic> data = jsonDecode(dataString);

      // Handle null values and convert to expected types
      return {
        'medications': (data['medications'] as List<dynamic>? ?? [])
            .map((item) {
          if (item == null) return null;
          final map = item as Map<String, dynamic>;
          // Ensure required fields are not null
          map['id'] ??= '';
          map['name'] ??= '';
          map['type'] ??= 'other';
          map['quantityUnit'] ??= 'mg';
          map['quantity'] ??= 0.0;
          map['remainingQuantity'] ??= 0.0;
          map['reconstitutionVolumeUnit'] ??= '';
          map['reconstitutionVolume'] ??= 0.0;
          map['reconstitutionFluid'] ??= '';
          map['notes'] ??= '';
          return Medication.fromJson(map);
        })
            .where((item) => item != null)
            .cast<Medication>()
            .toList(),
        'dosages': (data['dosages'] as List<dynamic>? ?? [])
            .map((item) {
          if (item == null) return null;
          final map = item as Map<String, dynamic>;
          // Ensure required fields are not null
          map['id'] ??= '';
          map['medicationId'] ??= '';
          map['name'] ??= '';
          map['method'] ??= 'oral';
          map['doseUnit'] ??= '';
          map['totalDose'] ??= 0.0;
          map['volume'] ??= 0.0;
          map['insulinUnits'] ??= 0.0;
          return Dosage.fromJson(map);
        })
            .where((item) => item != null)
            .cast<Dosage>()
            .toList(),
        'schedules': (data['schedules'] as List<dynamic>? ?? [])
            .map((item) {
          if (item == null) return null;
          final map = item as Map<String, dynamic>;
          // Ensure required fields are not null
          map['id'] ??= '';
          map['medicationId'] ??= '';
          map['dosageId'] ??= '';
          map['dosageName'] ??= '';
          map['dosageAmount'] ??= 0.0;
          map['dosageUnit'] ??= '';
          map['time'] ??= {'hour': 0, 'minute': 0};
          map['frequencyType'] ??= 'daily';
          map['nextDoseTime'] ??= DateTime.now().toIso8601String();
          return Schedule.fromJson(map);
        })
            .where((item) => item != null)
            .cast<Schedule>()
            .toList(),
      };
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  Future<void> saveData({
    required List<Medication> medications,
    required List<Dosage> dosages,
    required List<Schedule> schedules,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'medications': medications.map((m) => m.toJson()).toList(),
        'dosages': dosages.map((d) => d.toJson()).toList(),
        'schedules': schedules.map((s) => s.toJson()).toList(),
      };
      await prefs.setString(_key, jsonEncode(data));
    } catch (e) {
      throw Exception('Failed to save data: $e');
    }
  }

  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}