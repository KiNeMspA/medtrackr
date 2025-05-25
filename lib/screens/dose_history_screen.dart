import 'package:flutter/material.dart';
import 'package:medtrackr/models/dddosage_schedule.dart';
import 'package:intl/intl.dart';

class DoseHistoryScreen extends StatelessWidget {
  final DosageSchedule schedule;

  const DoseHistoryScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dose History'),
      ),
      body: schedule.takenDoses.isEmpty
          ? Center(
              child: Text(
                'No doses taken yet.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: schedule.takenDoses.length,
              itemBuilder: (context, index) {
                final doseTime = schedule.takenDoses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      'Dose Taken',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(doseTime),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
