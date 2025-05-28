// lib/features/history/ui/views/history_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final takenDosages =
        dosagePresenter.dosages.where((d) => d.takenTime != null).toList();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: takenDosages.isEmpty
          ? const Center(
              child: Text('No dosage history.', style: TextStyle(fontSize: 24)))
          : ListView.builder(
              itemCount: takenDosages.length,
              itemBuilder: (context, index) {
                final dosage = takenDosages[index];
                return ListTile(
                  title: Text(dosage.name),
                  subtitle: Text('Taken: ${dosage.takenTime!.toString()}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/medication_form'),
        backgroundColor: AppConstants.primaryColor,
        tooltip: 'Add a new medication',
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 2,
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
