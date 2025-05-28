// lib/features/settings/ui/views/settings_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/core/services/notification_service.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

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
        print('Notifications disabled');
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
        print('Notifications enabled and rescheduled');
      }
      setState(() {
        _notificationsEnabled = enabled;
      });
    } catch (e) {
      print('Error toggling notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling notifications: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Ensure pop
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Enable Notifications'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: AppConstants.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: false,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dark Mode coming soon!')),
                    );
                  },
                  activeColor: AppConstants.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
