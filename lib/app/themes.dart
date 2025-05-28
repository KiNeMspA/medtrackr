import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class AppThemes {
  static final ThemeData themeData = ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppConstants.primaryColor,
      selectionColor: AppConstants.primaryColor.withOpacity(0.5),
      selectionHandleColor: AppConstants.primaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppConstants.kLightGrey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppConstants.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppConstants.kLightGrey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppConstants.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.grey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppConstants.actionButtonStyle,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppConstants.primaryColor, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.red[600],
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Information Card Styling (e.g., confirmation messages, info dialogs)
  static final BoxDecoration informationCardDecoration = BoxDecoration(
    color: Colors.blue[50],
    border: Border.all(color: Colors.blue[200]!, width: 1),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
  static final Color informationBackgroundColor = Colors.blue[50]!;
  static const TextStyle informationTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle informationContentTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  );

  // Warning Card Styling (e.g., alerts, caution messages)
  static final BoxDecoration warningCardDecoration = BoxDecoration(
    color: Colors.orange[50],
    border: Border.all(color: Colors.orange[200]!, width: 1),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
  static final Color warningBackgroundColor = Colors.orange[50]!;
  static const TextStyle warningTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle warningContentTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  );

  // Error Card Styling (e.g., error notifications, failure dialogs)
  static final BoxDecoration errorCardDecoration = BoxDecoration(
    color: Colors.red[50],
    border: Border.all(color: Colors.red[200]!, width: 1),
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  );
  static final Color errorBackgroundColor = Colors.red[50]!;
  static const TextStyle errorTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static const TextStyle errorContentTextStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  );
}