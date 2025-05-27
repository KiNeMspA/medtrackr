# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Notes for Grok**: 
- Always provide code snippets with clear instructions on where to paste them in the specified files. Do not include full file replacements unless explicitly requested. (May 27, 2025, 10:38 PM AEST)
- Provide minimal code snippets targeting specific changes, avoiding full file replacements unless necessary, to save memory. Include precise placement instructions. (May 27, 2025, 11:18 PM AEST)
- Information cards use `Themes.informationCardDecoration` for consistent styling (off-white, yellow border, shadow).
- Information cards use `Themes.informationCardDecoration` for consistent styling (off-white, yellow border, shadow).
- For numeric displays, drop trailing decimal zeros app-wide (e.g., 1.0 → 1) using a formatting function.

## Features Implemented
To update this section:
- Add new features or fixes under the relevant category.
- Include date, time (AEST), and commit hash.
- Commit changes with `git add README.md`, `git commit -m "Updated README with changes"`, `git push origin main`.
- Retrieve commit hash with `git log -1 --pretty=%H`.

### Features and Fixes
- **Medication Management** (May 26, 2025)
  - Add, edit, delete medications (Tablet, Capsule, Injection, Other).
  - Quantity units (g, mg, mcg, mL, IU, Unit) with conversions.
  - Reconstitution: syringe size dropdown (0.3, 0.5, 1, 3, 5 mL), peptide formula (C=p/V, V_d=d/C), rounded volumes, warning bypass.
  - Helper text for stock entry.
  - National Geographic-themed UI: yellow accents, white cards, rounded corners.
  - Commit: `c75b6817a25d24c1e0813a6b52dd2e0cfb31d253`

- **Dosage Management** (May 27, 2025)
  - Add, edit, delete dosages (e.g., "BPC157 Dose of 100mcg").
  - Dynamic summary card per dose.
  - Units: mcg, syringe units for reconstituted injections.
  - Form-based add/edit with validation, map-based arguments.
  - Dosage name field with dynamic defaults, reconstitution defaults, syringe size for injections.
  - Recent dosages in MedicationCard on MedicationDetailsScreen.
  - Commits: `c75b6817a25d24c1e0813a6b52dd2e0cfb31d253`, `ca43f038c3f484596b9a6e6a919182d0933a32ef`

- **Home Screen** (May 26, 2025)
  - FAB for adding medications.
  - "No medications added" message.
  - Next scheduled dose display.
  - Medication tiles with "Remaining X/Y" (mL for reconstituted).
  - Schedule creation button.
  - Commit: `f1b5971aa29a8a2f225f227f857e7d54ba8956c4`

- **Schedules** (May 26, 2025)
  - Pre-populate medication/dosage, optional cycle period.
  - Frequency: hourly, daily, weekly, monthly.
  - Navigate to MedicationDetailsScreen after saving.
  - Notifications with details, supporting daily/weekly recurrence.
  - Commit: `96ac5411efb7b0986842f089765275b443caf76c`

- **Navigation** (May 26, 2025)
  - Bottom navigation bar on all screens (Home, Calendar, History, Settings).
  - Protected navigation stack with `WillPopScope`.
  - Commit: `42337984b04a1649c3229cd13d64832540a598a2`

- **UI Enhancements** (May 27, 2025)
  - Created CompactMedicationCard for HomeScreen.
  - Improved MedicationCard styling (gradient, spacing).
  - Moved medication name into MedicationCard.
  - Card styling: off-white background, shadow, yellow highlights, modern typography.
  - Commit: `ca43f038c3f484596b9a6e6a919182d0933a32ef`

- **Build Fixes** (May 27, 2025)
  - Fixed `selectedIU` in `main.dart`, `dosageUnit`, `frequencyType`, `notificationTime` in screens.
  - Fixed type mismatches in `data_provider.dart`, `notification_service.dart`.
  - Fixed `dosage_form_screen.dart`: removed invalid `importPlaylist`, added null check for `recon['syringeSize']`, corrected `_tabletCountController`, moved `isReconstituted` to class level.
  - Fixed `medication_form_screen.dart`: added `tabletCountController`, `volumeController`.
  - Created `lib/models/enums.dart` barrel file for enum imports.
  - Commits: `f74b6601948f0062a0ee54b47de2bad9b9ba8a89`, `ca43f038c3f484596b9a6e6a919182d0933a32ef`
  - Fixed `CompactMedicationCard` navigation to `MedicationDetailsScreen` by adding `/medication_details` route in `main.dart`.
  - Commit: `f7fafe15093810cd531c9b8c6cebaffd5235b5e0` (May 27, 2025, 10:25 PM AEST)
  - Restored card styling in `MedicationDetailsScreen` with `AppConstants.cardDecoration` (yellow border, off-white background, shadow, rounded corners).
  - Updated `constants.dart` to include yellow border in `cardDecoration`.
  - Commit: <new_commit_hash> (May 27, 2025, 10:31 PM AEST)
  - Fixed `MedicationDetailsScreen` layout issues causing stacked cards and unresponsiveness.
  - Added `ConstrainedBox` and adjusted `Column` sizing to ensure proper rendering.
  - Commit: `6bc1f8304e16f476bff016b63f978cab00e4e155` (May 27, 2025, 10:58 PM AEST)
  - Added help text for `MedicationType` dropdown and `Total Units` in `MedicationFormScreen`.
  - Made `Dose per Tablet` unit dropdown functional (g, mg, mcg).
  - Fixed confirmation dialog text display issue.
  - Commit: <new_commit_hash> (May 27, 2025, 11:18 PM AEST)
  - Added help text for `MedicationType` dropdown and `Total Units` in `MedicationFormScreen`.
  - Made `Dose per Tablet` unit dropdown functional (g, mg, mcg).
  - Fixed confirmation dialog text display issue.
  - Commit: `ea39b884e4591f7c682d7f42940f55177a23cfdd` (May 27, 2025, 11:18 PM AEST)

## Workflow Preservation
To maintain development workflow with Grok:
1. Provide latest commit hash from https://github.com/kinemspa/MedTrackr.
2. Share UI/UX feedback, functionality issues, bugs, console logs.
3. Include missing files if referenced.
4. Specify desired changes with examples.
5. Grok will:
  - Analyze commit and feedback.
  - Provide updated code with explanations.
  - Include commit instructions.
  - Update README with progress.
  - Request test results and priorities.

## Planned Features
- Schedules: Cycle period calculations, multi-dose schedules.
- Calendar Screen: View using `table_calendar`.
- History: Track dosages with CSV export.
- Settings: Themes, notifications.

## Build Instructions
1. Clone: `git clone https://github.com/kinemspa/MedTrackr.git`
2. Install dependencies: `flutter pub get`
3. Run: `flutter run`

## Development Environment
- Flutter: Latest stable version
- IDE: Android Studio
- OS: Windows 11
- Emulator: sdk gphone64 x86 64