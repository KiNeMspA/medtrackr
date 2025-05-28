// lib/app/themes.dart
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

  // Existing Decorations
  static final BoxDecoration informationCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  static final Color informationBackgroundColor = Colors.white;
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

  // CompactMedicationCard Styles
  static final BoxDecoration compactMedicationCardDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.blue.shade50, Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.shade100.withOpacity(0.3),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const TextStyle compactMedicationCardTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  static const TextStyle compactMedicationCardContentStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle compactMedicationCardActionStyle = TextStyle(
    fontSize: 12,
    color: AppConstants.primaryColor,
  );

  // ReconstitutionView Styles
  static final BoxDecoration reconstitutionCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static final BoxDecoration reconstitutionOptionCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration reconstitutionSelectedOptionCardDecoration =
      BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.blue.shade200.withOpacity(0.4),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static const TextStyle reconstitutionTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  static const TextStyle reconstitutionOptionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle reconstitutionOptionSubtitleStyle = TextStyle(
    fontSize: 14,
    color: Colors.black54,
  );

  static const TextStyle reconstitutionErrorStyle = TextStyle(
    fontSize: 14,
    color: Colors.red,
  );

  // Dialog Styles
  static final BoxDecoration dialogCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const TextStyle dialogTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle dialogContentStyle = TextStyle(
    fontSize: 16,
    color: Colors.black87,
    height: 1.5,
  );

  // Form and Action Button Styles
  static final BoxDecoration formCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static const TextStyle formLabelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.blueGrey,
  );

  static final BoxDecoration dosageCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static final BoxDecoration actionButtonDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(8),
    color: Colors.blue.shade50,
  );

  static const ScrollbarThemeData scrollbarTheme = ScrollbarThemeData(
    thumbVisibility: MaterialStateProperty.all(true),
    trackVisibility: MaterialStateProperty.all(true),
    thickness: MaterialStateProperty.all(6),
    radius: Radius.circular(8),
  );
}
