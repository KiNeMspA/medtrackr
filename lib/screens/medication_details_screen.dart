// In lib/screens/medication_details_screen.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/constants/constants.dart';
import 'package:medtrackr/constants/themes.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/utils/helpers/format_helper.dart';
import 'package:medtrackr/models/enums/enums.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/providers/data_provider.dart';
import 'package:medtrackr/widgets/navigation/app_bottom_navigation_bar.dart';

class MedicationDetailsScreen extends StatelessWidget {
  final Medication medication;

  const MedicationDetailsScreen({super.key, required this.medication});

  Future<void> _deleteMedication(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Themes.warningBackgroundColor,
        title: Text('Delete Medication', style: Themes.warningTitleStyle),
        content: Text(
          'Are you sure you want to delete ${medication.name}?',
          style: Themes.warningContentTextStyle,
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
        backgroundColor: AppConstants.backgroundColor,
        title: const Text('Add Dosage'),
        content: const Text(
          'Please set a volume (mL) or reconstitute the medication before adding a dosage.',
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
        backgroundColor: AppConstants.backgroundColor,
        title: const Text('No Dosage Available'),
        content: const Text(
          'You must create at least one dosage before adding a schedule.',
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
    String _getSelectedUnit() {
      // Assuming quantityUnit reflects the selected unit for tablets/capsules
      return medication.quantityUnit == QuantityUnit.tablets
          ? 'mg'
          : medication.quantityUnit.displayName;
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.pushNamed(context, '/medication_form',
                arguments: medication),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteMedication(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                kToolbarHeight -
                kBottomNavigationBarHeight,
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
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/medication_form',
                      arguments: medication),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${medication.name}',
                              style: AppConstants.cardBodyStyle),
                          Text('Type: ${medication.type.displayName}',
                              style: AppConstants.cardBodyStyle),
                          Text(
                              'Quantity: ${formatNumber(medication.quantity)} ${medication.quantityUnit.displayName}',
                              style: AppConstants.cardBodyStyle),
                          if (medication.dosePerTablet != null &&
                              medication.type == MedicationType.tablet)
                            Text(
                                'Dose per Tablet: ${formatNumber(medication.dosePerTablet!)} ${medication.dosePerTabletUnit?.displayName ?? 'mg'}',
                                style: AppConstants.cardBodyStyle),
                          if (medication.dosePerCapsule != null &&
                              medication.type == MedicationType.capsule)
                            Text(
                                'Dose per Capsule: ${formatNumber(medication.dosePerCapsule!)} ${medication.dosePerCapsuleUnit?.displayName ?? 'mg'}',
                                style: AppConstants.cardBodyStyle),
                          if (medication.reconstitutionVolume > 0)
                            Text(
                                'Reconstituted: ${formatNumber(medication.reconstitutionVolume)} ${medication.reconstitutionVolumeUnit} ${medication.reconstitutionFluid}',
                                style: AppConstants.cardBodyStyle),
                          Text(
                              'Notes: ${medication.notes.isNotEmpty ? medication.notes : 'None'}',
                              style: AppConstants.cardBodyStyle),
                        ],
                      ),
                    ),
                  ),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(dosage.name,
                                    style: AppConstants.cardTitleStyle),
                                subtitle: Text(
                                    '${formatNumber(dosage.totalDose)} ${dosage.doseUnit} (${dosage.method.displayName})',
                                    style: AppConstants.cardBodyStyle),
                                onTap: () => Navigator.pushNamed(
                                    context, '/dosage_form', arguments: {
                                  'medication': medication,
                                  'dosage': dosage
                                }),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/dosage_form',
                              arguments: medication),
                          style: AppConstants.actionButtonStyle,
                          child: const Text('Add Dosage'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: dosages.isEmpty
                              ? () => _showNoDosageDialog(context)
                              : () => Navigator.pushNamed(
                                  context, '/add_schedule',
                                  arguments: medication),
                          style: AppConstants.actionButtonStyle,
                          child: const Text('Add Schedule'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(
                              context, '/medication_form',
                              arguments: medication),
                          style: AppConstants.actionButtonStyle,
                          child: const Text('Refill'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: canAddDosage
          ? FloatingActionButton(
              onPressed: () => Navigator.pushNamed(context, '/dosage_form',
                  arguments: medication),
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : FloatingActionButton(
              onPressed: () => _showAddDosageDialog(context),
              backgroundColor: AppConstants.primaryColor,
              child: const Icon(Icons.info, color: Colors.black),
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
