# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Features Implemented
- **Medication Management** (May 26, 2025)
  - Add, edit, delete medications (Tablet, Capsule, Injection, Other).
  - Quantity units (g, mg, mcg, mL, IU, Unit) with accurate conversions.
  - Reconstitution for Injection/Other: fluid, syringe size (0.3-5mL), four suggestions, ±0.1 mL adjustments.
  - Helper text for stock entry (vial potency, tablet count/potency).
  - National Geographic-themed UI: yellow accents, white cards, rounded corners.
- **Dosage Management**
  - Add, edit, delete dosages with names like "BPC157 Dose of 600mcg".
  - Dose in mass units (mcg), IU/CC for syringe delivery in reconstituted injections.
  - Dynamic summary card on dosage screen.
  - Removed purple field highlighting.
- **Home Screen**
  - FAB for adding medications.
  - "No medications added" message.
  - Large card for next dose, two smaller cards for following doses.
- **Schedules**
  - Add schedules with medication/dosage selection, frequency (hourly, daily, weekly, monthly), cycle periods.
  - Notifications with medication/dosage details, supporting daily/weekly recurrence.
- **Navigation**
  - Fixed navigation to `MedicationDetailsScreen`.
  - Protected navigation stack with `WillPopScope`.
- **Build Fixes**
  - Commit `42337984b04a1649c3229cd13d64832540a598a2`: Fixed navigation.
  - Commit `e74e621a05e653bd8d730056e2519cf07164dd5c`: Added `Dosage`, `doseUnits`.
  - Commit `0a51ccb38b274a19219cc576c682d097291d12c6`: Enhanced UI, fixed reconstitution.
  - Commit `f1b5971aa29a8a2f225f227f857e7d54ba8956c4`: Added home screen, schedule model.
  - Commit `6f0eff93734fccc40feabdb07914376e48ca0754`: Fixed `upcomingDoses` parsing.
  - Commit `d252f5421fb91218394db19fe45378d3bc7647b7`: Fixed schedule imports, async methods, notifications.

## Workflow Preservation
To maintain the current development workflow with Grok:
1. Provide the latest commit hash from https://github.com/kinemedsppa/MedTrackr.
2. Share detailed feedback on UI/UX, functionality, and bugs, including console logs or errors.
3. Include any missing files (e.g., `reconstitution_calculator.dart`) if referenced.
4. Specify desired changes with examples (e.g., styling, medical terminology).
5. Grok will:
  - Analyze the commit and feedback.
  - Provide updated code with explanations.
  - Include commit instructions (stage, commit, push).
  - Update README with progress and workflow notes.
  - Request test results and next priorities.

## Planned Features
- **Schedules**: Add cycle period calculations, multi-dose schedules.
- **Calendar Screen**: View using `table_calendar`.
- **History**: Track dosages with CSV export.
- **Settings**: Themes, notifications.

## Build Instructions
1. Clone: `git clone https://github.com/kinemedsppa/MedTrackr.git`
2. Install dependencies: `flutter pub get`
3. Run: `flutter run`

## Development Environment
- Flutter: Latest stable version
- IDE: Android Studio
- OS: Windows 11
- Emulator: sdk gphone64 x86 64