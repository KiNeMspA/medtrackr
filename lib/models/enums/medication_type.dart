enum MedicationType {
  injection('Injection'),
  tablet('Tablet'),
  capsule('Capsule'),
  other('Other');

  final String displayName;

  const MedicationType(this.displayName);
}