enum TargetDoseUnit {
  mg,
  mcg;

  String get displayName {
    switch (this) {
      case TargetDoseUnit.mg:
        return 'mg';
      case TargetDoseUnit.mcg:
        return 'mcg';
    }
  }
}