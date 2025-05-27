import 'package:flutter/material.dart';
import 'package:medtrackr/models/enums/enums.dart';

class Dosage {
  final String id;
  final String medicationId;
  final String name;
  final DosageMethod method;
  final String doseUnit;
  final double totalDose;
  final double volume;
  final double insulinUnits;
  final TimeOfDay time;
  final DateTime? takenTime;
  //final double syringeSize;

  Dosage({
    required this.id,
    required this.medicationId,
    required this.name,
    required this.method,
    required this.doseUnit,
    required this.totalDose,
    required this.volume,
    required this.insulinUnits,
    required this.time,
    //required this.syringeSize,
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
    'time': '${time.hour}:${time.minute}',
    'takenTime': takenTime?.toIso8601String(),
  };

  factory Dosage.fromJson(Map<String, dynamic> json) => Dosage(
    id: json['id'],
    medicationId: json['medicationId'],
    name: json['name'] ?? 'Default Dose',
    method: DosageMethod.values.firstWhere(
          (e) => e.toString().split('.').last == json['method'],
      orElse: () => DosageMethod.unspecified,
    ),
    doseUnit: json['doseUnit'],
    totalDose: json['totalDose'],
    volume: json['volume'] ?? 0.0,
    insulinUnits: json['insulinUnits'] ?? 0.0,
    time: TimeOfDay(
      hour: int.parse(json['time'].split(':')[0]),
      minute: int.parse(json['time'].split(':')[1]),
    ),
    takenTime: json['takenTime'] != null
        ? DateTime.parse(json['takenTime'])
        : null,
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
    TimeOfDay? time,
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
        time: time ?? this.time,
        takenTime: takenTime ?? this.takenTime,
      );
}