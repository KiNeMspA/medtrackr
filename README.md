# MedTrackr

## Overview
MedTrackr is a mobile app designed to help users manage their medication schedules. Users can input medications and their respective schedules, and the app generates a consolidated schedule for medication intake. The app aims to provide a user-friendly interface with features like dose history logs and low quantity alerts.

## Project Status
- **Current Version**: Pre-release (no published releases yet)
- **Contributors**: 4 (see [Contributors](https://github.com/kinemspa/MedTrackr/graphs/contributors))
- **Repository**: [kinemspa/MedTrackr](https://github.com/kinemspa/MedTrackr)
- **Last Updated**: May 24, 2025

## Setup and Technical Details
- **Platform**: Android (developed using Android Studio)
- **Languages/Frameworks**: Kotlin, Jetpack Compose
- **Dependencies**:
    - Kotlin: 2.0.21
    - Android Gradle Plugin (AGP): 8.10.0
    - Compose Compiler: 1.5.15
    - Path Provider: 2.2.18
- **Key Configurations**:
    - NDK Version: 27.0.12077973 (fixed for build stability)
    - Compose Compiler Gradle Plugin: `org.jetbrains.kotlin.compose.compiler.gradle`
- **Setup Instructions**:
    1. Clone the repository: `git clone https://github.com/kinemspa/MedTrackr.git`
    2. Open in Android Studio, sync Gradle, and run `flutter doctor` (if Flutter is used).
    3. Enable developer options and USB debugging on an Android device for Wi-Fi testing.

## Features
- **Implemented**:
    - Medication input and schedule generation
    - Home Screen UI with medication cards
    - Add Dosage Screen for user input
    - Basic error handling for dosage saving
- **In Progress**:
    - Dose History Log
    - Low Quantity Alerts
    - Modern UI styling (Material Design 3, gradients, shadows)
- **Planned**:
    - Push notifications for medication reminders
    - Data persistence for offline use
    - Integration with health data APIs (if applicable)

## Session Logs
This section logs key discussion points and outcomes from each coding session to maintain continuity.

### Session: May 19, 2025
- **Topics Discussed**:
    - Fixed build errors in `HomeScreen.kt` (unresolved references, type mismatches).
    - Addressed crash in `AddDosageScreen.kt`/`DosageViewModel.kt` during dosage saving.
    - Resolved Settings Screen build failure in `MainActivity.kt` due to incorrect `@ExperimentalMaterial3Api` annotation.
- **Outcomes**:
    - Added error handling for `doseTime` parsing.
    - Moved annotation to a new composable function.
- **Pending Tasks**:
    - Test Settings Screen functionality.
    - Enhance UI for Home Screen.

### Session: May 23, 2025
- **Topics Discussed**:
    - Fixed GitHub sync issue (`src refspec main does not match any`) by verifying commits and pushing to `main`.
    - Resolved Gradle sync failure for `path_provider_android` by updating to version 2.2.18.
    - Fixed unresolved reference in `build.gradle.kts` (line 40, `getByName`).
- **Outcomes**:
    - Successful push to [kinemspa/MedTrackr](https://github.com/kinemspa/MedTrackr).
    - Stable build with updated NDK and dependencies.
- **Pending Tasks**:
    - Verify build after `getByName` fix.
    - Implement notifications for medication schedules.

### Session: May 24, 2025
- **Topics Discussed**:
    - Updated files: `dosage_schedule.dart`, `dosage_schedule_screen.dart`, `medication_manager.dart`, `medication_card.dart`, `home_screen.dart`, `add_medication_screen.dart`, `medication.dart`.
    - Implemented modern UI styling (gradients, shadows, Material Design 3).
    - Added Dose History Log and Low Quantity Alerts features.
    - Fixed errors in `MedicationManager` and `DosageSchedule`.
- **Outcomes**:
    - Successful testing of BPC-157 scenario.
    - Improved app usability and aesthetics.
- **Pending Tasks**:
    - Finalize notification system.
    - Test offline data persistence.

### Session: May 25, 2025
- **Topics Discussed**:
  - Redesigned MedTrackr UI to align with National Geographic app’s aesthetic using Flutter.
  - Implemented bottom navigation bar in `main.dart` with Home, Add Dosage, History, and Settings.
  - Updated `home_screen.dart` with swipeable medication cards using `ListView.horizontal`.
  - Enhanced `add_dosage_screen.dart` with clean input forms and yellow (#FFC107) accents.
  - Adopted color scheme: light gray background, National Geographic yellow accents, and high-contrast text.
- **Outcomes**:
  - Improved Home Screen with swipeable, tappable medication cards.
  - Added modern navigation and input forms for better usability.
  - Ensured accessibility with high-contrast text and `Semantics` support.
- **Pending Tasks**:
  - Test UI on various screen sizes and Android/iOS devices.
  - Add animations for card taps and screen transitions (e.g., using `Hero`).
  - Update `history_screen.dart` and `settings_screen.dart` to match new design.
  - Implement notification system for medication reminders.
  - - **Topics Discussed**:
  - Fixed missing file errors in `main.dart` for `home_screen.dart`, `add_dosage_screen.dart`, `history_screen.dart`, and `settings_screen.dart`.
  - Created missing files and updated imports to resolve build failure.
  - Updated `pubspec.yaml` to use `path_provider: ^2.2.18` and verified dependencies.
  - Enhanced `home_screen.dart` with tap animations for medication cards.
  - Confirmed National Geographic-inspired UI with yellow accents and swipeable cards.
- **Outcomes**:
  - Resolved build errors, enabling successful `flutter run`.
  - Improved Home Screen with animated, accessible medication cards.
- **Pending Tasks**:
  - Implement `history_screen.dart` and `settings_screen.dart` with National Geographic styling.
  - Add notification system using `flutter_local_notifications`.
  - Test UI on multiple devices for responsiveness.
  -   - Resolved dependency error for `path_provider_android ^2.2.18` by updating `pubspec.yaml` to use `path_provider: ^2.1.5`.
  - Added tap animation to `MedicationCard` in `home_screen.dart` using `ScaleTransition` and `AnimationController`.
  - Verified Gradle configuration in `settings.gradle` and `app/build.gradle`.
  - Continued National Geographic-inspired UI with yellow accents and swipeable cards.
- **Outcomes**:
  - Fixed dependency resolution, enabling successful `flutter pub get`.
  - Enhanced `MedicationCard` with a subtle scaling animation on tap.
  - Maintained accessibility with `Semantics` for screen readers.
- **Pending Tasks**:
  - Implement `history_screen.dart` and `settings_screen.dart` with matching UI styling.
  - Add notification system using `flutter_local_notifications`.
  - Test UI on multiple devices for responsiveness.
  - Add navigation to medication details from `MedicationCard` tap.
  - - **Topics Discussed**:
  - Restructured data model into `Medication`, `Dosage`, and `Schedule` classes for clarity.
  - Updated `medication.dart` and created `dosage.dart` and `schedule.dart`.
  - Modified `home_screen.dart` to use `Schedule` and `Medication` for displaying next dose times.
  - Updated `add_medication_screen.dart` to create `Medication` and `Schedule` objects.
  - Maintained National Geographic-inspired UI with yellow accents, swipeable cards, and tap animations.
- **Outcomes**:
  - Implemented new data model, resolving previous build errors.
  - Home Screen displays schedules with correct medication names and times.
- **Pending Tasks**:
  - Implement data persistence using `provider` and `path_provider`.
  - Style `history_screen.dart` and `settings_screen.dart` with National Geographic aesthetic.
  - Add notification system using `flutter_local_notifications`.
  - Add navigation to medication details from `MedicationCard` tap.
  -   - Reorganized file structure: Renamed `add_dosage_screen.dart` to `add_medication_screen.dart`, created `add_dosage_screen.dart` and `add_schedule_screen.dart`.
  - Updated `AddMedicationScreen` with dynamic `Storage Type`, integer `Total Storage Quantity`, and navigation to `AddDosageScreen` and `AddScheduleScreen`.
  - Implemented `AddDosageScreen` and `AddScheduleScreen` for modular data entry.
  - Maintained National Geographic-inspired UI with yellow accents, softened outlines, and swipeable cards.
- **Outcomes**:
  - Improved modularity with separate screens for `Medication`, `Dosage`, and `Schedule`.
  - Enhanced `AddMedicationScreen` with user-friendly features and navigation.
- **Pending Tasks**:
  - Implement data persistence using `provider` and `path_provider`.
  - Style `history_screen.dart` and `settings_screen.dart` with National Geographic aesthetic.
  - Implement notification system using `flutter_local_notifications`.
  - Add `Dosage` creation and tracking when marking doses as taken.
  - - Enhanced `AddMedicationScreen` by renaming `Storage Type` to `Stored In` (Syringe/Vial/Pen), `Total Storage Quantity` to `Total Medication Amount`, and moving `Measure` dropdown to the right.
  - Replaced reconstitution button with a toggle question and added a dosage calculator suggesting 3–4 reconstitution volumes based on single dose input.
  - Added dialog to prompt navigation to `AddDosageScreen` after saving.
  - Softened field outlines to `Colors.grey[300]` and darkened screen to `Colors.grey[200]`, maintaining National Geographic-inspired UI.
- **Outcomes**:
  - Improved `AddMedicationScreen` with user-friendly dosing calculations and intuitive navigation.
  - Ensured modular file structure and UI consistency.
- **Pending Tasks**:
  - Implement data persistence using `provider` and `path_provider`.
  - Style `history_screen.dart` and `settings_screen.dart` with National Geographic aesthetic.
  - Implement notification system using `flutter_local_notifications`.
  - Add `Dosage` creation and tracking when marking doses as taken.
  - - **Topics Discussed**:
  - Fixed build errors in `home_screen.dart` by restoring `MedicationCard` `StatefulWidget` structure, adding `Uuid` import, and correcting `Dosage` creation.
  - Resolved `main.dart` error by verifying `MainScreen` class.
  - Fixed `data_provider.dart` by importing `flutter_local_notifications` and `main.dart` for `flutterLocalNotificationsPlugin`.
  - Ensured data persistence, notifications, and dosage tracking functionality.
  - Maintained National Geographic-inspired UI with yellow accents, softened outlines, and darker background.
- **Outcomes**:
  - Restored app build and functionality after syntax and import errors.
  - Preserved modular file structure and enhanced features (reconstitution calculator, notifications).
- **Pending Tasks**:
  - Style `history_screen.dart` to display recorded dosages with timestamps.
  - Style `settings_screen.dart` with National Geographic aesthetic (e.g., toggle notifications).
  - Enhance notification details to include medication names.
  - Add editing/deleting functionality for medications and schedules.
  - - **Topics Discussed**:
  - Enhanced medication flow: navigate to `AddDosageScreen` after saving medication, pre-fill medication name.
  - Added `MedicationDetailsScreen` for `MedicationCard` tap to edit, add dosages/schedules.
  - Updated reconstitution UI with “Yes/No” toggle, “Target Single Dosage” label, calculation help.
  - Added dosage naming and linked schedules to dosages.
  - Implemented quantity deduction from `Medication.remainingQuantity` when doses are taken.
- **Outcomes**:
  - Improved usability for peptide dosing with precise reconstitution and dosage management.
  - Enhanced scheduling with dosage-specific notifications.
- **Pending Tasks**:
  - Add time picker for schedules in `add_schedule_screen.dart`.
  - Implement dark mode in `SettingsScreen`.
  - Add filtering/search to `HistoryScreen`.
  - Add confirmation dialogs for deletions.

**Features**:
- Add/edit/delete medications with reconstitution calculator.
- Multiple named dosages per medication with auto-calculated volume/IU for reconstituted medications.
- Schedules linked to specific dosages, deducting from remaining quantity.
- Medication details screen for managing medications, dosages, and schedules.
- **Topics Discussed**:
  - Fixed time picker display in `AddScheduleScreen` (time disappearing after dosage selection).
  - Enhanced reconstitution UI in `AddMedicationScreen`: “Yes/No” toggle with labels, fixed “Calculate” button, added four IU-based options, and “Add” button to update storage.
- **Outcomes**:
  - Resolved time picker UI issue with `TextEditingController`.
  - Improved reconstitution workflow with clear toggle, functional calculations, and storage updates.
- **Pending Tasks**:
  - Apply lighter fields to `edit_medication_screen.dart`, `add_dosage_screen.dart`.
  - Implement vertical `HomeScreen` cards sorted by next dose.
  - Add `CalendarScreen` with `table_calendar`.
  - Update cards/FAB to `Colors.grey[50]`.
  - Implement dark mode toggle in `SettingsScreen`.
  - Add filtering/search to `HistoryScreen`.

**Features**:
- Persistent time picker display in `AddScheduleScreen`.
- Enhanced reconstitution UI with “Yes/No” toggle, IU calculations, and “Add” button.
- Dosage and schedule deletion with confirmation dialogs.
- Lighter form fields (`Colors.grey[50]`) in `AddMedicationScreen`.

## To-Do List
- Short-term:
    - Test and finalize notifications for medication reminders.
    - Ensure Settings Screen is fully functional.
- Long-term:
    - Add support for multiple user profiles.
    - Explore health data API integration for compliance and functionality.

## How to Update This README
1. After each session, add a new "Session" entry under "Session Logs" with:
    - Date of the session.
    - Topics discussed (e.g., issues fixed, features added).
    - Outcomes (e.g., resolved errors, new commits).
    - Pending tasks for the next session.
2. Update the "Features" and "To-Do List" sections to reflect current progress.
3. Commit changes to the repository: `git add README.md`, `git commit -m "Updated README with session details"`, `git push origin main`.
4. Verify the commit on GitHub to ensure the README is up to date.

## Contact
For issues or collaboration, open an issue on the [GitHub Issues page](https://github.com/kinemspa/MedTrackr/issues) or contact the project lead via [GitHub](https://github.com/kinemspa).