enum DosageMethod {
  oral,
  subcutaneous,
  intramuscular,
  intravenous,
  unspecified;

  String get displayName {
    switch (this) {
      case DosageMethod.oral:
        return 'Oral';
      case DosageMethod.subcutaneous:
        return 'Subcutaneous';
      case DosageMethod.intramuscular:
        return 'Intramuscular';
      case DosageMethod.intravenous:
        return 'Intravenous';
      case DosageMethod.unspecified:
        return 'Unspecified';
    }
  }
}