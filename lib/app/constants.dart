// lib/app/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Core Colors (Modern palette for 2025)
  static const Color primaryColor = Color(0xFF00C4B4); // Teal for primary actions
  static const Color accentColorLight = Color(0xFFFF6F61); // Coral for accents
  static const Color accentColorDark = Color(0xFFFF8A65); // Slightly darker coral for dark mode
  static const Color backgroundColorLight = Color(0xFFF5F7FA); // Light grey background
  static const Color backgroundColorDark = Color(0xFF1A1C1E); // Dark background
  static const Color cardColorLight = Color(0xFFFFFFFF); // White cards
  static const Color cardColorDark = Color(0xFF2D2F31); // Dark grey cards
  static const Color textPrimaryLight = Color(0xFF1A1C1E); // Dark text
  static const Color textPrimaryDark = Color(0xFFE0E0E0); // Light text
  static const Color textSecondaryLight = Color(0xFF6B7280); // Medium grey text
  static const Color textSecondaryDark = Color(0xFFA0A0A0); // Medium grey text
  static const Color errorColor = Color(0xFFE57373); // Red for errors
  static const Color warningColor = Color(0xFFFBBF24); // Amber for warnings
  static const Color kLightGrey = Color(0xFFE5E7EB); // Very light grey for borders

  // Dynamic Theme Colors
  static Color backgroundColor(bool isDark) => isDark ? backgroundColorDark : backgroundColorLight;
  static Color cardColor(bool isDark) => isDark ? cardColorDark : cardColorLight;
  static Color textPrimary(bool isDark) => isDark ? textPrimaryDark : textPrimaryLight;
  static Color textSecondary(bool isDark) => isDark ? textSecondaryDark : textSecondaryLight;
  static Color accentColor(bool isDark) => isDark ? accentColorDark : accentColorLight;

  // Card-specific colors for Medications
  static const Color tabletCardBackground = Color(0xFFE0F7FA); // Light cyan for tablet cards
  static const Color injectionCardBackground = Color(0xFFFFF1F0); // Light red for injection cards

  // Decorations
  static BoxDecoration cardDecoration(bool isDark) => BoxDecoration(
    color: cardColor(isDark),
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration prominentCardDecoration(bool isDark) => BoxDecoration(
    color: cardColor(isDark),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: kLightGrey, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration infoCardDecoration(bool isDark) => BoxDecoration(
    color: isDark ? const Color(0xFF2E7D32) : const Color(0xFFE8F5E9),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: isDark ? const Color(0xFF4CAF50) : const Color(0xFFA5D6A7), width: 1),
  );

  // Text Styles (Using Inter font for modern look)
  static TextStyle headlineStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary(isDark),
  );

  static TextStyle cardTitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary(isDark),
  );

  static TextStyle cardBodyStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: textSecondary(isDark),
  );

  static TextStyle secondaryTextStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: textSecondary(isDark),
  );

  static TextStyle infoTextStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: textPrimary(isDark),
    fontStyle: FontStyle.italic,
  );

  static TextStyle errorTextStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: errorColor,
  );

  // Form and Input Decorations
  static InputDecoration formFieldDecoration(bool isDark) => InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: kLightGrey, width: 1),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: primaryColor, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: errorColor, width: 1),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: errorColor, width: 1.5),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: isDark ? Colors.grey[800] : Colors.white,
    labelStyle: TextStyle(color: textSecondary(isDark), fontFamily: 'Inter'),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  // Button Styles
  static ButtonStyle dialogButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(120, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
  );

  static ButtonStyle cancelButtonStyle(bool isDark) => ElevatedButton.styleFrom(
    backgroundColor: accentColor(isDark),
    foregroundColor: Colors.white,
    minimumSize: const Size(120, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
  );

  static ButtonStyle actionButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
  );

  // Home Screen Constants
  static TextStyle nextDoseTitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary(isDark),
  );

  static TextStyle nextDoseSubtitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: textSecondary(isDark),
  );

  static TextStyle medicationCardTitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary(isDark),
  );

  static TextStyle medicationCardSubtitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: textSecondary(isDark),
  );

  static ButtonStyle homeActionButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(100, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
  );

  static ButtonStyle snoozeButtonStyle(bool isDark) => ElevatedButton.styleFrom(
    backgroundColor: accentColor(isDark),
    foregroundColor: Colors.white,
    minimumSize: const Size(100, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
  );

  static ButtonStyle homeCancelButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(100, 40),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 14),
  );

  // Medication Details Constants
  static TextStyle stockTitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary(isDark),
  );

  static TextStyle stockSubtitleStyle(bool isDark) => TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    color: textSecondary(isDark),
  );

  static ButtonStyle medicationActionButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(120, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
  );

  static ButtonStyle deleteButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    minimumSize: const Size(120, 48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 16),
  );
}