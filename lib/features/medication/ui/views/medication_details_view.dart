// lib/features/medication/ui/views/medication_details_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/widgets/dosage_card.dart';
import 'package:medtrackr/core/widgets/dosage_edit_dialog.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class MedicationDetailsView extends StatefulWidget {
  final Medication medication;

  const MedicationDetailsView({super.key, required this.medication});

  @override
  _MedicationDetailsViewState createState() => _MedicationDetailsViewState();
}

class _MedicationDetailsViewState extends State<MedicationDetailsView> {
  bool _showActions = false;
  final _refillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refillController.text = widget.medication.quantity.toString();
  }

  @override
  void dispose() {
    _refillController.dispose();
    super.dispose();
  }

  Future<void> _deleteMedication(BuildContext context) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.dialogCardDecoration(isDark),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete Medication', style: AppThemes.dialogTitleStyle(isDark)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete ${widget.medication.name}?',
                style: AppThemes.dialogContentStyle(isDark),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor(isDark), fontFamily: 'Inter')),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: AppConstants.deleteButtonStyle(),
                    child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
      await medicationPresenter.deleteMedication(widget.medication.id);
      if (context.mounted) {
        navigationService.replaceWith('/home');
      }
    }
  }

  Future<void> _refillMedication(BuildContext context) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.dialogCardDecoration(isDark),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Refill Medication', style: AppThemes.dialogTitleStyle(isDark)),
              const SizedBox(height: 12),
              Text(
                'Enter the amount to refill ${widget.medication.name}:',
                style: AppThemes.dialogContentStyle(isDark),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _refillController,
                decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                  labelText: 'Refill Amount',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor(isDark), fontFamily: 'Inter')),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: AppConstants.dialogButtonStyle(),
                    child: const Text('Refill', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
      final newAmount = double.tryParse(_refillController.text) ?? widget.medication.quantity;
      await medicationPresenter.updateMedication(
        widget.medication.id,
        widget.medication.copyWith(remainingQuantity: newAmount),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.medication.name} refilled to ${formatNumber(newAmount)}')),
        );
      }
    }
  }

  Future<void> _deleteDosage(BuildContext context, String dosageId) async {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.cardColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: AppThemes.dialogCardDecoration(isDark),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete Dosage', style: AppThemes.dialogTitleStyle(isDark)),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete this dosage?',
                style: AppThemes.dialogContentStyle(isDark),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancel', style: TextStyle(color: AppConstants.accentColor(isDark), fontFamily: 'Inter')),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: AppConstants.deleteButtonStyle(),
                    child: const Text('Delete', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
      await dosagePresenter.deleteDosage(dosageId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dosage deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final dosages = dosagePresenter.getDosagesForMedication(widget.medication.id);
    final schedules = schedulePresenter.upcomingDoses
        .where((dose) => dose['schedule'] != null && dose['schedule'].medicationId == widget.medication.id)
        .map((dose) => dose['schedule'] as Schedule)
        .toSet()
        .toList();
    final scheduledDosages = dosages.where((d) => schedules.any((s) => s.dosageId == d.id)).length;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(widget.medication.name, style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navigationService.replaceWith('/home'), // Always go to Home
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Information Section
                  Container(
                    decoration: AppThemes.stockCardDecoration(isDark),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Information',
                          style: AppConstants.stockTitleStyle(isDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.medication.type == MedicationType.tablet || widget.medication.type == MedicationType.capsule
                              ? '${formatNumber(widget.medication.remainingQuantity)}/${formatNumber(widget.medication.quantity)} tablets remaining'
                              : '${formatNumber(widget.medication.remainingQuantity)}/${formatNumber(widget.medication.quantity)} ${widget.medication.quantityUnit.displayName}',
                          style: AppConstants.stockSubtitleStyle(isDark),
                        ),
                        if (widget.medication.type == MedicationType.tablet || widget.medication.type == MedicationType.capsule) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Dose per ${widget.medication.type == MedicationType.tablet ? "tablet" : "capsule"}: ${formatNumber(widget.medication.dosePerTablet ?? widget.medication.dosePerCapsule ?? 0)} ${widget.medication.dosePerTabletUnit?.displayName ?? widget.medication.dosePerCapsuleUnit?.displayName ?? ''}',
                            style: AppConstants.stockSubtitleStyle(isDark),
                          ),
                        ],
                        if (widget.medication.reconstitutionVolume > 0)
                          Text(
                            'Reconstituted: ${formatNumber(widget.medication.reconstitutionVolume)} ${widget.medication.reconstitutionVolumeUnit}',
                            style: AppConstants.stockSubtitleStyle(isDark),
                          ),
                        if (widget.medication.isLowStock) ...[
                          const SizedBox(height: 8),
                          Text(
                            '⚠️ Low Stock Warning',
                            style: AppThemes.reconstitutionErrorStyle(isDark),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Dosages Section
                  Container(
                    decoration: AppThemes.stockCardDecoration(isDark),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dosages (${dosages.length})',
                          style: AppConstants.stockTitleStyle(isDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have set up ${dosages.length} dosage${dosages.length == 1 ? '' : 's'}. $scheduledDosages of them are currently scheduled.',
                          style: AppConstants.stockSubtitleStyle(isDark),
                        ),
                        const SizedBox(height: 8),
                        if (dosages.isEmpty)
                          Text(
                            'No dosages added.',
                            style: AppConstants.stockSubtitleStyle(isDark),
                          )
                        else
                          ...dosages.map((dosage) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: GestureDetector(
                              onTap: () => showDialog(
                                context: context,
                                builder: (context) => DosageEditDialog(
                                  dosage: dosage,
                                  medication: widget.medication,
                                  onSave: (updatedDosage) async {
                                    await dosagePresenter.updateDosage(dosage.id, updatedDosage);
                                  },
                                  isInjection: widget.medication.type == MedicationType.injection,
                                  isTabletOrCapsule: widget.medication.type == MedicationType.tablet || widget.medication.type == MedicationType.capsule,
                                  isReconstituted: widget.medication.reconstitutionVolume > 0,
                                  isDark: isDark,
                                ),
                              ),
                              child: Container(
                                decoration: AppThemes.compactMedicationCardDecoration(isDark),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            dosage.name,
                                            style: AppConstants.medicationCardTitleStyle(isDark),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Method: ${dosage.method.displayName}',
                                            style: AppConstants.medicationCardSubtitleStyle(isDark),
                                          ),
                                          Text(
                                            'Total Dose: ${formatNumber(dosage.totalDose)} ${dosage.doseUnit}',
                                            style: AppConstants.medicationCardSubtitleStyle(isDark),
                                          ),
                                          if (dosage.insulinUnits > 0)
                                            Text(
                                              'IU: ${formatNumber(dosage.insulinUnits)}',
                                              style: AppConstants.medicationCardSubtitleStyle(isDark),
                                            ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: AppConstants.errorColor, size: 20),
                                      onPressed: () => _deleteDosage(context, dosage.id),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Schedules Section
                  Container(
                    decoration: AppThemes.stockCardDecoration(isDark),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schedules (${schedules.length})',
                          style: AppConstants.stockTitleStyle(isDark),
                        ),
                        const SizedBox(height: 8),
                        if (schedules.isEmpty)
                          Text(
                            'No schedules added.',
                            style: AppConstants.stockSubtitleStyle(isDark),
                          )
                        else
                          ...schedules.map((schedule) => ListTile(
                            title: Text(schedule.dosageName, style: AppConstants.stockSubtitleStyle(isDark)),
                            subtitle: Text(
                              '${schedule.time.format(context)} - ${formatNumber(schedule.dosageAmount)} ${schedule.dosageUnit}',
                              style: AppConstants.stockSubtitleStyle(isDark),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit, color: AppConstants.primaryColor),
                              onPressed: () => navigationService.navigateTo(
                                '/schedule_form',
                                arguments: {'medication': widget.medication, 'schedule': schedule},
                              ),
                            ),
                          )),
                        const SizedBox(height: 8),
                        Center(
                          child: ElevatedButton(
                            onPressed: () => navigationService.navigateTo(
                              '/schedule_form',
                              arguments: {'medication': widget.medication},
                            ),
                            style: AppConstants.homeActionButtonStyle(),
                            child: const Text('Add Schedule', style: TextStyle(fontFamily: 'Inter')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
          // Floating Action Menu for Actions
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              children: [
                if (_showActions) ...[
                  _buildActionButton(
                    context,
                    label: 'Edit',
                    icon: Icons.edit,
                    onTap: () {
                      setState(() => _showActions = false);
                      navigationService.navigateTo('/medication_form', arguments: widget.medication);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    context,
                    label: 'Refill',
                    icon: Icons.refresh,
                    onTap: () {
                      setState(() => _showActions = false);
                      _refillMedication(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    context,
                    label: 'Add Dose',
                    icon: Icons.add,
                    onTap: () {
                      setState(() => _showActions = false);
                      navigationService.navigateTo('/dosage_form', arguments: widget.medication);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    context,
                    label: 'Delete',
                    icon: Icons.delete,
                    onTap: () {
                      setState(() => _showActions = false);
                      _deleteMedication(context);
                    },
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(height: 8),
                ],
                FloatingActionButton(
                  onPressed: () {
                    setState(() => _showActions = !_showActions);
                  },
                  backgroundColor: AppConstants.primaryColor,
                  child: Icon(_showActions ? Icons.close : Icons.more_horiz),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == 0) navigationService.replaceWith('/home');
            if (index == 1) navigationService.navigateTo('/calendar');
            if (index == 2) navigationService.navigateTo('/history');
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

  Widget _buildActionButton(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap, Color? color}) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppConstants.cardColor(isDark),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppConstants.cardBodyStyle(isDark)),
          ],
        ),
      ),
    );
  }
}