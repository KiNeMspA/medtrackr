// lib/features/schedule/ui/views/schedule_form_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';
import 'package:medtrackr/core/widgets/schedule_form_fields.dart';
import 'package:medtrackr/core/widgets/schedule_edit_dialog.dart';
import 'package:medtrackr/core/widgets/confirm_schedule_dialog.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';

class ScheduleFormView extends StatefulWidget {
  final Medication medication;
  final Schedule? schedule;

  const ScheduleFormView({super.key, required this.medication, this.schedule});

  @override
  _ScheduleFormViewState createState() => _ScheduleFormViewState();
}

class _ScheduleFormViewState extends State<ScheduleFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dosageNameController;
  late Dosage? _selectedDosage;
  late TimeOfDay _time;
  late FrequencyType _frequencyType;
  late int? _notificationTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return;
    }
    final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
    final dosages = dosagePresenter.getDosagesForMedication(widget.medication.id);
    _dosageNameController = TextEditingController(text: widget.schedule?.dosageName ?? '');
    _selectedDosage = widget.schedule != null && dosages.isNotEmpty
        ? dosages.firstWhere(
          (d) => d.id == widget.schedule!.dosageId,
      orElse: () => dosages.isNotEmpty ? dosages.first : null,
    )
        : dosages.isNotEmpty
        ? dosages.first
        : null;
    _time = widget.schedule?.time ?? TimeOfDay.now();
    _frequencyType = widget.schedule?.frequencyType ?? FrequencyType.daily;
    _notificationTime = widget.schedule?.notificationTime;
  }

  @override
  void dispose() {
    _dosageNameController.dispose();
    super.dispose();
  }

  Future<void> _saveSchedule(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    if (_selectedDosage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a dosage')),
      );
      setState(() => _isSaving = false);
      return;
    }

    final schedule = Schedule(
      id: widget.schedule?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: widget.medication.id,
      dosageId: _selectedDosage!.id,
      dosageName: _dosageNameController.text.isEmpty ? _selectedDosage!.name : _dosageNameController.text,
      time: _time,
      dosageAmount: _selectedDosage!.totalDose,
      dosageUnit: _selectedDosage!.doseUnit,
      frequencyType: _frequencyType,
      notificationTime: _notificationTime,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmScheduleDialog(
        schedule: schedule,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving schedule: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final dosages = dosagePresenter.getDosagesForMedication(widget.medication.id);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Add Schedule' : 'Edit Schedule'),
        backgroundColor: AppConstants.primaryColor,
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
                  'Schedule for ${widget.medication.name}',
                  style: AppConstants.cardTitleStyle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 16),
                ScheduleFormFields(
                  dosageNameController: _dosageNameController,
                  selectedDosage: _selectedDosage,
                  dosages: dosages,
                  time: _time,
                  frequencyType: _frequencyType,
                  notificationTime: _notificationTime,
                  onDosageChanged: (value) {
                    setState(() => _selectedDosage = value);
                  },
                  onTimeChanged: (value) {
                    if (value != null) setState(() => _time = value);
                  },
                  onFrequencyChanged: (value) {
                    if (value != null) setState(() => _frequencyType = value);
                  },
                  onNotificationTimeChanged: (value) {
                    setState(() => _notificationTime = value);
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : () => _saveSchedule(context),
                    style: AppConstants.actionButtonStyle,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Schedule'),
                  ),
                ),
              ],
            ),
          ),
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