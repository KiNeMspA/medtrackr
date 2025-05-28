# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Notes for Grok

- **Date of Restructuring**: May 28, 2025
- **Enums**: All enums are consolidated in `lib/core/enums/enums.dart` for app-wide calculations (e.g., `QuantityUnit` conversions). Do not split into feature-specific enum files.
- **Themes**: General styling for Information, Warning, and Error cards/messages is in `lib/app/themes.dart`. Use `AppThemes.informationCardDecoration`, `AppThemes.warningBackgroundColor`, etc., for consistent UI across all files.
- **Code Snippets**: When providing changes, include precise line numbers and code references to existing file content to ensure accuracy.
- **Restructuring Completed**: Folder structure is modular with feature-specific directories (`medication`, `dosage`, `schedule`). `DataProvider` is split into `MedicationProvider`, `DosageProvider`, and `ScheduleProvider` with corresponding repositories.
- **When reviewing and adding new code please make sure to utilise the new folder structure and place the required code , operations, functions and files in their respective directory for efficiency. 

## Folder Structure

Below is the restructured folder structure, detailing where each file type/operation is located and its purpose:

- **lib/**
  - **app/**
    - `constants.dart`: Defines app-wide constants (e.g., `primaryColor`, `appName`, `cardTitleStyle`). Used for shared styling and configuration values across the app.
    - `themes.dart`: Contains `AppThemes` with `ThemeData` and styling for Information, Warning, and Error cards/messages (e.g., `informationCardDecoration`, `warningBackgroundColor`). Provides general theme styling accessible app-wide.
    - `routes.dart`: Defines navigation routes (`AppRoutes`) for all screens (e.g., `/home`, `/medication_form`). Centralizes routing logic.
  - **core/**
    - **enums/**
      - `enums.dart`: Single file for all enums (`MedicationType`, `QuantityUnit`, `DosageMethod`, `SyringeSize`, `FrequencyType`, `FluidUnit`, `TargetDoseUnit`). Used for calculations and UI consistency across features.
    - **utils/**
      - `format_helper.dart`: Utility for number formatting (e.g., `formatNumber` to drop trailing zeros). Used for consistent numeric display.
      - `validators.dart`: Input validation logic for forms (e.g., required fields). Supports form validation across features.
    - **services/**
      - `database_service.dart`: Handles JSON file persistence (`saveData`, `loadData`, `migrateData`). Manages data storage for medications, dosages, and schedules.
      - `notification_service.dart`: Manages notification scheduling and cancellation. Used for schedule reminders.
    - **widgets/**
      - `app_bottom_navigation_bar.dart`: Bottom navigation bar widget for app-wide navigation (Home, Calendar, History, Settings).
      - `confirm_medication_dialog.dart`: Dialog for confirming medication actions. Uses `AppThemes.informationCardDecoration`.
      - `confirm_dosage_dialog.dart`: Dialog for confirming dosage actions. Uses `AppThemes.informationCardDecoration` or `AppThemes.warningCardDecoration`.
      - `confirm_schedule_dialog.dart`: Dialog for confirming schedule actions. Uses `AppThemes.informationCardDecoration`.
  - **features/**
    - **medication/**
      - **models/**
        - `medication.dart`: `Medication` model defining medication data (e.g., name, type, quantity). Used for data storage and UI.
      - **repositories/**
        - `medication_repository.dart`: Data operations for medications (e.g., add, update, delete). Interacts with `DatabaseService`.
      - **pages/**
        - `medication_form_page.dart`: Screen for adding/editing medications. Uses `MedicationProvider` and `MedicationFormFields`.
        - `medication_details_page.dart`: Screen for viewing medication details. Displays cards and reconstitution options.
        - `reconstitution_page.dart`: Screen for calculating reconstitution for injections. Uses `Medication` model.
      - **widgets/**
        - `medication_card.dart`: Card widget for displaying medication info. Uses `AppThemes.informationCardDecoration`.
        - `compact_medication_card.dart`: Compact card for medication summaries (e.g., on Home screen).
        - `medication_form_fields.dart`: Form fields for medication input. Supports `medication_form_page.dart`.
      - **providers/**
        - `medication_provider.dart`: State management for medications (e.g., `addMedication`, `updateMedication`). Uses `MedicationRepository`.
    - **dosage/**
      - **models/**
        - `dose.dart`: `Dosage` model defining dosage data (e.g., totalDose, method). Used for data storage and UI.
      - **repositories/**
        - `dosage_repository.dart`: Data operations for dosages (e.g., add, update, delete). Interacts with `DatabaseService`.
      - **pages/**
        - `dosage_form_page.dart`: Screen for adding/editing dosages. Uses `DosageProvider` and `DosageFormFields`.
      - **widgets/**
        - `dosage_form_fields.dart`: Form fields for dosage input. Supports `dosage_form_page.dart`.
      - **providers/**
        - `dosage_provider.dart`: State management for dosages (e.g., `addDosage`, `takeDose`). Uses `DosageRepository`.
    - **schedule/**
      - **models/**
        - `schedule.dart`: `Schedule` model defining schedule data (e.g., time, frequencyType). Used for data storage and UI.
      - **repositories/**
        - `schedule_repository.dart`: Data operations for schedules (e.g., add, update, delete). Interacts with `DatabaseService`.
      - **pages/**
        - `schedule_form_page.dart`: Screen for adding/editing schedules. Uses `ScheduleProvider` and `ScheduleFormFields`.
      - **widgets/**
        - `schedule_form_fields.dart`: Form fields for schedule input. Supports `schedule_form_page.dart`.
      - **providers/**
        - `schedule_provider.dart`: State management for schedules (e.g., `addSchedule`, `upcomingDoses`). Uses `ScheduleRepository`.
    - **home/**
      - **pages/**
        - `home_page.dart`: Home screen displaying medication summaries and navigation. Uses `MedicationProvider` and `ScheduleProvider`.
      - **providers/**
        - `home_provider.dart`: State management for home screen (if implemented). Coordinates data for display.
    - **calendar/**
      - **pages/**
        - `calendar_page.dart`: Placeholder for calendar screen. Planned for schedule visualization.
    - **history/**
      - **pages/**
        - `history_page.dart`: Placeholder for history screen. Planned for dosage tracking.
    - **settings/**
      - **pages/**
        - `settings_page.dart`: Placeholder for settings screen. Planned for theme/notification settings.
  - **main.dart**: App entry point. Sets up `MultiProvider` for `MedicationProvider`, `DosageProvider`, `ScheduleProvider`, `DatabaseService`, `NotificationService`, and initializes `AppRoutes` and `AppThemes`.

## Features Implemented

### Folder Structure Restructuring (May 28, 2025)
- **Commit**: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
- **Details**:
  - Consolidated all enums into `lib/core/enums/enums.dart` for simplicity and shared calculations (e.g., `QuantityUnit` conversions). Renamed from `barrel_enums.dart`.
  - Updated `app/themes.dart` to include general theme styling for Information, Warning, and Error cards/messages. Properties like `AppThemes.informationCardDecoration`, `AppThemes.warningBackgroundColor`, and `AppThemes.errorTitleStyle` are used app-wide for consistent UI.
  - Fixed `Themes` error in `dosage_form_page.dart` and `schedule_form_page.dart` by replacing `Themes` with `AppThemes`.
  - Split `DataProvider` into `MedicationProvider`, `DosageProvider`, and `ScheduleProvider` with corresponding repositories (`medication_repository.dart`, `dosage_repository.dart`, `schedule_repository.dart`) for modular data management.
  - Moved JSON persistence to `database_service.dart` for centralized data storage.
  - Updated `main.dart` to use `MultiProvider` and `AppRoutes` for navigation.
  - Ensured `routes.dart` uses `enums.dart` for routing logic.
- **Commit Instructions**:
  ```bash
  
  git commit -m "Restructured folder structure, consolidated enums, updated themes"
  git push origin main
  git log -1 --pretty=%H
Planned Features
Schedules: Cycle period calculations, multi-dose schedules.
Calendar Screen: View using table_calendar.
History: Track dosages with CSV export.
Settings: Themes, notifications.
Build Instructions
Clone: git clone https://github.com/kinemspa/MedTrackr.git
Install dependencies: flutter pub get
Run: flutter run
Development Environment
Flutter: Latest stable version
IDE: Android Studio
OS: Windows 11
Emulator: sdk gphone64 x86 64
About
A Medicine Tracking App

Releases
No releases published

Packages
No packages published

Footer
© 2025 GitHub, Inc.