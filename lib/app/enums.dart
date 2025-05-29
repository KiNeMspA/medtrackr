// lib/app/enums.dart
enum MedicationType {
  tablet('Tablet'),
  capsule('Capsule'),
  injection('Injection'),
  other('Other');

  final String displayName;

  const MedicationType(this.displayName);
}

enum DosageMethod {
  oral('Oral'),
  subcutaneous('Subcutaneous'),
  intramuscular('Intramuscular'),
  intravenous('Intravenous'),
  intradermal('Intradermal'),
  other('Other');

  final String displayName;

  const DosageMethod(this.displayName);

  bool get isInjection => this != oral && this != other;
}

enum QuantityUnit {
  mg('mg'),
  g('g'),
  mcg('mcg'),
  mL('mL'),
  tablets('tablets'),
  unit('unit'),
  iu('IU');

  final String displayName;

  const QuantityUnit(this.displayName);
}

enum TargetDoseUnit {
  mcg('mcg'),
  mg('mg'),
  g('g');

  final String displayName;

  const TargetDoseUnit(this.displayName);
}

enum FluidUnit {
  mL('mL', 1.0),
  L('L', 1000.0);

  final String displayName;
  final double toMLFactor;

  const FluidUnit(this.displayName, this.toMLFactor);
}

enum SyringeSize {
  size0_3('0.3 mL'),
  size0_5('0.5 mL'),
  size1_0('1.0 mL'),
  size3_0('3.0 mL');

  final String displayName;

  const SyringeSize(this.displayName);

  double get value => double.parse(displayName.split(' ').first);

  double get maxVolume {
    switch (this) {
      case SyringeSize.size0_3:
        return 0.3;
      case SyringeSize.size0_5:
        return 0.5;
      case SyringeSize.size1_0:
        return 1.0;
      case SyringeSize.size3_0:
        return 3.0;
    }
  }

  double get maxIU {
    switch (this) {
      case SyringeSize.size0_3:
        return 30.0;
      case SyringeSize.size0_5:
        return 50.0;
      case SyringeSize.size1_0:
        return 100.0;
      case SyringeSize.size3_0:
        return 300.0;
    }
  }
}

enum FrequencyType {
  once('Once'),
  hourly('Hourly'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  final String displayName;

  const FrequencyType(this.displayName);

  Duration get duration {
    switch (this) {
      case FrequencyType.once:
        return const Duration(minutes: 1);
      case FrequencyType.hourly:
        return const Duration(hours: 1);
      case FrequencyType.daily:
        return const Duration(days: 1);
      case FrequencyType.weekly:
        return const Duration(days: 7);
      case FrequencyType.monthly:
        return const Duration(days: 30);
    }
  }
}