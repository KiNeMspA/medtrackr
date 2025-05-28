// lib/features/calendar/ui/views/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: const Center(child: Text('Calendar Screen', style: TextStyle(fontSize: 24))),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/medication_form'),
        backgroundColor: AppConstants.primaryColor,
        tooltip: 'Add a new medication',
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/calendar');
          if (index == 2) Navigator.pushReplacementNamed(context, '/history');
          if (index == 3) Navigator.pushReplacementNamed(context, '/settings');
        },
      ),
    );
  }
}