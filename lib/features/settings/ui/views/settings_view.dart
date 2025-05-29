// lib/features/settings/ui/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/core/services/theme_provider.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;

  Future<void> _toggleNotifications(bool enabled) async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
    final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
    final schedulePresenter = Provider.of<SchedulePresenter>(context, listen: false);
    try {
      if (!enabled) {
        await notificationService.cancelAllNotifications();
      } else {
        final schedules = schedulePresenter.upcomingDoses
            .where((dose) => dose['schedule'] != null)
            .map((dose) => dose['schedule'] as Schedule)
            .toList();
        await notificationService.rescheduleAllNotifications(
          schedules,
          medicationPresenter.medications,
          dosagePresenter.dosages,
        );
      }
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: AppConstants.cardTitleStyle(isDark).copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Enable Notifications', style: TextStyle(fontFamily: 'Inter')),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Dark Mode', style: TextStyle(fontFamily: 'Inter')),
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: AppConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == 0) navigationService.replaceWith('/home');
            if (index == 1) navigationService.navigateTo('/calendar');
            if (index == 2) navigationService.navigateTo('/history');
            if (index == 3) navigationService.replaceWith('/settings');
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