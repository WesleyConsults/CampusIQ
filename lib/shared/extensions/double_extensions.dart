extension DoubleFormatting on double {
  /// e.g. 68.3
  String toCwaString() => toStringAsFixed(1);

  /// e.g. "68.3%"
  String toPercentString() => '${toStringAsFixed(1)}%';
}
