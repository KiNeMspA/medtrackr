// lib/history_screen.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/models/enums/enums.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('History Screen', style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}