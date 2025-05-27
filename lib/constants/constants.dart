import 'package:flutter/material.dart';

class AppConstants {
  static const primaryColor = Color(0xFFFFC107); // National Geographic yellow
  static const kLightGrey = Color(0xFFB0BEC5); // Soft grey for borders
  static const defaultDosageUnit = 'IU';
  static const appName = 'MedTrackr';
  static const cardDecoration = BoxDecoration(
    color: Color(0xFFF5F5F5), // Off-white background
    border: Border.fromBorderSide(BorderSide(color: primaryColor, width: 2)),
    borderRadius: BorderRadius.all(Radius.circular(16)), // Softer corners
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );
  static const cardTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontFamily: 'Roboto', // Clean, modern font
  );
  static const cardBodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
    fontFamily: 'Roboto',
    height: 1.5,
  );
}