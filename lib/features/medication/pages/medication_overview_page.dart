// In lib/features/medication/pages/medication_overview_page.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/data/data_sources/local/data_provider.dart';
import 'package:medtrackr/core/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/core/widgets/buttons/animated_action_button.dart';
import 'package:medtrackr/core/widgets/cards/medication_card.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  Future<void> _deleteMedication(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemes.warningBackgroundColor,
        title: Text('Delete Medication', style: AppThemes.warningTitleStyle),
        content: Text(
          'Are you sure you want to delete ${medication.name}?',
          style: AppThemes.warningContentTextStyle,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppConstants.dialogButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      await dataProvider.deleteMedicationAsync(medication.id);
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _showAddDosageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.informationCardDecoration,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Dosage', style: AppThemes.informationTitleStyle),
              const SizedBox(height: 16),
              const Text(
                'Please set a volume (mL) or reconstitute the medication before adding a dosage.',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/medication_form',
                  arguments: medication);
            },
            child: const Text('Edit Volume'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reconstitute',
                  arguments: medication);
            },
            style: AppConstants.dialogButtonStyle,
            child: const Text('Reconstitute'),
          ),
        ],
      ),
    );
  }

  void _showNoDosageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.informationCardDecoration,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No Dosage Available', style: AppThemes.informationTitleStyle),
              const SizedBox(height: 16),
              const Text(
                'You must create at least one dosage before adding a schedule.',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/dosage_form',
                  arguments: medication);
            },
            style: AppConstants.dialogButtonStyle,
            child: const Text('Add Dosage'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final dosages = dataProvider.getDosagesForMedication(medication.id);
    final canAddDosage = medication.type != MedicationType.injection ||
        medication.quantityUnit == QuantityUnit.mL ||
        medication.reconstitutionVolume > 0;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(medication.name),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight - 60,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Medication Overview',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                MedicationCard(
                  medication: medication,
                ),
                const SizedBox(height: 16),
                Text(
                  'Dosages',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
                ),
                dosages.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No dosages added.',
                    style: AppConstants.secondaryTextStyle,
                  ),
                )
                    : Column(
                  children: dosages.map((dosage) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(dosage.name, style: AppConstants.cardTitleStyle),
                          subtitle: Text(
                              '${formatNumber(dosage.totalDose)} ${dosage.doseUnit} (${dosage.method.displayName})',
                              style: AppConstants.cardBodyStyle),
                          onTap: () => Navigator.pushNamed(context, '/dosage_form',
                              arguments: {'medication': medication, 'dosage': dosage}),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: AnimatedActionButton(
                        label: 'Add Dosage',
                        icon: Icons.add_circle,
                        onPressed: () => Navigator.pushNamed(context, '/dosage_form', arguments: medication),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedActionButton(
                        label: 'Add Schedule',
                        icon: Icons.schedule,
                        onPressed: () => dosages.isEmpty
                            ? _showNoDosageDialog(context)
                            : Navigator.pushNamed(context, '/add_schedule', arguments: medication),
                      ),
                    ),
                    if (medication.type == MedicationType.injection) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: AnimatedActionButton(
                          label: 'Reconstitute',
                          icon: Icons.science,
                          onPressed: () => Navigator.pushNamed(context, '/reconstitute', arguments: medication),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: canAddDosage
            ? () => Navigator.pushNamed(context, '/dosage_form', arguments: medication)
            : () => _showAddDosageDialog(context),
        backgroundColor: AppConstants.primaryColor,
        tooltip: canAddDosage ? 'Add a new dosage' : 'Set volume or reconstitute to add dosage',
        child: Icon(canAddDosage ? Icons.add : Icons.info, color: Colors.black),
      ),
      bottomSheet: Container(
        color: AppConstants.backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/medication_form', arguments: medication),
                style: AppConstants.actionButtonStyle,
                child: const Text('Edit'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _deleteMedication(context),
                style: AppConstants.actionButtonStyle.copyWith(
                  backgroundColor: WidgetStateProperty.all(Colors.redAccent),
                ),
                child: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 0,
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
