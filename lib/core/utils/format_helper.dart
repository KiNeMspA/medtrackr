// In lib/core/utils/format_helper.dart

String formatNumber(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString(); // No decimals for whole numbers
  } else {
    String formatted = value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
    return formatted.endsWith('.') ? formatted.substring(0, formatted.length - 1) : formatted;
  }
}