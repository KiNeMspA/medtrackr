// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/routes.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/database_service.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/medication/data/repos/medication_repository.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/dosage/data/repos/dosage_repository.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/data/repos/schedule_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();
    return MultiProvider(
      providers: [
        Provider<NavigationService>.value(value: navigationService), // Ensure single instance
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        Provider<MedicationRepository>(create: (_) => MedicationRepository(DatabaseService())),
        Provider<DosageRepository>(create: (_) => DosageRepository(DatabaseService())),
        Provider<ScheduleRepository>(create: (_) => ScheduleRepository(DatabaseService())),
        ChangeNotifierProxyProvider2<MedicationRepository, NotificationService, MedicationPresenter>(
          create: (_) => MedicationPresenter(MedicationRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, __) => MedicationPresenter(repo, notif)..loadMedications(),
        ),
        ChangeNotifierProxyProvider2<MedicationPresenter, NotificationService, DosagePresenter>(
          create: (_) => DosagePresenter(
            repository: DosageRepository(DatabaseService()),
            medicationPresenter: MedicationPresenter(MedicationRepository(DatabaseService()), NotificationService()),
            notificationService: NotificationService(),
          ),
          update: (_, medPresenter, notif, __) => DosagePresenter(
            repository: DosageRepository(DatabaseService()),
            medicationPresenter: medPresenter,
            notificationService: notif,
          )..loadDosages(),
        ),
        ChangeNotifierProxyProvider2<ScheduleRepository, NotificationService, SchedulePresenter>(
          create: (_) => SchedulePresenter(ScheduleRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, __) => SchedulePresenter(repo, notif)..loadSchedules(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => MaterialApp(
          title: 'MedTrackr',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.generateRoute,
          navigatorKey: navigationService.navigatorKey, // Ensure navigatorKey is attached
        ),
      ),
    );
  }
}