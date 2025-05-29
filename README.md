# MedTrackr

A Flutter-based medication tracking app to manage medications, dosages, schedules, and history.

## Notes for Grok

- **Date of Restructuring**: May 28, 2025
- **Enums**: All enums are consolidated in `lib/core/enums/enums.dart` for app-wide calculations (e.g., `QuantityUnit` conversions). Do not split into feature-specific enum files.
- **Themes**: General styling for Information, Warning, and Error cards/messages is in `lib/app/themes.dart`. Use `AppThemes.informationCardDecoration`, `AppThemes.warningBackgroundColor`, etc., for consistent UI across all files.
- **Code Snippets**: When providing changes, include precise line numbers and code references to existing file content to ensure accuracy. this also reduces your load and I dont have to wait for entire code snippet files. 
- **Restructuring Completed**: Folder structure is modular with feature-specific directories (`medication`, `dosage`, `schedule`). `DataProvider` is split into `MedicationProvider`, `DosageProvider`, and `ScheduleProvider` with corresponding repositories.
- **When reviewing and adding new code please make sure to utilise the new folder structure and place the required code , operations, functions and files in their respective directory for efficiency. 

## Features

- **Medication Management**: Add, edit, and delete medications with detailed information (e.g., type, quantity, dose per tablet/capsule).
- **Dosage Tracking**: Create and manage dosage plans for each medication, including support for tablets, capsules, and injections.
- **Reconstitution for Injections**: Calculate and manage reconstitution for injectable medications, with support for different syringe sizes and fluid types.
- **Scheduling**: Set up schedules for dosages with reminders via notifications.
- **Stock Alerts**: Receive notifications when medication stock is low.
- **Modern Design**: A 2025-inspired UI with a teal primary color, coral accents, and the Inter font for a clean, geometric look.
- **Dark Mode**: Toggle between light and dark themes for better accessibility.
- **Consistent Styling**: All views and dialogs use centralized `AppConstants` and `AppThemes` for a cohesive look and feel.

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
  
### ReconstitutionView Fix and Checklist Progress (May 28, 2025, 7:58 PM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Fixed `reconstitution_view.dart` by providing a complete file with centralized styling from `themes.dart`, addressing all verification checklist requirements (modern styling, single formula line, clear option cards, arrow placement, out-of-range warnings, enhanced confirmation dialog).
  - Added "Edit Schedule" button in `medication_details_view.dart` for scheduling functionality.
  - Enhanced `notification_service.dart` with logging to confirm notification scheduling.
  - Updated `calendar_view.dart` to map `frequencyType` for accurate schedule dates, syncing with `home_view.dart`.
  - Continued styling audit, ensuring all inline styles are centralized in `themes.dart`.
  - Verified dosage tracking, settings toggle, and data persistence.

### Issue Fixes and Checklist Completion (May 28, 2025, 8:19 PM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Restored "Add Medication" button in `home_view.dart` AppBar.
  - Fixed tablet dosage form in `dosage_form_fields.dart` to show correct "Tablets" label.
  - Updated `format_helper.dart` to remove trailing zeros in total dose display.
  - Enhanced `settings_view.dart` notification toggle with logging and error handling.
  - Updated `home_view.dart` to display all upcoming schedules in a ListView.
  - Finalized styling audit by centralizing scrollbar styles in `themes.dart`.
  - Progressed verification checklist: verified dosage tracking, scheduling, calendar sync, settings, and data persistence testing.

### Runtime and Build Error Fixes, Checklist Progress (May 28, 2025, 8:45 PM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Fixed calendar screen back button to use `Navigator.pop` in `calendar_view.dart`.
  - Resolved `PrimaryScrollController` conflict by converting `HomeView` to `StatefulWidget` with dedicated `ScrollController`s.
  - Fixed `DosagePresenter` and `SchedulePresenter` disposal errors with lifecycle management in `home_view.dart`.
  - Removed non-constant `scrollbarTheme` from `themes.dart` to fix build errors.
  - Enhanced `schedule_form_view.dart` for proper schedule editing initialization.
  - Progressed verification checklist: confirmed data persistence, fixed dosage labels, notifications toggle, multiple schedules display, and scheduling functionality.

