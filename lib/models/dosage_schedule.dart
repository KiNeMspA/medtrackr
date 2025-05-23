enum DosageMethod { subcutaneous, intramuscular, other }
enum FrequencyType { timesPerDay, daily, timesPerWeek, selectedDays, daysOnDaysOff }

class DosageSchedule {
  final String medicationId;
  final DosageMethod method;
  final String doseUnit; // mcg, mg
  final double totalDose;
  final double volume; // mL
  final double insulinUnits; // IU
  final FrequencyType frequencyType;
  final int frequencyValue;
  final List<int>? selectedDays;
  final int cycleOn;
  final int cycleOff;
  final bool repeatCycle;
  final int totalCycles;
  final int breakDuration; // days
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
    this.frequencyValue = 1,
    this.selectedDays,
    required this.cycleOn,
    required this.cycleOff,
    required this.repeatCycle,
    this.totalCycles = 1,
    this.breakDuration = 0,
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
    'frequencyValue': frequencyValue,
    'selectedDays': selectedDays,
    'cycleOn': cycleOn,
    'cycleOff': cycleOff,
    'repeatCycle': repeatCycle,
    'totalCycles': totalCycles,
    'breakDuration': breakDuration,
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
    frequencyValue: json['frequencyValue'],
    selectedDays: json['selectedDays'] != null ? List<int>.from(json['selectedDays']) : null,
    cycleOn: json['cycleOn'],
    cycleOff: json['cycleOff'],
    repeatCycle: json['repeatCycle'],
    totalCycles: json['totalCycles'],
    breakDuration: json['breakDuration'],
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
    frequencyValue: frequencyValue,
    selectedDays: selectedDays,
    cycleOn: cycleOn,
    cycleOff: cycleOff,
    repeatCycle: repeatCycle,
    totalCycles: totalCycles,
    breakDuration: breakDuration,
    notificationTime: notificationTime,
    takenDoses: takenDoses ?? this.takenDoses,
  );
}