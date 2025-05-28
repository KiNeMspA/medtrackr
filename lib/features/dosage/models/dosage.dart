//In lib/features/dosage/models/dosage.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';

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
    this.takenTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'name': name,
    'method': method.displayName,
    'doseUnit': doseUnit,
    'totalDose': totalDose,
    'volume': volume,
    'insulinUnits': insulinUnits,
    'time': {'hour': time.hour, 'minute': time.minute},
    'takenTime': takenTime?.toIso8601String(),
  };

  factory Dosage.fromJson(Map<String, dynamic> json) => Dosage(
    id: json['id'],
    medicationId: json['medicationId'],
    name: json['name'],
    method: DosageMethod.values.firstWhere(
            (e) => e.displayName == json['method'],
        orElse: () => DosageMethod.subcutaneous),
    doseUnit: json['doseUnit'],
    totalDose: json['totalDose'].toDouble(),
    volume: json['volume'].toDouble(),
    insulinUnits: json['insulinUnits'].toDouble(),
    time: TimeOfDay(
        hour: json['time']['hour'], minute: json['time']['minute']),
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