import 'package:medtrackr/models/enums/medication_type.dart';
import 'package:medtrackr/models/enums/quantity_unit.dart';

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
  final List<Map<String, dynamic>> reconstitutionOptions;
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
    this.reconstitutionOptions = const [],
    this.selectedReconstitution,
  });

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
    List<Map<String, dynamic>>? reconstitutionOptions,
    Map<String, dynamic>? selectedReconstitution,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      quantity: quantity ?? this.quantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      reconstitutionVolumeUnit: reconstitutionVolumeUnit ?? this.reconstitutionVolumeUnit,
      reconstitutionVolume: reconstitutionVolume ?? this.reconstitutionVolume,
      reconstitutionFluid: reconstitutionFluid ?? this.reconstitutionFluid,
      notes: notes ?? this.notes,
      reconstitutionOptions: reconstitutionOptions ?? this.reconstitutionOptions,
      selectedReconstitution: selectedReconstitution ?? this.selectedReconstitution,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
      'reconstitutionOptions': reconstitutionOptions,
      'selectedReconstitution': selectedReconstitution,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      type: MedicationType.values.firstWhere(
            (e) => e.displayName == json['type'],
        orElse: () => MedicationType.other,
      ),
      quantityUnit: QuantityUnit.values.firstWhere(
            (e) => e.displayName == json['quantityUnit'],
        orElse: () => QuantityUnit.mg,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      remainingQuantity: (json['remainingQuantity'] as num).toDouble(),
      reconstitutionVolumeUnit: json['reconstitutionVolumeUnit'] as String? ?? '',
      reconstitutionVolume: (json['reconstitutionVolume'] as num?)?.toDouble() ?? 0.0,
      reconstitutionFluid: json['reconstitutionFluid'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      reconstitutionOptions: (json['reconstitutionOptions'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ??
          [],
      selectedReconstitution: json['selectedReconstitution'] != null
          ? Map<String, dynamic>.from(json['selectedReconstitution'])
          : null,
    );
  }
}