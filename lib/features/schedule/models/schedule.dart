// lib/features/schedule/models/schedule.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';

class Schedule {
  final String id;
  final String medicationId;
  final String dosageId;
  final String dosageName;
  final double dosageAmount;
  final String dosageUnit;
  final TimeOfDay time;
  final FrequencyType frequencyType;
  final DateTime nextDoseTime;
  final int? notificationTime;

  Schedule({
    required this.id,
    required this.medicationId,
    required this.dosageId,
    required this.dosageName,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.time,
    required this.frequencyType,
    required this.nextDoseTime,
    this.notificationTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'dosageId': dosageId,
    'dosageName': dosageName,
    'dosageAmount': dosageAmount,
    'dosageUnit': dosageUnit,
    'time': {'hour': time.hour, 'minute': time.minute},
    'frequencyType': frequencyType.displayName,
    'nextDoseTime': nextDoseTime.toIso8601String(),
    'notificationTime': notificationTime,
  };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'],
    medicationId: json['medicationId'],
    dosageId: json['dosageId'],
    dosageName: json['dosageName'],
    dosageAmount: json['dosageAmount'].toDouble(),
    dosageUnit: json['dosageUnit'],
    time: TimeOfDay(hour: json['time']['hour'], minute: json['time']['minute']),
    frequencyType: FrequencyType.values.firstWhere(
          (e) => e.displayName == json['frequencyType'],
      orElse: () => FrequencyType.daily,
    ),
    nextDoseTime: DateTime.parse(json['nextDoseTime']),
    notificationTime: json['notificationTime'],
  );

  Schedule copyWith({
    String? id,
    String? medicationId,
    String? dosageId,
    String? dosageName,
    double? dosageAmount,
    String? dosageUnit,
    TimeOfDay? time,
    FrequencyType? frequencyType,
    DateTime? nextDoseTime,
    int? notificationTime,
  }) => Schedule(
    id: id ?? this.id,
    medicationId: medicationId ?? this.medicationId,
    dosageId: dosageId ?? this.dosageId,
    dosageName: dosageName ?? this.dosageName,
    dosageAmount: dosageAmount ?? this.dosageAmount,
    dosageUnit: dosageUnit ?? this.dosageUnit,
    time: time ?? this.time,
    frequencyType: frequencyType ?? this.frequencyType,
    nextDoseTime: nextDoseTime ?? this.nextDoseTime,
    notificationTime: notificationTime ?? this.notificationTime,
  );
}