import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/screens/home_screen.dart';
import 'package:medtrackr/screens/medication_form_screen.dart';
import 'package:medtrackr/screens/dosage_form_screen.dart';
import 'package:medtrackr/screens/schedule_form_screen.dart';
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
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppConstants.primaryColor,
              selectionColor: AppConstants.primaryColor.withOpacity(0.5),
              selectionHandleColor: AppConstants.primaryColor,
            ),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppConstants.kLightGrey, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppConstants.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppConstants.kLightGrey, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: AppConstants.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              labelStyle: TextStyle(color: Colors.grey),
            ),
          ),
          initialRoute: '/home',
          routes: {
            '/home': (context) => const HomeScreen(),
            '/medication_form': (context) => MedicationFormScreen(
                  medication:
                      ModalRoute.of(context)!.settings.arguments as Medication?,
                ),
            '/medication_details': (context) => MedicationDetailsScreen(
              medication: ModalRoute.of(context)!.settings.arguments as Medication,
            ),
            '/dosage_form': (context) {
              final args = ModalRoute.of(context)!.settings.arguments;
              if (args is Medication) {
                return DosageFormScreen(medication: args);
              } else if (args is Map<String, dynamic>) {
                return DosageFormScreen(
                  medication: args['medication'] as Medication,
                  dosage: args['dosage'] as Dosage?,
                );
              }
              return const HomeScreen(); // Fallback
            },
            '/add_schedule': (context) => ScheduleFormScreen(
                  medication: Medication(
                      id: '',
                      name: '',
                      type: MedicationType.tablet,
                      quantity: 0,
                      quantityUnit: QuantityUnit.mg,
                      remainingQuantity: 0,
                      reconstitutionVolumeUnit: '',
                      reconstitutionVolume: 0,
                      reconstitutionFluid: '',
                      notes: ''),
                ),
            '/schedule_form': (context) {
              final args = ModalRoute.of(context)?.settings.arguments;
              return ScheduleFormScreen(
                medication: args is Medication
                    ? args
                    : Medication(
                        id: '',
                        name: '',
                        type: MedicationType.tablet,
                        quantity: 0,
                        quantityUnit: QuantityUnit.mg,
                        remainingQuantity: 0,
                        reconstitutionVolumeUnit: '',
                        reconstitutionVolume: 0,
                        reconstitutionFluid: '',
                        notes: ''),
              );
            },
            '/reconstitute': (context) => ReconstitutionScreen(
                  medication:
                      ModalRoute.of(context)!.settings.arguments as Medication,
                ),
            '/calendar': (context) => const Placeholder(),
            '/history': (context) => const Placeholder(),
            '/settings': (context) => const Placeholder(),
          },
        ));
  }
}
