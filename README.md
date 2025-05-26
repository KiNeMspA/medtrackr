# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Features Implemented
- **Medication Management** (May 26, 2025)
  - Add, edit, delete medications (types: Tablet, Capsule, Injection, Other).
  - Quantity units (g, mg, mcg, mL, IU, Unit) based on type.
  - Reconstitution for Injection/Other with fluid, IU calculations, ±0.1 mL adjustments.
  - Navigation to `MedicationDetailsScreen` after adding medication/dosage.
  - Edit medication by tapping card in `MedicationDetailsScreen`.
  - National Geographic-themed UI: yellow accents, white cards, rounded corners.
- **Dosage Management**
  - Add, edit, delete dosages with default names (e.g., "BPC157 Dose of 600mcg").
  - Dynamic dose units, no trailing zeros, units displayed beside values.
  - Subcutaneous method shown as "Subcutaneous Injection", IU/CC for reconstituted.
  - Removed storage volume field.
- **Navigation**
  - Fixed navigation to `MedicationDetailsScreen`.
  - Protected navigation stack with `WillPopScope`.
- **Build Fixes**
  - Commit `42337984b04a1649c3229cd13d64832540a598a2`: Fixed navigation, added features.
  - Commit `e74e621a05e653bd8d730056e2519cf07164dd5c`: Added `Dosage` model, `doseUnits`.
  - Commit `0a51ccb38b274a19219cc576c682d097291d12c6`: Fixed type cast error, enhanced UI, fixed reconstitution bugs.

## Planned Features
- **Schedules**: Add/edit/delete schedules with frequency, cycles, notifications.
- **Home Screen Cards**: Next dosage with "Take Now", "Postpone", "Cancel".
- **Calendar Screen**: Calendar view using `table_calendar`.
- **History**: Track taken/canceled/postponed dosages with CSV export.
- **Settings**: Light/dark/system themes, notifications.

## Build Instructions
1. Clone: `git clone https://github.com/kinemspa/MedTrackr.git`
2. Install dependencies: `flutter pub get`
3. Run: `flutter run`

## Development Environment
- Flutter: Latest stable version
- IDE: Android Studio
- OS: Windows 11
- Emulator: sdk gphone64 x86 64