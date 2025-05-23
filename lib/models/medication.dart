import 'package:uuid/uuid.dart';

class Medication {
  final String id;
  final String name;
  final String type;
  final String storageType;
  final String quantityUnit;
  final double quantity;
  final String reconstitutionVolumeUnit; // mL
  final double reconstitutionVolume;
  final double concentration; // mcg/mL
  final double remainingQuantity;

  Medication({
    String? id,
    required this.name,
    this.type = 'Injection',
    required this.storageType,
    required this.quantityUnit,
    required this.quantity,
    required this.reconstitutionVolumeUnit,
    required this.reconstitutionVolume,
    double? remainingQuantity,
  })  : id = id ?? const Uuid().v4(),
        concentration = reconstitutionVolume != 0
            ? (quantityUnit == 'mg' ? quantity * 1000 : quantity) / reconstitutionVolume
            : 0,
        remainingQuantity = remainingQuantity ?? quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'storageType': storageType,
    'quantityUnit': quantityUnit,
    'quantity': quantity,
    'reconstitutionVolumeUnit': reconstitutionVolumeUnit,
    'reconstitutionVolume': reconstitutionVolume,
    'concentration': concentration,
    'remainingQuantity': remainingQuantity,
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    storageType: json['storageType'],
    quantityUnit: json['quantityUnit'],
    quantity: json['quantity'],
    reconstitutionVolumeUnit: json['reconstitutionVolumeUnit'],
    reconstitutionVolume: json['reconstitutionVolume'],
    remainingQuantity: json['remainingQuantity'],
  );

  Medication copyWith({double? remainingQuantity}) => Medication(
    id: id,
    name: name,
    type: type,
    storageType: storageType,
    quantityUnit: quantityUnit,
    quantity: quantity,
    reconstitutionVolumeUnit: reconstitutionVolumeUnit,
    reconstitutionVolume: reconstitutionVolume,
    remainingQuantity: remainingQuantity ?? this.remainingQuantity,
  );
}