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
          update: (_, repo, notif, __) => MedicationPresenter(repo, notif)..loadMedications(),
        ),
        ChangeNotifierProxyProvider3<DosageRepository, MedicationPresenter, NotificationService, DosagePresenter>(
          create: (_) => DosagePresenter(
            repository: DosageRepository(DatabaseService()),
            medicationPresenter: MedicationPresenter(MedicationRepository(DatabaseService()), NotificationService()),
            notificationService: NotificationService(),
          ),
          update: (_, repo, medPresenter, notif, __) => DosagePresenter(
            repository: repo,
            medicationPresenter: medPresenter,
            notificationService: notif,
          )..loadDosages(),
        ),
        ChangeNotifierProxyProvider3<ScheduleRepository, NotificationService, DosagePresenter, SchedulePresenter>(
          create: (_) => SchedulePresenter(ScheduleRepository(DatabaseService()), NotificationService()),
          update: (_, repo, notif, dosagePresenter, __) {
            final presenter = SchedulePresenter(repo, notif);
            presenter.setDependencies(dosagePresenter.medicationPresenter.medications, dosagePresenter.dosages);
            presenter.loadSchedules();
            return presenter;
          },
        ),
      ],
      child: MaterialApp(
        title: 'MedTrackr',
        theme: AppThemes.themeData,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}