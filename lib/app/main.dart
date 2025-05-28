// In lib/app/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/routes.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/database_service.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/features/medication/providers/medication_provider.dart';
import 'package:medtrackr/features/medication/repositories/medication_repository.dart';
import 'package:medtrackr/features/dosage/providers/dosage_provider.dart';
import 'package:medtrackr/features/dosage/repositories/dosage_repository.dart';
import 'package:medtrackr/features/schedule/providers/schedule_provider.dart';
import 'package:medtrackr/features/schedule/repositories/schedule_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<NotificationService>(create: (_) => NotificationService()),
        ProxyProvider<DatabaseService, MedicationRepository>(
          update: (_, db, __) => MedicationRepository(db),
        ),
        ProxyProvider<DatabaseService, DosageRepository>(
          update: (_, db, __) => DosageRepository(db),
        ),
        ProxyProvider<DatabaseService, ScheduleRepository>(
          update: (_, db, __) => ScheduleRepository(db),
        ),
        ChangeNotifierProxyProvider2<MedicationRepository, NotificationService, MedicationProvider>(
          create: (_) => MedicationProvider(
              MedicationRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, provider) =>
          MedicationProvider(repo, notif).._medications = provider?._medications ?? [],
        ),
        ChangeNotifierProxyProvider3<DosageRepository, MedicationProvider, NotificationService, DosageProvider>(
          create: (_) => DosageProvider(
              DosageRepository(DatabaseService()),
              MedicationProvider(
                  MedicationRepository(DatabaseService()), NotificationService()),
              NotificationService()),
          update: (_, repo, medProvider, notif, provider) =>
          DosageProvider(repo, medProvider, notif)
            .._dosages = provider?._dosages ?? [],
        ),
        ChangeNotifierProxyProvider2<ScheduleRepository, NotificationService, ScheduleProvider>(
          create: (_) => ScheduleProvider(
              ScheduleRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, provider) => ScheduleProvider(repo, notif)
            .._schedules = provider?._schedules ?? []
            .._dosages = provider?._dosages ?? []
            .._medications = provider?._medications ?? [],
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppThemes.themeData,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}