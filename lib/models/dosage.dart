import 'package:flutter/foundation.dart';
import 'package:medtrackr/models/dosage_method.dart';

class Dosage {
  final String id;
  final String medicationId;
  final String name;
  final DosageMethod method;
  final String doseUnit;
  final double totalDose;
  final double volume;
  final double insulinUnits;
  final DateTime? takenTime;

  Dosage({
    required this.id,
    required this.medicationId,
    required this.name,
    required this.method,
    required this.doseUnit,
    required this.totalDose,
    required this.volume,
    required this.insulinUnits,
    this.takenTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'name': name,
    'method': method.toString().split('.').last,
    'doseUnit': doseUnit,
    'totalDose': totalDose,
    'volume': volume,
    'insulinUnits': insulinUnits,
    'takenTime': takenTime?.toIso8601String(),
  };

  factory Dosage.fromJson(Map<String, dynamic> json) => Dosage(
    id: json['id'],
    medicationId: json['medicationId'],
    name: json['name'] ?? 'Default Dose',
    method: DosageMethod.values.firstWhere(
          (e) => e.toString().split('.').last == json['method'],
      orElse: () => DosageMethod.topical,
    ),
    doseUnit: json['doseUnit'],
    totalDose: json['totalDose'],
    volume: json['volume'] ?? 0.0,
    insulinUnits: json['insulinUnits'] ?? 0.0,
    takenTime: json['takenTime'] != null ? DateTime.parse(json['takenTime']) : null,
  );

  Dosage copyWith({
    String? id,
    String? medicationId,
    String? name,
    DosageMethod? method,
    String? doseUnit,
    double? totalDose,
    double? volume,
    double? insulinUnits,
    DateTime? takenTime,
  }) =>
      Dosage(
        id: id ?? this.id,
        medicationId: medicationId ?? this.medicationId,
        name: name ?? this.name,
        method: method ?? this.method,
        doseUnit: doseUnit ?? this.doseUnit,
        totalDose: totalDose ?? this.totalDose,
        volume: volume ?? this.volume,
        insulinUnits: insulinUnits ?? this.insulinUnits,
        takenTime: takenTime ?? this.takenTime,
      );
}