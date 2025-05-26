# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Features Implemented
- **Medication Management** (May 26, 2025)
  - Add, edit, delete medications with types: Tablet, Capsule, Injection, Other.
  - Quantity units (g, mg, mcg, mL, IU, Unit) based on medication type.
  - Reconstitution for Injection/Other with fluid and IU calculations.
  - Navigation to `MedicationDetailsScreen` after adding medication/dosage.
  - Type-specific icons in `MedicationDetailsScreen`.
- **Dosage Management**
  - Add, edit, delete dosages with default names (e.g., "Dose of X IU" for reconstituted).
  - Dynamic dose units (g, mg, mcg, mL, IU, Unit) based on medication type/reconstitution.
  - Display target dose and IU per mL for reconstituted medications.
- **Navigation**
  - Fixed navigation to `MedicationDetailsScreen` after dosage save.
  - Protected navigation stack with `WillPopScope` in `MainScreen`.
- **Build Fixes** (May 26, 2025)
  - Added `Dosage` model and import in `main.dart`.
  - Updated `DosageFormFields` to include `doseUnits` parameter.

## Planned Features
- **Schedules**: Add/edit/delete schedules with frequency (hourly, daily, weekly, monthly), cycle periods, notifications.
- **Home Screen Cards**: Next dosage with "Take Now", "Postpone", "Cancel" buttons; upcoming dosages.
- **Calendar Screen**: Calendar view for scheduled dosages using `table_calendar`.
- **History**: Track taken/canceled/postponed dosages with CSV export.
- **Settings**: Light/dark/system themes, notification settings.

## Build Instructions
1. Clone: `git clone https://github.com/kinemspa/MedTrackr.git`
2. Install dependencies: `flutter pub get`
3. Run: `flutter run`

## Recent Changes
- Commit `42337984b04a1649c3229cd13d64832540a598a2`: Fixed navigation to `MedicationDetailsScreen`, enhanced medication/dosage features.
- Commit [Insert New Commit Hash]: Fixed build errors by adding `Dosage` model and `doseUnits` to `DosageFormFields`.

## Development Environment
- Flutter: Latest stable version
- IDE: Android Studio
- OS: Windows 11
- Emulator: sdk gphone64 x86 64