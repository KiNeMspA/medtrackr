// lib/core/utils/format_helper.dart
String formatNumber(double value) {
  if (value == value.truncateToDouble()) {
    return value.toInt().toString();
  } else {
    String formatted = value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
    return formatted.endsWith('.') ? formatted.substring(0, formatted.length - 1) : formatted;
  }
}

String formatDateTime(DateTime dateTime) {
  return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
}