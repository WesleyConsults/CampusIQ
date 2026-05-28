extension DoubleFormatting on double {
  /// e.g. 68.32
  String toCwaString() => toStringAsFixed(2);

  /// e.g. "68.3%"
  String toPercentString() => '${toStringAsFixed(1)}%';
}
