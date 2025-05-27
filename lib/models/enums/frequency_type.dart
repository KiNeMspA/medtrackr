enum FrequencyType {
  daily,
  weekly,
  monthly,
  asNeeded;

  String get displayName {
    switch (this) {
      case FrequencyType.daily:
        return 'Daily';
      case FrequencyType.weekly:
        return 'Weekly';
      case FrequencyType.monthly:
        return 'Monthly';
      case FrequencyType.asNeeded:
        return 'As Needed';
    }
  }
}