### Dynamic Validation Warnings (May 28, 2025, 9:22 PM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Implemented dynamic validation warnings in `dosage_form_view.dart` for dosage amounts exceeding remaining stock, with real-time error display and save button disabling.
  - Added dynamic validation warnings in `reconstitution_view.dart` for fluid amount (0.5–99 mL) and target dose, with real-time error display and save button disabling.
  - Ensured code reuse with `format_helper.dart`, `validators.dart`, and `themes.dart`, respecting folder structure (`lib/app`, `lib/core`, `lib/features`).
  - Progressed verification checklist: completed dynamic validation for dosage tracking and reconstitution.

### Dosage and Reconstitution Fixes (May 29, 2025, 10:52 AM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Fixed Dosage Form: Removed empty tablet count warning, corrected tablet quantity validation, added remaining quantity display, implemented up/down arrows, and styled `ConfirmDosageDialog` with `themes.dart`.
  - Fixed Reconstitution Form: Set IU warning threshold to 5% of syringe size, enabled target dose updates, validated IU against syringe capacity, reduced non-selected option text, and fixed crash on fluid volume change.
  - Ensured code reuse with `format_helper.dart`, `validators.dart`, `themes.dart`, and `reconstitution_calculator.dart`, respecting folder structure.
  - Progressed verification checklist: completed dosage and reconstitution validation.

### Build and Form Fixes (May 29, 2025, 10:58 AM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Fixed build errors: Added missing colors to `constants.dart`, corrected `int` to `double` in `formatNumber`, added `format_helper.dart` import in `dosage_form_fields.dart`.
  - Dosage Form: Removed empty tablet count warning, fixed tablet quantity validation, added remaining quantity display, implemented up/down arrows, styled `ConfirmDosageDialog`.
  - Reconstitution Form: Set IU warning threshold to 5% of syringe size, fixed target dose updates, validated IU against syringe capacity, reduced non-selected option text, fixed fluid volume change crash.
  - Ensured code reuse with `format_helper.dart`, `validators.dart`, `themes.dart`, and `reconstitution_calculator.dart`.
  - Progressed verification checklist: completed dosage and reconstitution form fixes.
  
### Form Fixes and Home Screen Redesign (May 29, 2025, 11:35 AM AEST)
- **Commit**: `8221e170c72b7656048de81f45a87aa655ad86f3`
- **Details**:
  - Dosage Form: Fixed ConfirmDosageDialog button positioning, restricted tablet/capsule methods to Oral/Other, added injection methods, removed duplicate dropdowns.
  - Reconstitution Form: Updated selected option display, fixed suggestion type error, resolved volume field crash.
  - Redesign home screen: Compact schedule cards with action buttons, smaller medication cards, View Calendar button.
  - Optimized code: Consolidated dialog actions, enhanced validators, centralized navigation bar.

## Recent Updates (May 2025)

- **Theming Overhaul**: Updated to a modern, award-winning design with a teal primary color (`#00C4B4`), coral accents (`#FF6F61`/`#FF8A65`), and the Inter font.
- **Home Screen**:
  - Added a top banner with the app name (placeholder logo).
  - Moved the Upcoming Doses box above the calendar.
  - Made medication cards smaller with specific info (tablets/injections), icons, and colored backgrounds.
  - Updated the calendar to show the full month view with a visible header.
  - Replaced the FAB with a contextual menu to add medications or schedules.
- **Medication Details Screen**:
  - Renamed "Stock Information" to "Information" with detailed info for tablets.
  - Updated Dosages card to show scheduling status.
  - Made dose cards smaller, added more info, and included a delete option.
  - Added a button to schedule a dose.
  - Replaced action buttons with a modern FAB menu.
  - Updated Refill to allow editable amounts.
  - Added bottom navigation bar and ensured the back button navigates to Home.
- **Add Medication Screen**:
  - Prompt for medication type first, revealing fields after selection.
  - Added a warning for injections about reconstitution and volume requirements.
  - Navigates to `MedicationDetailsView` after saving.
- **Reconstitution View**:
  - Removed "Stock: [X]" from the top.
  - Renamed "Reconstitution Fluid" to "Reconstitution Fluid Name" and added a fluid type tracker.
  - Added up/down buttons to Target Dose and Fluid Amount fields.
  - Ensured 5.0 mL syringe appears in suggestions.
  - Updated dosage options to include reference ranges within syringe IU limits.
  - Standardized confirmation dialog styling.
    Theming Overhaul : Updated to a modern, award-winning design with a teal primary color ( `#00C4B4` ), coral accents ( `#FF6F61` / `#FF8A65` ), and the Inter font.
