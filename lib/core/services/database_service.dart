// In lib/core/services/database_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:medtrackr/app/enums.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class DatabaseService {
  Future<void> saveData({
    required List<Medication> medications,
    required List<Dosage> dosages,
    required List<Schedule> schedules,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medtrackr_data.json');
    final data = {
      'medications': medications.map((m) => m.toJson()).toList(),
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'dosages': dosages.map((d) => d.toJson()).toList(),
    };
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, List>> loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medtrackr_data.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString());
        return {
          'medications':
          (data['medications'] as List).map((m) => Medication.fromJson(m)).toList(),
          'schedules':
          (data['schedules'] as List).map((s) => Schedule.fromJson(s)).toList(),
          'dosages':
          (data['dosages'] as List).map((d) => Dosage.fromJson(d)).toList(),
        };
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
    return {'medications': [], 'schedules': [], 'dosages': []};
  }

  Future<void> migrateData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medtrackr_data.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        bool needsMigration = false;

        final medications = (data['medications'] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
            [];
        for (var i = 0; i < medications.length; i++) {
          final med = medications[i];
          if (med['type'] is String &&
              !MedicationType.values.any((e) => e.displayName == med['type'])) {
            med['type'] = _parseMedicationType(med['type'] as String).displayName;
            needsMigration = true;
          }
          if (med['quantityUnit'] is String &&
              !QuantityUnit.values
                  .any((e) => e.displayName == med['quantityUnit'])) {
            med['quantityUnit'] =
                _parseQuantityUnit(med['quantityUnit'] as String).displayName;
            needsMigration = true;
          }
        }

        if (needsMigration) {
          data['medications'] = medications;
          await file.writeAsString(jsonEncode(data));
        }
      }
    } catch (e) {
      print('Error migrating data: $e');
    }
  }

  MedicationType _parseMedicationType(String type) {
    return MedicationType.values.firstWhere(
          (e) => e.displayName.toLowerCase() == type.toLowerCase(),
      orElse: () => MedicationType.other,
    );
  }

  QuantityUnit _parseQuantityUnit(String unit) {
    return QuantityUnit.values.firstWhere(
          (e) => e.displayName.toLowerCase() == unit.toLowerCase(),
      orElse: () => QuantityUnit.mg,
    );
  }
}