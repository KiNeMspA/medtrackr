// In lib/app/rout.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/dosage/pages/dosage_form_page.dart';
import 'package:medtrackr/features/home/pages/home_page.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/medication/pages/medication_overview_page.dart';
import 'package:medtrackr/features/medication/pages/medication_form_page.dart';
import 'package:medtrackr/features/medication/pages/reconstitution_page.dart';
import 'package:medtrackr/features/schedule/pages/schedule_form_page.dart';

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
        return MaterialPageRoute(builder: (_) => const HomePage());
      case medicationForm:
        final medication = settings.arguments as Medication?;
        return MaterialPageRoute(
            builder: (_) => MedicationFormPage(medication: medication));
      case medicationDetails:
        final medication = settings.arguments as Medication;
        return MaterialPageRoute(
            builder: (_) => MedicationDetailsPage(medication: medication));
      case dosageForm:
        if (settings.arguments is Medication) {
          final medication = settings.arguments as Medication;
          return MaterialPageRoute(
              builder: (_) => DosageFormPage(medication: medication));
        } else if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (_) => DosageFormPage(
                medication: args['medication'] as Medication,
                dosage: args['dosage'] as Dosage?,
              ));
        }
        return MaterialPageRoute(builder: (_) => const HomePage());
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
            builder: (_) => ScheduleFormPage(medication: medication));
      case reconstitute:
        final medication = settings.arguments as Medication;
        return MaterialPageRoute(
            builder: (_) => ReconstitutionPage(medication: medication));
      case calendar:
      case history:
      case settings:
        return MaterialPageRoute(builder: (_) => const Placeholder());
      default:
        return MaterialPageRoute(
            builder: (_) =>
            const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}