import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';

// In lib/constants/themes.dart, add to Themes class
class Themes {
  static final informationCardDecoration = BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppConstants.primaryColor, width: 1),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  static const warningBackgroundColor = Colors.white;
  static const informationBackgroundColor = Colors.white;

  static const warningTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const informationTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const warningContentTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const informationContentTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
}