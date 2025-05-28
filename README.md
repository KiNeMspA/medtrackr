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
    - `enums.dart`: Single file for all enums (`MedicationType`, `QuantityUnit`, `DosageMethod`, `SyringeSize`, `FrequencyType`, `FluidUnit`, `TargetDoseUnit`). Used for calculations and UI consistency across features.
  - **core/**
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
  
### Folder Structure Restructuring (May 28, 2025, 17:51 PM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Kept enums in `lib/app/enums.dart` for app-wide use (`MedicationType`, `QuantityUnit`, `DosageMethod`, `SyringeSize`, `FrequencyType`, `FluidUnit`, `TargetDoseUnit`). Added `toMLFactor` to `FluidUnit` and `displayName` to `SyringeSize`.
  - Ensured `lib/app/themes.dart` uses `AppThemes` for consistent styling of Information (blue), Warning (orange), and Error (red) cards/messages.
  - Replaced `DataProvider` with feature-specific presenters (`MedicationPresenter`, `DosagePresenter`, `SchedulePresenter`) in `lib/features/*/presenters/*.dart`.
  - Moved `main.dart` to `lib/` and kept `constants.dart`, `themes.dart`, `routes.dart`, `enums.dart` in `lib/app/`.
  - Organized core utilities in `lib/core/utils/` (`format_helper.dart`, `validators.dart`), services in `lib/core/services/` (`database_service.dart`, `notification_service.dart`), and widgets in `lib/core/widgets/` (e.g., `app_bottom_navigation_bar.dart`, `confirm_medication_dialog.dart`).
  - Structured features into `lib/features/*/`: `models/`, `data/repos/`, `ui/views/`, `ui/widgets/`, `presenters/` for `medication`, `dosage`, `schedule`, `home`, `calendar`, `history`, `settings`.
  - Moved `reconstitution_calculator.dart` to `lib/features/medication/utils/` and widgets like `compact_medication_card.dart` to `lib/features/*/ui/widgets/`.
  - Renamed screens to `*_view.dart` (e.g., `medication_form_view.dart`) and providers to `*_presenter.dart` (e.g., `medication_presenter.dart`).
  - Deleted obsolete files: `storage_service.dart`, `data_provider.dart`, `database_service.dart` (in `data/repositories`), `date_utils.dart`, `dosage_form_pageOLD.dart`, `medication_form_pageOLD.dart`.
  - Created new files: `calendar_view.dart`, `confirm_dosage_dialog.dart`, `validators.dart`.
  - Updated all imports to use `app/enums.dart` and new paths, ensuring no deprecated `DataProvider` or `Themes` references remain.
  
  
  
  
## Planned Features
- Schedules: Cycle period calculations, multi-dose schedules.
- Calendar Screen: View using table_calendar.
- History: Track dosages with CSV export.
- Settings: Themes, notifications.
- Icons: Add Icons for various things.
- Free vs Paid versions
- Medication Information
- Estimated Expected time of Run out of stock
- 
- 
