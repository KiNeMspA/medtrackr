# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Features Implemented
To update this section:
- Add new features or build fixes under the relevant category (e.g., Medication Management, Build Fixes).
- Include the date (e.g., May 26, 2025), time (e.g., 04:30 PM AEST), and commit hash.
- Commit changes with `git add README.md`, `git commit -m "Updated README with changes"`, and `git push origin main`.
- Retrieve the commit hash with `git log -1 --pretty=%H` and share it in the next chat.

- **Medication Management** (May 26, 2025)
  - Add, edit, delete medications (Tablet, Capsule, Injection, Other).
  - Quantity units (g, mg, mcg, mL, IU, Unit) with accurate conversions.
  - Reconstitution: single syringe size dropdown (0.3, 0.5, 1, 3, 5 mL), peptide formula (C=p/V, V_d=d/C), rounded volumes, warning bypass.
  - Helper text for stock entry.
  - National Geographic-themed UI: yellow accents, white cards, rounded corners.
- **Dosage Management**
  - Add, edit, delete dosages (e.g., "BPC157 Dose of 100mcg").
  - Dynamic summary card per dose.
  - Units: mcg, syringe units for reconstituted injections.
  - No purple field highlighting.
- **Home Screen**
  - FAB for adding medications.
  - "No medications added" message.
  - Next scheduled dose display.
  - Medication tiles with "Remaining X/Y" (mL for reconstituted).
  - Schedule creation button.
- **Schedules**
  - Pre-populate medication/dosage, optional cycle period.
  - Frequency: hourly, daily, weekly, monthly.
  - Navigate to MedicationDetailsScreen after saving.
  - Notifications with details, supporting daily/weekly recurrence.
- **Navigation**
  - Bottom navigation bar on all screens (Home, Calendar, History, Settings).
  - Protected navigation stack with `WillPopScope`.
