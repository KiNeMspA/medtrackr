// lib/models/schedule.dart
enum FrequencyType { daily, selectedDays }

class Schedule {
  final String id;
  final String medicationId; // Links to Medication
  final FrequencyType frequencyType;
  final List<int>? selectedDays; // e.g., [1, 3, 5] for Mon, Wed, Fri
  final String notificationTime; // e.g., "22:00"

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

  Schedule copyWith({String? notificationTime}) => Schedule(
    id: id,
    medicationId: medicationId,
    frequencyType: frequencyType,
    selectedDays: selectedDays,
    notificationTime: notificationTime ?? this.notificationTime,
  );
}