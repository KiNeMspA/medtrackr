enum FluidUnit {
  mL('mL', 1.0),
  cc('CC', 1.0),
  iu('IU', 0.01),
  units('Units', 0.01);

  final String displayName;
  final double toMLFactor;

  const FluidUnit(this.displayName, this.toMLFactor);
}