enum FluidUnit {
  mL('mL', 1.0),
  cc('CC', 1.0), // 1 CC = 1 mL
  iu('IU', 0.01), // 1 IU = 0.01 mL (adjust if needed)
  units('Units', 0.01); // Same as IU

  final String displayName;
  final double toMLFactor;

  const FluidUnit(this.displayName, this.toMLFactor);
}