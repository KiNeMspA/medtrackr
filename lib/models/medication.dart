import 'package:uuid/uuid.dart';

class Medication {
  final String id;
  final String name;
  final String type;
  final String storageType;
  final String stockUnit;
  final double stockQuantity;
  final String reconstitutionVolumeUnit;
  final double reconstitutionVolume;
  final double concentration;

  Medication({
    String? id,
    required this.name,
    this.type = 'Injectable',
    required this.storageType,
    required this.stockUnit,
    required this.stockQuantity,
    required this.reconstitutionVolumeUnit,
    required this.reconstitutionVolume,
  })  : id = id ?? const Uuid().v4(),
        concentration = reconstitutionVolume != 0 ? stockQuantity / reconstitutionVolume : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'storageType': storageType,
    'stockUnit': stockUnit,
    'stockQuantity': stockQuantity,
    'reconstitutionVolumeUnit': reconstitutionVolumeUnit,
    'reconstitutionVolume': reconstitutionVolume,
    'concentration': concentration,
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    storageType: json['storageType'],
    stockUnit: json['stockUnit'],
    stockQuantity: json['stockQuantity'],
    reconstitutionVolumeUnit: json['reconstitutionVolumeUnit'],
    reconstitutionVolume: json['reconstitutionVolume'],
  );
}