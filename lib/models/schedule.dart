// lib/models/schedule.dart
enum FrequencyType { daily, selectedDays }

class Schedule {
  final String id;
  final String medicationId;
  final FrequencyType frequencyType;
  final List<int>? selectedDays;
  final String notificationTime;

  Schedule({
    required this.id,
    required this.medicationId,
    required this.frequencyType,
    this.selectedDays,
    required this.notificationTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'frequencyType': frequencyType.toString(),
    'selectedDays': selectedDays,
    'notificationTime': notificationTime,
  };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'],
    medicationId: json['medicationId'],
    frequencyType: FrequencyType.values.firstWhere((e) => e.toString() == json['frequencyType']),
    selectedDays: json['selectedDays'] != null ? List<int>.from(json['selectedDays']) : null,
    notificationTime: json['notificationTime'],
  );

  Schedule copyWith({
    String? medicationId,
    String? notificationTime,
    FrequencyType? frequencyType,
    List<int>? selectedDays,
  }) =>
      Schedule(
        id: id,
        medicationId: medicationId ?? this.medicationId,
        frequencyType: frequencyType ?? this.frequencyType,
        selectedDays: selectedDays ?? this.selectedDays,
        notificationTime: notificationTime ?? this.notificationTime,
      );
}