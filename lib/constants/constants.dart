import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'MedTrackr';
  static const Color primaryColor = Color(0xFFFFC107); // Amber
  static const Color kLightGrey = Color(0xFFCCCCCC);
  static const Color secondaryColor = Colors.blue; // For info message
  static const Color cancelColor = Colors.grey; // For cancel button

  static final cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static final prominentCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey[300]!, width: 1), // Thinner border
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );

  static final infoCardDecoration = BoxDecoration(
    color: Colors.blue[50],
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.blue[200]!, width: 1),
  );

  static const cardTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const cardBodyStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  static const secondaryTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  static final infoTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.blue[800],
    fontStyle: FontStyle.italic,
  );

  static final formFieldDecoration = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kLightGrey, width: 1),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor, width: 1),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kLightGrey, width: 1),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor, width: 1),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: Colors.grey),
  );

  static final dialogButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    minimumSize: Size(120, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: TextStyle(fontWeight: FontWeight.bold),
  );

  static final cancelButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: cancelColor,
    foregroundColor: Colors.white,
    minimumSize: Size(120, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: TextStyle(fontWeight: FontWeight.bold),
  );

  static final actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.black,
    minimumSize: Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: TextStyle(fontWeight: FontWeight.bold),
  );
}