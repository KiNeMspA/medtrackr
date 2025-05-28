// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/routes.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/database_service.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/medication/data/repos/medication_repository.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/dosage/data/repos/dosage_repository.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/data/repos/schedule_repository.dart';

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
        ChangeNotifierProxyProvider2<MedicationRepository, NotificationService, MedicationPresenter>(
          create: (_) => MedicationPresenter(MedicationRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, provider) =>
          MedicationPresenter(repo, notif).._medications = provider?._medications ?? [],
        ),
        ChangeNotifierProxyProvider3<DosageRepository, MedicationPresenter, NotificationService, DosagePresenter>(
          create: (_) => DosagePresenter(
              DosageRepository(DatabaseService()),
              MedicationPresenter(MedicationRepository(DatabaseService()), NotificationService()),
              NotificationService()),
          update: (_, repo, medPresenter, notif, provider) =>
          DosagePresenter(repo, medPresenter, notif).._dosages = provider?._dosages ?? [],
        ),
        ChangeNotifierProxyProvider2<ScheduleRepository, NotificationService, SchedulePresenter>(
          create: (_) => SchedulePresenter(ScheduleRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, provider) => SchedulePresenter(repo, notif)
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