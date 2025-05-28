// In lib/features/medication/models/medication.dart

import 'package:medtrackr/app/enums.dart';

class Medication {
  final String id;
  final String name;
  final MedicationType type;
  final QuantityUnit quantityUnit;
  final double quantity;
  final double remainingQuantity;
  final String reconstitutionVolumeUnit;
  final double reconstitutionVolume;
  final String reconstitutionFluid;
  final String notes;
  final double? dosePerTablet;
  final double? dosePerCapsule;
  final QuantityUnit? dosePerTabletUnit;
  final QuantityUnit? dosePerCapsuleUnit;
  final Map<String, dynamic>? selectedReconstitution;

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.quantityUnit,
    required this.quantity,
    required this.remainingQuantity,
    required this.reconstitutionVolumeUnit,
    required this.reconstitutionVolume,
    required this.reconstitutionFluid,
    required this.notes,
    this.dosePerTablet,
    this.dosePerCapsule,
    this.dosePerTabletUnit,
    this.dosePerCapsuleUnit,
    this.selectedReconstitution,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.displayName,
    'quantityUnit': quantityUnit.displayName,
    'quantity': quantity,
    'remainingQuantity': remainingQuantity,
    'reconstitutionVolumeUnit': reconstitutionVolumeUnit,
    'reconstitutionVolume': reconstitutionVolume,
    'reconstitutionFluid': reconstitutionFluid,
    'notes': notes,
    'dosePerTablet': dosePerTablet,
    'dosePerCapsule': dosePerCapsule,
    'dosePerTabletUnit': dosePerTabletUnit?.displayName,
    'dosePerCapsuleUnit': dosePerCapsuleUnit?.displayName,
    'selectedReconstitution': selectedReconstitution,
  };

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
    id: json['id'],
    name: json['name'],
    type: MedicationType.values.firstWhere(
            (e) => e.displayName == json['type'],
        orElse: () => MedicationType.other),
    quantityUnit: QuantityUnit.values.firstWhere(
            (e) => e.displayName == json['quantityUnit'],
        orElse: () => QuantityUnit.mg),
    quantity: json['quantity'].toDouble(),
    remainingQuantity: json['remainingQuantity'].toDouble(),
    reconstitutionVolumeUnit: json['reconstitutionVolumeUnit'],
    reconstitutionVolume: json['reconstitutionVolume'].toDouble(),
    reconstitutionFluid: json['reconstitutionFluid'],
    notes: json['notes'],
    dosePerTablet: json['dosePerTablet']?.toDouble(),
    dosePerCapsule: json['dosePerCapsule']?.toDouble(),
    dosePerTabletUnit: json['dosePerTabletUnit'] != null
        ? QuantityUnit.values.firstWhere(
            (e) => e.displayName == json['dosePerTabletUnit'],
        orElse: () => QuantityUnit.mg)
        : null,
    dosePerCapsuleUnit: json['dosePerCapsuleUnit'] != null
        ? QuantityUnit.values.firstWhere(
            (e) => e.displayName == json['dosePerCapsuleUnit'],
        orElse: () => QuantityUnit.mg)
        : null,
    selectedReconstitution: json['selectedReconstitution'],
  );

  Medication copyWith({
    String? id,
    String? name,
    MedicationType? type,
    QuantityUnit? quantityUnit,
    double? quantity,
    double? remainingQuantity,
    String? reconstitutionVolumeUnit,
    double? reconstitutionVolume,
    String? reconstitutionFluid,
    String? notes,
    double? dosePerTablet,
    double? dosePerCapsule,
    QuantityUnit? dosePerTabletUnit,
    QuantityUnit? dosePerCapsuleUnit,
    Map<String, dynamic>? selectedReconstitution,
  }) =>
      Medication(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        quantityUnit: quantityUnit ?? this.quantityUnit,
        quantity: quantity ?? this.quantity,
        remainingQuantity: remainingQuantity ?? this.remainingQuantity,
        reconstitutionVolumeUnit:
        reconstitutionVolumeUnit ?? this.reconstitutionVolumeUnit,
        reconstitutionVolume: reconstitutionVolume ?? this.reconstitutionVolume,
        reconstitutionFluid: reconstitutionFluid ?? this.reconstitutionFluid,
        notes: notes ?? this.notes,
        dosePerTablet: dosePerTablet ?? this.dosePerTablet,
        dosePerCapsule: dosePerCapsule ?? this.dosePerCapsule,
        dosePerTabletUnit: dosePerTabletUnit ?? this.dosePerTabletUnit,
        dosePerCapsuleUnit: dosePerCapsuleUnit ?? this.dosePerCapsuleUnit,
        selectedReconstitution:
        selectedReconstitution ?? this.selectedReconstitution,
      );
}