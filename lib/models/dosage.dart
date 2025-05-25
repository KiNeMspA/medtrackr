// lib/models/dosage.dart
enum DosageMethod { subcutaneous, intramuscular, oral, other }

class Dosage {
  final String id;
  final String medicationId;
  final DosageMethod method;
  final String doseUnit;
  final double totalDose;
  final double volume;
  final double insulinUnits;
  final DateTime? takenTime;

  Dosage({
    required this.id,
    required this.medicationId,
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
    'method': method.toString(),
    'doseUnit': doseUnit,
    'totalDose': totalDose,
    'volume': volume,
    'insulinUnits': insulinUnits,
    'takenTime': takenTime?.toIso8601String(),
  };

  factory Dosage.fromJson(Map<String, dynamic> json) => Dosage(
    id: json['id'],
    medicationId: json['medicationId'],
    method: DosageMethod.values.firstWhere((e) => e.toString() == json['method']),
    doseUnit: json['doseUnit'],
    totalDose: json['totalDose'],
    volume: json['volume'],
    insulinUnits: json['insulinUnits'],
    takenTime: json['takenTime'] != null ? DateTime.parse(json['takenTime']) : null,
  );

  Dosage copyWith({
    String? medicationId,
    DateTime? takenTime,
    DosageMethod? method,
    String? doseUnit,
    double? totalDose,
    double? volume,
    double? insulinUnits,
  }) =>
      Dosage(
        id: id,
        medicationId: medicationId ?? this.medicationId,
        method: method ?? this.method,
        doseUnit: doseUnit ?? this.doseUnit,
        totalDose: totalDose ?? this.totalDose,
        volume: volume ?? this.volume,
        insulinUnits: insulinUnits ?? this.insulinUnits,
        takenTime: takenTime ?? this.takenTime,
      );
}