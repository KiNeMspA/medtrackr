// lib/models/schedule.dart
import 'package:flutter/foundation.dart';

enum FrequencyType { daily, weekly }

class Schedule {
  final String id;
  final String medicationId;
  final String dosageId;
  final FrequencyType frequencyType;
  final String notificationTime;
  final List<String> selectedDays;

  Schedule({
    required this.id,
    required this.medicationId,
    required this.dosageId,
    required this.frequencyType,
    required this.notificationTime,
    this.selectedDays = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'dosageId': dosageId,
    'frequencyType': frequencyType.toString().split('.').last,
    'notificationTime': notificationTime,
    'selectedDays': selectedDays,
  };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'],
    medicationId: json['medicationId'],
    dosageId: json['dosageId'] ?? '',
    frequencyType: FrequencyType.values.firstWhere(
          (e) => e.toString().split('.').last == json['frequencyType'],
      orElse: () => FrequencyType.daily,
    ),
    notificationTime: json['notificationTime'],
    selectedDays: List<String>.from(json['selectedDays'] ?? []),
  );

  Schedule copyWith({
    String? id,
    String? medicationId,
    String? dosageId,
    FrequencyType? frequencyType,
    String? notificationTime,
    List<String>? selectedDays,
  }) =>
      Schedule(
        id: id ?? this.id,
        medicationId: medicationId ?? this.medicationId,
        dosageId: dosageId ?? this.dosageId,
        frequencyType: frequencyType ?? this.frequencyType,
        notificationTime: notificationTime ?? this.notificationTime,
        selectedDays: selectedDays ?? this.selectedDays,
      );
}