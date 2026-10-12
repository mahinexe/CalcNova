String formatNumber(double value) {
  if (!value.isFinite) return 'Undefined';
  if (value.abs() >= 1e12 || (value != 0 && value.abs() < 1e-9)) {
    return value.toStringAsExponential(6).replaceAll(RegExp(r'0+e'), 'e');
  }
  final rounded = double.parse(value.toStringAsFixed(10));
  return rounded.toString().replaceFirst(RegExp(r'\.0$'), '');
}
