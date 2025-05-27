import 'package:flutter/material.dart';

class AppConstants {
  static const primaryColor = Color(0xFFFFC107); // National Geographic yellow
  static const kLightGrey = Color(0xFFB0BEC5); // Soft grey for borders
  static const defaultDosageUnit = 'IU';
  static const appName = 'MedTrackr';
  static const cardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: primaryColor, width: 2),
    borderRadius: BorderRadius.circular(12),
  );
}