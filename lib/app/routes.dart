// lib/app/routes.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/dosage/ui/views/dosage_form_view.dart';
import 'package:medtrackr/features/home/ui/views/home_view.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/ui/views/medication_details_view.dart';
import 'package:medtrackr/features/medication/ui/views/medication_form_view.dart';
import 'package:medtrackr/features/medication/ui/views/reconstitution_view.dart';
import 'package:medtrackr/features/schedule/ui/views/schedule_form_view.dart';
import 'package:medtrackr/features/calendar/ui/views/calendar_view.dart';
import 'package:medtrackr/features/history/ui/views/history_view.dart';
import 'package:medtrackr/features/settings/ui/views/settings_view.dart';

class AppRoutes {
  static const String home = '/home';
  static const String medicationForm = '/medication_form';
  static const String medicationDetails = '/medication_details';
  static const String dosageForm = '/dosage_form';
  static const String scheduleForm = '/schedule_form';
  static const String addSchedule = '/add_schedule';
  static const String reconstitute = '/reconstitute';
  static const String calendar = '/calendar';
  static const String history = '/history';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case medicationForm:
        final medication = settings.arguments as Medication?;
        return MaterialPageRoute(
            builder: (_) => MedicationFormView(medication: medication));
      case medicationDetails:
        final medication = settings.arguments as Medication;
        return MaterialPageRoute(
            builder: (_) => MedicationDetailsView(medication: medication));
      case dosageForm:
        if (settings.arguments is Medication) {
          final medication = settings.arguments as Medication;
          return MaterialPageRoute(
              builder: (_) => DosageFormView(medication: medication));
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (_) => DosageFormView(
                medication: args['medication'] as Medication,
                dosage: args['dosage'] as Dosage?,
              ));
        }
        return MaterialPageRoute(builder: (_) => const HomeView());
      case scheduleForm:
      case addSchedule:
        final medication = settings.arguments as Medication? ??
            Medication(
              id: '',
              name: '',
              type: MedicationType.tablet,
              quantity: 0,
              quantityUnit: QuantityUnit.mg,
              remainingQuantity: 0,
              reconstitutionVolumeUnit: '',
              reconstitutionVolume: 0,
              reconstitutionFluid: '',
              notes: '',
            );
        return MaterialPageRoute(
            builder: (_) => ScheduleFormView(medication: medication));
      case reconstitute:
        final medication = settings.arguments as Medication;
        return MaterialPageRoute(
            builder: (_) => ReconstitutionView(medication: medication));
      case calendar:
        return MaterialPageRoute(builder: (_) => const CalendarView());
      case history:
        return MaterialPageRoute(builder: (_) => const HistoryView());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      default:
        return MaterialPageRoute(
            builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}