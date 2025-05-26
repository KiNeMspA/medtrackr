# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Features Implemented
- **Medication Management** (May 26, 2025)
  - Add, edit, delete medications with types: Tablet, Capsule, Injection, Other.
  - Support for quantity units (g, mg, mcg, mL, IU, Unit) based on medication type.
  - Reconstitution support for Injection/Other with fluid and IU calculations.
  - Navigation to `MedicationDetailsScreen` after adding medication and dosage.
  - Icons for medication types in `MedicationDetailsScreen`.
- **Dosage Management**
  - Add, edit, delete dosages with default names (e.g., "Dose of X IU" for reconstituted).
  - Dynamic dose units based on medication type and reconstitution status.
  - Display target dose for reconstituted medications.
- **Navigation**
  - Fixed navigation to return to `MedicationDetailsScreen` after adding dosage.
  - Protected navigation stack with `WillPopScope` in `MainScreen`.

## Planned Features
- **Schedules**: Add/edit/delete schedules with frequency (hourly, daily, weekly, monthly), cycle periods, and notifications.
- **Home Screen Cards**: Display next dosage with "Take Now", "Postpone", "Cancel" buttons; show upcoming dosages.
- **Calendar Screen**: Calendar view for scheduled dosages using `table_calendar`.
- **History**: Track taken/canceled/postponed dosages with exportable CSV reports.
- **Settings**: Light/dark/system themes, notification settings.

## Build Instructions
1. Clone the repository: `git clone https://github.com/kinemspa/MedTrackr.git`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

## Recent Changes
- Commit [Insert Commit Hash]: Fixed build errors, updated navigation to `MedicationDetailsScreen`, enhanced medication/dosage features.

## Development Environment
- Flutter: Latest stable version
- IDE: Android Studio
- OS: Windows 11
- Emulator: sdk gphone64 x86 64