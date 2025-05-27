enum QuantityUnit {
  g('g'),
  mg('mg'),
  mcg('mcg'),
  mL('mL'),
  iu('IU'),
  unit('Unit'),
  tablets('Tablets'); // Added for tablet/capsule counts

  final String displayName;

  const QuantityUnit(this.displayName);
}