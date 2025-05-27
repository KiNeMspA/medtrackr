import 'package:medtrackr/models/enums/enums.dart';

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
  final double? dosePerTablet; // New field

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
    this.dosePerTablet,
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
    double? dosePerTablet,
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
      dosePerTablet: dosePerTablet ?? this.dosePerTablet,
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
      'dosePerTablet': dosePerTablet,
    };
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: _parseMedicationType(json['type'] as String?),
      quantityUnit: _parseQuantityUnit(json['quantityUnit'] as String?),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      remainingQuantity: (json['remainingQuantity'] as num?)?.toDouble() ?? 0.0,
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
      dosePerTablet: (json['dosePerTablet'] as num?)?.toDouble(),
    );
  }

  static MedicationType _parseMedicationType(String? type) {
    if (type == null || type.isEmpty) return MedicationType.other;
    return MedicationType.values.firstWhere(
          (e) => e.displayName.toLowerCase() == type.toLowerCase(),
      orElse: () => MedicationType.other,
    );
  }

  static QuantityUnit _parseQuantityUnit(String? unit) {
    if (unit == null || unit.isEmpty) return QuantityUnit.mg;
    return QuantityUnit.values.firstWhere(
          (e) => e.displayName.toLowerCase() == unit.toLowerCase(),
      orElse: () => QuantityUnit.mg,
    );
  }
}