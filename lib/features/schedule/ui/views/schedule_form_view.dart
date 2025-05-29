// lib/features/schedule/ui/views/schedule_form_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/utils/validators.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/core/widgets/confirm_schedule_dialog.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';

class ScheduleFormView extends StatefulWidget {
  final Medication? medication;
  final Schedule? schedule;

  const ScheduleFormView({super.key, this.medication, this.schedule});

  @override
  _ScheduleFormViewState createState() => _ScheduleFormViewState();
}

class _ScheduleFormViewState extends State<ScheduleFormView> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay _time = TimeOfDay.now();
  FrequencyType _frequency = FrequencyType.daily;
  String? _selectedDosageId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (widget.medication == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigationService.replaceWith('/home');
      });
      return;
    }
    if (widget.schedule != null) {
      _time = widget.schedule!.time;
      _frequency = widget.schedule!.frequencyType;
      _selectedDosageId = widget.schedule!.dosageId;
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked != _time) {
      setState(() => _time = picked);
    }
  }

  Future<void> _saveSchedule(BuildContext context) async {
    if (!_formKey.currentState!.validate() || _selectedDosageId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a dosage')));
      return;
    }

    setState(() => _isSaving = true);
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
    final dosage = dosagePresenter.getDosageById(_selectedDosageId!);
    final isTabletOrCapsule = widget.medication!.type == MedicationType.tablet || widget.medication!.type == MedicationType.capsule;
    final isInjection = widget.medication!.type == MedicationType.injection;
    final isReconstituted = widget.medication!.reconstitutionVolume > 0;

    if (dosage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dosage not found')));
      setState(() => _isSaving = false);
      return;
    }

    double amount = dosage.totalDose;
    if (isInjection && isReconstituted && widget.medication!.selectedReconstitution != null) {
      amount = dosage.insulinUnits;
    }

    final now = DateTime.now();
    var nextDoseTime = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    while (nextDoseTime.isBefore(now)) {
      nextDoseTime = nextDoseTime.add(_frequency.duration);
    }

    final schedule = Schedule(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.medication!.id,
      dosageId: _selectedDosageId!,
      dosageName: dosage.name,
      dosageAmount: amount,
      dosageUnit: isInjection && isReconstituted
          ? 'IU'
          : isTabletOrCapsule
          ? (widget.medication!.type == MedicationType.tablet ? 'tablets' : 'capsules')
          : dosage.doseUnit,
      time: _time,
      frequencyType: _frequency,
      nextDoseTime: nextDoseTime,
      notificationTime: widget.schedule?.notificationTime,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmScheduleDialog(
        schedule: schedule,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
        isDark: isDark,
      ),
    );

    if (confirmed != true) {
      setState(() => _isSaving = false);
      return;
    }

    final schedulePresenter = Provider.of<SchedulePresenter>(context, listen: false);
    try {
      if (widget.schedule == null) {
        await schedulePresenter.addSchedule(schedule);
      } else {
        await schedulePresenter.updateSchedule(schedule.id, schedule);
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    if (widget.medication == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final dosages = dosagePresenter.getDosagesForMedication(widget.medication!.id);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Add Schedule' : 'Edit Schedule', style: const TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule for ${widget.medication!.name}',
                  style: AppConstants.cardTitleStyle(isDark).copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedDosageId,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Select Dosage',
                  ),
                  items: dosages.map((dosage) {
                    return DropdownMenuItem<String>(
                      value: dosage.id,
                      child: Text(dosage.name, style: const TextStyle(fontFamily: 'Inter')),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedDosageId = value),
                  validator: (value) => value == null ? 'Please select a dosage' : null,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    'Time: ${_time.format(context)}',
                    style: AppConstants.cardBodyStyle(isDark),
                  ),
                  trailing: const Icon(Icons.access_time, color: AppConstants.primaryColor),
                  onTap: () => _selectTime(context),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FrequencyType>(
                  value: _frequency,
                  decoration: AppConstants.formFieldDecoration(isDark).copyWith(
                    labelText: 'Frequency',
                  ),
                  items: FrequencyType.values
                      .map((freq) => DropdownMenuItem(
                    value: freq,
                    child: Text(freq.displayName, style: const TextStyle(fontFamily: 'Inter')),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => _frequency = value ?? _frequency),
                  validator: (value) => value == null ? 'Please select a frequency' : null,
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveSchedule(context),
                    style: AppConstants.actionButtonStyle(),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Schedule', style: TextStyle(fontFamily: 'Inter')),
                  ),
                ),
              ],
            ),
          ),
        ),
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
}