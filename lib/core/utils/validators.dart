// lib/core/utils/validators.dart
class Validators {
  static String? required(String? value, [String fieldName = 'Field']) {
    return value == null || value.isEmpty ? '$fieldName is required' : null;
  }

  static String? positiveNumber(String? value, [String fieldName = 'Value']) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Enter a valid positive $fieldName';
    }
    return null;
  }

  static String? rangeNumber(String? value, double min, double max, [String fieldName = 'Value']) {
    final error = positiveNumber(value, fieldName);
    if (error != null) return error;
    final number = double.parse(value!);
    if (number < min || number > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }
}