// In lib/core/services/storage_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:path_provider/path_provider.dart';

class StorageService {
  Future<void> saveData(
      List<Medication> medications, List<Schedule> schedules, List<Dosage> dosages) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/medtrackr_data.json');
    final data = {
      'medications': medications.map((m) => m.toJson()).toList(),
      'schedules': schedules.map((s) => s.toJson()).toList(),
      'dosages': dosages.map((d) => d.toJson()).toList(),
    };
    await file.writeAsString(json.encode(data));
  }

  Future<Map<String, List>> loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medtrackr_data.json');
      if (await file.exists()) {
        final data = json.decode(await file.readAsString());
        return {
          'medications': (data['medications'] as List)
              .map((m) => Medication.fromJson(m))
              .toList(),
          'schedules': (data['schedules'] as List)
              .map((s) => Schedule.fromJson(s))
              .toList(),
          'dosages': (data['dosages'] as List)
              .map((d) => Dosage.fromJson(d))
              .toList(),
        };
      }
    } catch (e) {
      print('Error loading data: $e');
    }
    return {'medications': [], 'schedules': [], 'dosages': []};
  }
}