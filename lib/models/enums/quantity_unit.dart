enum QuantityUnit {
  g('g'),
  mg('mg'),
  mcg('mcg'),
  mL('mL'),
  iu('IU'),
  unit('Unit');

  final String displayName;

  const QuantityUnit(this.displayName);
}