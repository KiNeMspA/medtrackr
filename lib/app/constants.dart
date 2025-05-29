// lib/app/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'MedTrackr';
  static const Color primaryColor = Color(0xFFFFA726); // Orange-yellow highlight
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121); // Dark grey
  static const Color textSecondary = Color(0xFF757575); // Medium grey
  static const Color accentColor = Color(0xFF616161); // Darker grey
  static const Color errorColor = Color(0xFFD32F2F); // Red for errors
  static const Color kLightGrey = Color(0xFFE0E0E0);

  static final cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final prominentCardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: kLightGrey, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static final infoCardDecoration = BoxDecoration(
    color: Color(0xFFE8EAF6), // Light grey-blue
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Color(0xFF9FA8DA), width: 1),
  );

  static const cardTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const cardBodyStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
  );

  static const secondaryTextStyle = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  static const infoTextStyle = TextStyle(
    fontSize: 14,
    color: textPrimary,
    fontStyle: FontStyle.italic,
  );

  static final formFieldDecoration = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: kLightGrey, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryColor, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: errorColor, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: errorColor, width: 1),
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: Colors.white,
    labelStyle: TextStyle(color: textSecondary),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  );

  static final dialogButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textPrimary,
    minimumSize: Size(100, 36),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  );

  static final cancelButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    minimumSize: Size(100, 36),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  );

  static final actionButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: textPrimary,
    minimumSize: Size(double.infinity, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
  );
}