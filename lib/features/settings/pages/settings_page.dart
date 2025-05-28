// In lib/features/schedule/pages/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/data/data_sources/local/data_provider.dart';
import 'package:medtrackr/core/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  Future<void> _toggleNotifications(bool enabled) async {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    if (!enabled) {
      await notificationService.cancelAllNotifications();
    } else {
      await notificationService.rescheduleAllNotifications(
        dataProvider.schedules,
        dataProvider.medications,
        dataProvider.dosages,
      );
    }
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFFFFC107),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: const Text('Enable Notifications'),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: _toggleNotifications,
                  activeColor: const Color(0xFFFFC107),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  activeColor: const Color(0xFFFFC107),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}