enum DosageMethod { subcutaneous, intramuscular, other }
enum FrequencyType { timesPerDay, daily, timesPerWeek, selectedDays, daysOnDaysOff }

class DosageSchedule {
  final String medicationId;
  final DosageMethod method;
  final double totalDose;
  final double volume;
  final FrequencyType frequencyType;
  final int frequencyValue;
  final List<int>? selectedDays;
  final int cycleOn;
  final int cycleOff;
  final bool repeatCycle;

  DosageSchedule({
    required this.medicationId,
    required this.method,
    required this.totalDose,
    required this.volume,
    required this.frequencyType,
    this.frequencyValue = 1,
    this.selectedDays,
    required this.cycleOn,
    required this.cycleOff,
    required this.repeatCycle,
  });

  Map<String, dynamic> toJson() => {
    'medicationId': medicationId,
    'method': method.toString(),
    'totalDose': totalDose,
    'volume': volume,
    'frequencyType': frequencyType.toString(),
    'frequencyValue': frequencyValue,
    'selectedDays': selectedDays,
    'cycleOn': cycleOn,
    'cycleOff': cycleOff,
    'repeatCycle': repeatCycle,
  };

  factory DosageSchedule.fromJson(Map<String, dynamic> json) => DosageSchedule(
    medicationId: json['medicationId'],
    method: DosageMethod.values.firstWhere((e) => e.toString() == json['method']),
    totalDose: json['totalDose'],
    volume: json['volume'],
    frequencyType: FrequencyType.values.firstWhere((e) => e.toString() == json['frequencyType']),
    frequencyValue: json['frequencyValue'],
    selectedDays: json['selectedDays'] != null ? List<int>.from(json['selectedDays']) : null,
    cycleOn: json['cycleOn'],
    cycleOff: json['cycleOff'],
    repeatCycle: json['repeatCycle'],
  );
}