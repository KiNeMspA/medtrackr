// lib/features/history/ui/views/history_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/core/services/theme_provider.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final takenDosages = dosagePresenter.dosages.where((d) => d.takenTime != null).toList()
      ..sort((a, b) => b.takenTime!.compareTo(a.takenTime!)); // Sort by most recent

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: const Text('History', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: takenDosages.isEmpty
          ? Center(
        child: Text(
          'No dosage history.',
          style: AppConstants.cardTitleStyle(isDark).copyWith(fontSize: 24),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: takenDosages.length,
        itemBuilder: (context, index) {
          final dosage = takenDosages[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: ListTile(
              title: Text(dosage.name, style: AppConstants.cardTitleStyle(isDark)),
              subtitle: Text('Taken: ${formatDateTime(dosage.takenTime!)}', style: AppConstants.cardBodyStyle(isDark)),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == 0) navigationService.replaceWith('/home');
            if (index == 1) navigationService.navigateTo('/calendar');
            if (index == 2) navigationService.replaceWith('/history');
            if (index == 3) navigationService.navigateTo('/settings');
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        backgroundColor: isDark ? AppConstants.cardColorDark : Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: isDark ? AppConstants.textSecondaryDark : AppConstants.textSecondaryLight,
      ),
    );
  }
}