* Home Screen :
  ...
* Consistency : Ensured all views and dialogs use `AppConstants` and `AppThemes` for styling.
* Build Fixes (May 29, 2025, 07:02 PM AEST) :
  - Commit: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`
  - Fixed `themes.dart` build error by using `AppConstants.cardColor` explicitly.
  - Corrected `pubspec.yaml` font indentation to resolve syntax error.
* Build Fixes and Enhancements (May 29, 2025, 07:10 PM AEST) :
  - Commit: `32850236ec109b8878d022ec007e733c78ef4f65`
  - Fixed syntax errors in `medication_form_view.dart` (unmatched brackets, incorrect commas).
  - Corrected syntax error in `reconstitution_view.dart` by removing erroneous `}d`.
  - Resolved `AppThemes` namespace errors in `home_view.dart`.
  - Replaced invalid `Icons.syringe` with `Icons.medical_services` in `home_view.dart`, `confirm_dosage_dialog.dart`, and `confirm_medication_dialog.dart`.
  - Fixed incorrect reference to `AppThemes.infoCardDecoration` in `medication_form_view.dart` by using `AppConstants.infoCardDecoration`.
* Build Fixes for Medication Form (May 29, 2025, 07:22 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Fixed syntax errors in `medication_form_view.dart` related to unmatched brackets, incorrect commas, and missing semicolons in the `Column` widget.
* Additional Build Fixes for Medication Form (May 29, 2025, 07:28 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Removed duplicate `TextFormField` and `ElevatedButton` widgets in `medication_form_view.dart` to fix syntax errors in the `Column` widget.
* Reapplied Build Fixes for Medication Form (May 29, 2025, 07:48 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Reapplied fix for duplicate `TextFormField` and `ElevatedButton` widgets in `medication_form_view.dart` to resolve syntax errors in the `Column` widget.
* Reapplied Build Fixes for Medication Form Syntax (May 29, 2025, 07:51 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Reapplied fix for duplicate `TextFormField` and `ElevatedButton` widgets in `medication_form_view.dart`, and corrected `Scaffold` closure syntax.
* Fixed Scaffold Closure in Medication Form (May 29, 2025, 07:55 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Fixed `Scaffold` closure syntax in `medication_form_view.dart` by adding a comma before `bottomNavigationBar` and removing an extra parenthesis.
* Added SingleChildScrollView in Medication Form (May 29, 2025, 08:08 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Added `SingleChildScrollView` between `Form` and `Column` in `medication_form_view.dart` to fix bracket mismatch and ensure proper scrolling.
* Reapplied SingleChildScrollView Fix in Medication Form (May 29, 2025, 08:25 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Reapplied the addition of `SingleChildScrollView` between `Form` and `Column` in `medication_form_view.dart` to fix bracket mismatch and ensure proper scrolling.
* Fixed Class Closure in Medication Form (May 29, 2025, 08:43 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Removed extra closing parenthesis at the end of `_MedicationFormViewState` class in `medication_form_view.dart`, replacing it with a proper closing brace to fix syntax error.
* Reapplied SingleChildScrollView Fix in Medication Form (May 29, 2025, 08:49 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Reapplied the addition of `SingleChildScrollView` between `Form` and `Column` in `medication_form_view.dart` to fix bracket mismatch and ensure proper scrolling.
* Fixed Truncated Widget and Typo in Medication Form (May 29, 2025, 09:00 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Completed the truncated `DropdownButtonFormField` widget in the dose per tablet/capsule block and fixed a typo in `_saveMedication` (changed `medicine` to `medication`) in `medication_form_view.dart` to resolve syntax errors.
* Extracted Widgets in Medication Form (May 29, 2025, 09:10 PM AEST) :
  - Commit: `<new_commit_hash>` (Run `git log -1 --pretty=%H` after committing)
  - Extracted widgets from `medication_form_view.dart` into separate files in `lib/core/widgets/` (e.g., `medication_type_dropdown.dart`, `medication_name_field.dart`, etc.) for better modularity and reusability.
  

  
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