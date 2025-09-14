class Amount {
  static const double maxAbs = 999999.99;
  final double value;

  Amount._(this.value);

  /// Generic factory - accepts positive or negative amounts but validates range and non-zero
  factory Amount(double value) {
    if (value == 0) throw ArgumentError('Amount cannot be zero');
    if (value.abs() > maxAbs)
      throw ArgumentError('Amount exceeds maximum allowed');
    return Amount._(double.parse(value.toStringAsFixed(2)));
  }

  /// Expense must be negative
  factory Amount.expense(double value) {
    if (value >= 0) throw ArgumentError('Expense amount must be negative');
    return Amount(value);
  }

  /// Income must be positive
  factory Amount.income(double value) {
    if (value <= 0) throw ArgumentError('Income amount must be positive');
    return Amount(value);
  }

  @override
  String toString() => value.toStringAsFixed(2);
}
