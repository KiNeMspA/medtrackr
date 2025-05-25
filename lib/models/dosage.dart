// lib/models/dosage.dart
enum DosageMethod { subcutaneous, intramuscular, oral, other }

class Dosage {
  final String id;
  final String medicationId; // Links to Medication
  final DosageMethod method;
  final String doseUnit; // e.g., mcg, mg
  final double totalDose; // Amount for this dosage
  final double volume; // e.g., mL
  final double insulinUnits; // e.g., IU
  final DateTime? takenTime; // When this dosage was taken (null if not taken)

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

  Dosage copyWith({DateTime? takenTime}) => Dosage(
    id: id,
    medicationId: medicationId,
    method: method,
    doseUnit: doseUnit,
    totalDose: totalDose,
    volume: volume,
    insulinUnits: insulinUnits,
    takenTime: takenTime ?? this.takenTime,
  );
}