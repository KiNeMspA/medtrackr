enum DosageMethod { subcutaneous, intramuscular, other }
enum FrequencyType { daily, selectedDays }

class DosageSchedule {
  final String medicationId;
  final DosageMethod method;
  final String doseUnit; // mcg, mg
  final double totalDose;
  final double volume; // mL
  final double insulinUnits; // IU
  final FrequencyType frequencyType;
  final List<int>? selectedDays;
  final String notificationTime; // e.g., "22:00"
  final List<DateTime> takenDoses;

  DosageSchedule({
    required this.medicationId,
    required this.method,
    required this.doseUnit,
    required this.totalDose,
    required this.volume,
    required this.insulinUnits,
    required this.frequencyType,
    this.selectedDays,
    this.notificationTime = '',
    this.takenDoses = const [],
  });

  Map<String, dynamic> toJson() => {
    'medicationId': medicationId,
    'method': method.toString(),
    'doseUnit': doseUnit,
    'totalDose': totalDose,
    'volume': volume,
    'insulinUnits': insulinUnits,
    'frequencyType': frequencyType.toString(),
    'selectedDays': selectedDays,
    'notificationTime': notificationTime,
    'takenDoses': takenDoses.map((e) => e.toIso8601String()).toList(),
  };

  factory DosageSchedule.fromJson(Map<String, dynamic> json) => DosageSchedule(
    medicationId: json['medicationId'],
    method: DosageMethod.values.firstWhere((e) => e.toString() == json['method']),
    doseUnit: json['doseUnit'],
    totalDose: json['totalDose'],
    volume: json['volume'],
    insulinUnits: json['insulinUnits'],
    frequencyType: FrequencyType.values.firstWhere((e) => e.toString() == json['frequencyType']),
    selectedDays: json['selectedDays'] != null ? List<int>.from(json['selectedDays']) : null,
    notificationTime: json['notificationTime'],
    takenDoses: json['takenDoses'] != null
        ? (json['takenDoses'] as List).map((e) => DateTime.parse(e)).toList()
        : [],
  );

  DosageSchedule copyWith({List<DateTime>? takenDoses}) => DosageSchedule(
    medicationId: medicationId,
    method: method,
    doseUnit: doseUnit,
    totalDose: totalDose,
    volume: volume,
    insulinUnits: insulinUnits,
    frequencyType: frequencyType,
    selectedDays: selectedDays,
    notificationTime: notificationTime,
    takenDoses: takenDoses ?? this.takenDoses,
  );
}