import 'package:flutter/material.dart';
import 'package:medtrackr/screens/home_screen.dart';

void main() {
  runApp(const MedTrackrApp());
}

class MedTrackrApp extends StatelessWidget {
  const MedTrackrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MedTrackr',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}