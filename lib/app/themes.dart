// lib/app/themes.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: AppConstants.backgroundColorLight,
    cardTheme: CardThemeData(
      color: AppConstants.cardColorLight,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppConstants.kLightGrey, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.kLightGrey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: AppConstants.textSecondaryLight, fontFamily: 'Inter'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppConstants.actionButtonStyle(),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppConstants.cardColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: AppConstants.cardTitleStyle(false),
      contentTextStyle: AppConstants.cardBodyStyle(false),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppConstants.errorColor,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.textSecondaryLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: AppConstants.backgroundColorDark,
    cardTheme: CardThemeData(
      color: AppConstants.cardColorDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppConstants.kLightGrey, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.kLightGrey, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.primaryColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppConstants.errorColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[800],
      labelStyle: const TextStyle(color: AppConstants.textSecondaryDark, fontFamily: 'Inter'),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppConstants.actionButtonStyle(),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppConstants.cardColorDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: AppConstants.cardTitleStyle(true),
      contentTextStyle: AppConstants.cardBodyStyle(true),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppConstants.errorColor,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      behavior: SnackBarBehavior.floating,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppConstants.cardColorDark,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.textSecondaryDark,
    ),
  );

  // Restored styles previously removed
  static BoxDecoration stockCardDecoration(bool isDark) => BoxDecoration(
    color: AppConstants.cardColor(isDark),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static TextStyle reconstitutionErrorStyle(bool isDark) => AppConstants.errorTextStyle(isDark);

  static BoxDecoration dialogCardDecoration(bool isDark) => BoxDecoration(
    color: AppConstants.cardColor(isDark),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static TextStyle dialogTitleStyle(bool isDark) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppConstants.textPrimary(isDark),
    fontFamily: 'Inter',
  );

  static TextStyle dialogContentStyle(bool isDark) => TextStyle(
    fontSize: 16,
    color: AppConstants.textSecondary(isDark),
    height: 1.5,
    fontFamily: 'Inter',
  );

  static TextStyle reconstitutionTitleStyle(bool isDark) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppConstants.textPrimary(isDark),
    fontFamily: 'Inter',
  );

  static TextStyle formLabelStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppConstants.textSecondary(isDark),
  );

  static BoxDecoration compactMedicationCardDecoration(bool isDark) => BoxDecoration(
    color: AppConstants.cardColor(isDark),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static TextStyle compactMedicationCardContentStyle(bool isDark) => TextStyle(
    fontSize: 12,
    color: AppConstants.textSecondary(isDark),
    fontFamily: 'Inter',
  );

  static TextStyle reconstitutionOptionTitleStyle(bool isDark) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppConstants.textPrimary(isDark),
    fontFamily: 'Inter',
  );

  static TextStyle reconstitutionOptionSubtitleStyle(bool isDark) => TextStyle(
    fontSize: 12,
    color: AppConstants.textSecondary(isDark),
    fontFamily: 'Inter',
  );

  static BoxDecoration reconstitutionSelectedOptionCardDecoration(bool isDark) => BoxDecoration(
    color: AppConstants.accentColor(isDark).withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: AppConstants.accentColor(isDark).withOpacity(isDark ? 0.3 : 0.15),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration reconstitutionOptionCardDecoration(bool isDark) => BoxDecoration(
    color: AppConstants.cardColor(isDark),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration reconstitutionCardDecoration(bool isDark) => BoxDecoration(
    color: AppConstants.cardColor(isDark),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration bannerDecoration(bool isDark) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppConstants.primaryColor,
        AppConstants.accentColor(isDark),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
}