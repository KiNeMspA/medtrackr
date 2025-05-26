import 'package:flutter/material.dart';

enum FrequencyType {
  hourly,
  daily,
  weekly,
  monthly,
}

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
    required this.notificationTime,
  });

  Schedule copyWith({
    String? id,
    String? medicationId,
    String? dosageId,
    String? dosageName,
    TimeOfDay? time,
    double? dosageAmount,
    String? dosageUnit,
    FrequencyType? frequencyType,
    String? notificationTime,
  }) {
    return Schedule(
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'dosageId': dosageId,
    'dosageName': dosageName,
    'time': '${time.hour}:${time.minute}',
    'dosageAmount': dosageAmount,
    'dosageUnit': dosageUnit,
    'frequencyType': frequencyType.toString(),
    'notificationTime': notificationTime?.toString(),
  };

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final timeParts = json['time'].split(':');
    return Schedule(
      id: json['id'],
      medicationId: json['medicationId'],
      dosageId: json['dosageId'],
      dosageName: json['dosageName'],
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      dosageAmount: json['dosageAmount'].toDouble(),
      dosageUnit: json['dosageUnit'],
      frequencyType: FrequencyType.values.firstWhere(
            (e) => e.toString() == json['frequencyType'],
        orElse: () => FrequencyType.daily,
      ),
      notificationTime: json['notificationTime'] != null ? int.tryParse(json['notificationTime']) : null,
    );
  }
}