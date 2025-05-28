// lib/features/schedule/models/schedule.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';

class Schedule {
  final String id;
  final String medicationId;
  final String dosageId;
  final String dosageName;
  final TimeOfDay time;
  final double dosageAmount;
  final String dosageUnit;
  final FrequencyType frequencyType;
  final int? notificationTime;

  Schedule({
    required this.id,
    required this.medicationId,
    required this.dosageId,
    required this.dosageName,
    required this.time,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.frequencyType,
    this.notificationTime,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'dosageId': dosageId,
    'dosageName': dosageName,
    'time': {'hour': time.hour, 'minute': time.minute},
    'dosageAmount': dosageAmount,
    'dosageUnit': dosageUnit,
    'frequencyType': frequencyType.displayName,
    'notificationTime': notificationTime,
  };

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    id: json['id'],
    medicationId: json['medicationId'],
    dosageId: json['dosageId'],
    dosageName: json['dosageName'],
    time: TimeOfDay(hour: json['time']['hour'], minute: json['time']['minute']),
    dosageAmount: json['dosageAmount'].toDouble(),
    dosageUnit: json['dosageUnit'],
    frequencyType: FrequencyType.values.firstWhere(
            (e) => e.displayName == json['frequencyType'],
        orElse: () => FrequencyType.daily),
    notificationTime: json['notificationTime'],
  );

  Schedule copyWith({
    String? id,
    String? medicationId,
    String? dosageId,
    String? dosageName,
    TimeOfDay? time,
    double? dosageAmount,
    String? dosageUnit,
    FrequencyType? frequencyType,
    int? notificationTime,
  }) =>
      Schedule(
        id: id ?? this.id,
        medicationId: medicationId ?? this.medicationId,
        dosageId: dosageId ?? this.dosageId,
        dosageName: dosageName ?? this.dosageName,
        time: time ?? this.time,
        dosageAmount: dosageAmount ?? this.dosageAmount,
        dosageUnit: dosageUnit ?? this.dosageUnit,
        frequencyType: frequencyType ?? this.frequencyType,
        notificationTime: notificationTime ?? this.notificationTime,
      );
}