- **Build Fixes**
  - Commit `42337984b04a1649c3229cd13d64832540a598a2`: Fixed navigation.
  - Commit `e74e621a05e653bd8d730056e2519cf07164dd5c`: Added `Dosage`, `doseUnits`.
  - Commit `0a51ccb38b274a19219cc576c682d097291d12c6`: Enhanced UI, fixed reconstitution.
  - Commit `f1b5971aa29a8a2f225f227f857e7d54ba8956c4`: Added home screen, schedule model.
  - Commit `6f0eff93734fccc40feabdb07914376e48ca0754`: Fixed `upcomingDoses` parsing.
  - Commit `d252f5421fb91218394db19fe45378d3bc7647b7`: Fixed schedule imports, async methods.
  - Commit `b81b4326b56deb0e54a70c98f79011be2afbd7c4`: Fixed `notification_service.dart`.
  - Commit `96ac5411efb7b0986842f089765275b443caf76c`: Fixed reconstitution, added schedule creation.
  - Commit `35f206cae73add2a5b0d94624db602a337c08b45`: Fixed reconstitution math, syringe pop-up.
  - Commit `f87b75af7b96ffae8726e39b540a91489ec94b5c`: Removed duplicate syringe dropdown, added schedule and UI enhancements.
  - Commit `c75b6817a25d24c1e0813a6b52dd2e0cfb31d253` (May 26, 2025, 04:30 PM AEST):
  - Fixed `selectedIU` in `main.dart`, `amount` and `dosageUnit` in `add_dosage_screen.dart`.
  - Corrected `dosageUnit`, `frequencyType`, and `notificationTime` in `add_schedule_screen.dart`.
  - Updated `notificationTime` to `int?` in `schedule.dart` and fixed type mismatches in `data_provider.dart` and `notification_service.dart`.
  - Commit `f74b6601948f0062a0ee54b47de2bad9b9ba8a89` (May 26, 2025, 04:25 PM AEST):
  - Fixed `selectedIU` in `main.dart`.
  - Corrected `Dosage` fields (`dosageAmount`, `unit`) in `add_dosage_screen.dart` and `add_schedule_screen.dart`.
  - Fixed `notificationTime` handling in `notification_service.dart` and `data_provider.dart`.
  - Initial setup for medication input and schedule generation.
  - Fixed errors in DosageMethod enum, null safety, missing parameters, and type mismatches in dosage and schedule screens.
  - Latest commit hash: `158216041ab3d87e0c3eb7b8a62da55023a4fad1`
  - Initial setup for medication input and schedule generation.
  - Fixed errors in DosageMethod enum, null safety, missing parameters, and type mismatches in dosage and schedule screens.
  - Latest commit hash: `4524241d0b48148781c78b4962298ec2f387ec46`
  - - Initial setup for medication input and schedule generation.
  - Fixed errors in DosageMethod, FrequencyType, missing parameters, undefined identifiers, and type mismatches.
  - Resolved warnings for unused variables and imports.
  - Latest commit hash: `d951f27e2df3a35fb171ea9e78e84a7c5cdf222b`
  - Initial setup for medication input and schedule generation.
  - Fixed errors in undefined identifiers, missing parameters, type mismatches, and ambiguous imports.
  - Removed duplicate FrequencyType enum from schedule.dart.
  - Resolved warnings for unused variables and dead code.
  - Latest commit hash: `36cd007435e39ca9088c2fb458c51ffa3b2e3e48`
  - Initial setup for medication input and schedule generation.
  - Fixed errors in undefined identifiers, missing parameters, type mismatches, and ambiguous imports.
  - Removed duplicate FrequencyType enum from schedule.dart and added missing imports.
  - Resolved warnings for unused variables and dead code.
  - Latest commit hash: `c9ae2f5105b8962dff688a98ae7048bfe38c584f`
  - Initial setup for medication input and schedule generation.
  - Fixed duplicate bottom navigation bar on HomeScreen.
  - Added AppBottomNavigationBar in `lib/widgets/navigation`.
  - Updated AddMedicationScreen to start with Medicine Type selection.
  - Moved reconstitution calculator to ReconstitutionScreen for Injection/Other types.
  - Fixed AddDosageScreen crash and updated UI (default name, dose unit placement).
  - Enhanced MedicationDetailsScreen with Add Schedule and Reconstitute buttons.
  - Improved confirmation dialogs with bolded text and styling.
  - Latest commit hash: `7cb8624efea1847ffb466829cddd6526f195c6bd`
  - Added syringe size/type to IU terminology in Confirm Reconstitution Screen (May 27, 2025, 11:07 AM AEST, commit c131107f17269ebf6c331e1f52d7d153499f9cf8).
  - Added SyringeSize enum in lib/models/enums/syringe_size.dart and updated ReconstitutionScreen to use it for syringe sizes (May 27, 2025, 11:25 AM AEST, commit f990613919f45ae2b520cc1e811766e88a948feb).
  - Added cardDecoration constant in constants.dart and applied consistent card styling to MedicationDetailsScreen and ReconstitutionScreen (May 27, 2025, 11:29 AM AEST, commit ecac760eec1ab72764e350f39953ad40c47422c2).
  - Fixed cardDecoration constant in constants.dart to use const-compatible Border and BorderRadius, applied to MedicationCard and ReconstitutionScreen cards. Commit e8d779f0e2753d37f08977dc6e1edf021f6ff85e (May 27, 2025, 12:01 PM AEST):
  - Removed yellow highlight from MedicationCard and ReconstitutionScreen cards for cleaner styling (May 27, 2025, 12:11 PM AEST, commit <280b19dd8d7761f28638ecaa5dbc92f935f7a5ff>).- Enhanced card styling with National Geographic aesthetic (off-white background, shadow, yellow highlights, modern typography) in MedicationDetailsScreen and ReconstitutionScreen (May 27, 2025, 12:05 PM AEST, commit a8d86ec3f73600b57f3d6ce041d681f48387f61c).
  - Consolidated add/edit medication screens, added enums, made MedicationCard tappable, moved reconstitution option to button in MedicationDetailsScreen (May 27, 2025, 1:05 PM AEST, commit <new_commit_hash>).




## Workflow Preservation
To maintain the current development workflow with Grok:
1. Provide the latest commit hash from https://github.com/kinemedsppa/MedTrackr.
2. Share detailed feedback on UI/UX, functionality, and bugs, including console logs or errors.
3. Include any missing files (e.g., `medication.dart`) if referenced.
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
- 
