import 'package:flutter/material.dart';
import 'package:medtrackr/features/medication/ui/views/medication_form_view.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/core/services/navigation_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return MultiProvider(
      providers: [
        Provider<ThemeProvider>(create: (_) => ThemeProvider()),
        Provider<NavigationService>.value(value: navigationService),
      ],
      child: MaterialApp(
        title: 'MedTrackr',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        navigatorKey: navigationService.navigatorKey,
        initialRoute: '/',
        routes: {
          '/': (context) => const MedicationFormView(),
          '/home': (context) => const MedicationFormView(),
          '/calendar': (context) => const MedicationFormView(),
          '/history': (context) => const MedicationFormView(),
          '/settings': (context) => const MedicationFormView(),
          '/medication_details': (context) => const MedicationFormView(),
        },
      ),
    );
  }
}