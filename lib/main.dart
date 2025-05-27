import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/screens/home_screen.dart';
import 'package:medtrackr/screens/medication_form_screen.dart';
import 'package:medtrackr/screens/add_dosage_screen.dart';
import 'package:medtrackr/screens/add_schedule_screen.dart';
import 'package:medtrackr/screens/medication_details_screen.dart';
import 'package:medtrackr/screens/reconstitution_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DataProvider(),
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[200],
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppConstants.kLightGrey, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppConstants.kLightGrey, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppConstants.primaryColor, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            labelStyle: TextStyle(color: Colors.grey[600]),
            suffixStyle: TextStyle(color: Colors.grey[600]),
          ),
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => const HomeScreen(),
          '/medication_form': (context) => MedicationFormScreen(
            medication: ModalRoute.of(context)!.settings.arguments as Medication?,
          ),
          '/add_dosage': (context) => AddDosageScreen(
            medication: (ModalRoute.of(context)!.settings.arguments as Map)['medication'] as Medication,
          ),
          '/add_schedule': (context) => const AddScheduleScreen(),
          '/medication_details': (context) => MedicationDetailsScreen(
            medication: ModalRoute.of(context)!.settings.arguments as Medication,
          ),
          '/reconstitute': (context) => ReconstitutionScreen(
            medication: ModalRoute.of(context)!.settings.arguments as Medication,
          ),
          '/calendar': (context) => const Placeholder(),
          '/history': (context) => const Placeholder(),
          '/settings': (context) => const Placeholder(),
        },
      )
    );
  }
}