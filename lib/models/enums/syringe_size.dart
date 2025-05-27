enum SyringeSize {
  size0_3(0.3, '0.3 mL Syringe'),
  size0_5(0.5, '0.5 mL Syringe'),
  size1_0(1.0, '1.0 mL Syringe'),
  size3_0(3.0, '3.0 mL Syringe'),
  size5_0(5.0, '5.0 mL Syringe');

  final double value;
  final String displayName;

  const SyringeSize(this.value, this.displayName);
}