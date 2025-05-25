// lib/models/medication.dart
import 'package:flutter/foundation.dart';

class Medication {
  final String id;
  final String name;
  final String type;
  final String storageType;
  final String quantityUnit;
  final double quantity;
  final double remainingQuantity;
  final String reconstitutionVolumeUnit;
  final double reconstitutionVolume;

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.storageType,
    required this.quantityUnit,
    required this.quantity,
    required this.remainingQuantity,
    required this.reconstitutionVolumeUnit,
    required this.reconstitutionVolume,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'storageType': storageType,
    'quantityUnit': quantityUnit,
    'quantity': quantity,
    'remainingQuantity': remainingQuantity,
    'reconstitutionVolumeUnit': reconstitutionVolumeUnit,
    'reconstitutionVolume': reconstitutionVolume,
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    storageType: json['storageType'],
    quantityUnit: json['quantityUnit'],
    quantity: json['quantity'],
    remainingQuantity: json['remainingQuantity'] ?? json['quantity'],
    reconstitutionVolumeUnit: json['reconstitutionVolumeUnit'],
    reconstitutionVolume: json['reconstitutionVolume'],
  );

  Medication copyWith({
    String? id,
    String? name,
    String? type,
    String? storageType,
    String? quantityUnit,
    double? quantity,
    double? remainingQuantity,
    String? reconstitutionVolumeUnit,
    double? reconstitutionVolume,
  }) =>
      Medication(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        storageType: storageType ?? this.storageType,
        quantityUnit: quantityUnit ?? this.quantityUnit,
        quantity: quantity ?? this.quantity,
        remainingQuantity: remainingQuantity ?? this.remainingQuantity,
        reconstitutionVolumeUnit: reconstitutionVolumeUnit ?? this.reconstitutionVolumeUnit,
        reconstitutionVolume: reconstitutionVolume ?? this.reconstitutionVolume,
      );
}