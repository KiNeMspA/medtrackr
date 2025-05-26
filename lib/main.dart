import 'package:flutter/material.dart';
import 'package:medtrackr/screens/home_screen.dart';
import 'package:medtrackr/screens/medication_form_screen.dart';
import 'package:medtrackr/screens/history_screen.dart';
import 'package:medtrackr/screens/settings_screen.dart';
import 'package:medtrackr/screens/add_dosage_screen.dart';
import 'package:medtrackr/screens/add_schedule_screen.dart';
import 'package:medtrackr/screens/medication_details_screen.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final notificationService = NotificationService();
  await notificationService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataProvider(notificationService: notificationService)),
        Provider(create: (context) => notificationService),
      ],
      child: const MedTrackrApp(),
    ),
  );
}

class MedTrackrApp extends StatelessWidget {
  const MedTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFFFFC107),
        scaffoldBackgroundColor: Colors.grey[200],
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              fontFamily: 'Roboto', fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontFamily: 'Roboto', color: Colors.grey),
          bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 18, color: Colors.black),
          titleLarge: TextStyle(
              fontFamily: 'Roboto', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
      routes: {
        '/medication_form': (context) => MedicationFormScreen(
          medication: ModalRoute.of(context)!.settings.arguments as Medication?,
        ),
        '/add_dosage': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return AddDosageScreen(
            medication: args['medication'] as Medication,
            targetDoseMcg: args['targetDoseMcg'] as double?,
            selectedIU: args['selectedIU'] as double?,
          );
        },
        '/add_schedule': (context) => const AddScheduleScreen(),
        '/medication_details': (context) => MedicationDetailsScreen(
          medication: ModalRoute.of(context)!.settings.arguments as Medication,
        ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    MedicationFormScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFFFC107),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
    );
  }
}