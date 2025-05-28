// In lib/app/enums.dart

enum MedicationType {
  tablet,
  capsule,
  injection,
  other;

  String get displayName {
    switch (this) {
      case MedicationType.tablet:
        return 'Tablet';
      case MedicationType.capsule:
        return 'Capsule';
      case MedicationType.injection:
        return 'Injection';
      case MedicationType.other:
        return 'Other';
    }
  }
}

enum QuantityUnit {
  g,
  mg,
  mcg,
  mL,
  iu,
  unit,
  tablets;

  String get displayName {
    switch (this) {
      case QuantityUnit.g:
        return 'g';
      case QuantityUnit.mg:
        return 'mg';
      case QuantityUnit.mcg:
        return 'mcg';
      case QuantityUnit.mL:
        return 'mL';
      case QuantityUnit.iu:
        return 'IU';
      case QuantityUnit.unit:
        return 'Unit';
      case QuantityUnit.tablets:
        return 'Tablets';
    }
  }
}

enum DosageMethod {
  oral,
  subcutaneous;

  String get displayName {
    switch (this) {
      case DosageMethod.oral:
        return 'Oral';
      case DosageMethod.subcutaneous:
        return 'Subcutaneous';
    }
  }
}

enum SyringeSize {
  size0_3(value: 0.3),
  size0_5(value: 0.5),
  size1_0(value: 1.0),
  size3_0(value: 3.0),
  size5_0(value: 5.0);

  final double value;

  const SyringeSize({required this.value});
}

enum FrequencyType {
  hourly,
  daily,
  weekly,
  monthly;

  String get displayName {
    switch (this) {
      case FrequencyType.hourly:
        return 'Hourly';
      case FrequencyType.daily:
        return 'Daily';
      case FrequencyType.weekly:
        return 'Weekly';
      case FrequencyType.monthly:
        return 'Monthly';
    }
  }
}

enum FluidUnit {
  mL,
  L;

  String get displayName {
    switch (this) {
      case FluidUnit.mL:
        return 'mL';
      case FluidUnit.L:
        return 'L';
    }
  }
}

enum TargetDoseUnit {
  g,
  mg,
  mcg;

  String get displayName {
    switch (this) {
      case TargetDoseUnit.g:
        return 'g';
      case TargetDoseUnit.mg:
        return 'mg';
      case TargetDoseUnit.mcg:
        return 'mcg';
    }
  }
}