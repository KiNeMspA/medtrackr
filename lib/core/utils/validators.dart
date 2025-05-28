// lib/core/utils/validators.dart
class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (double.tryParse(value) == null || double.parse(value) <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }
}