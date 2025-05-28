// In lib/features/schedule/pages/schedule_form_page.dart

import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';
import 'package:provider/provider.dart';
import 'package:medtrackr/data/data_sources/local/data_provider.dart';
import 'package:medtrackr/core/widgets/navigation/app_bottom_navigation_bar.dart';
import 'package:medtrackr/core/widgets/forms/schedule_form_fields.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Medication medication;
  final Schedule? schedule;

  const ScheduleFormScreen({super.key, required this.medication, this.schedule});

  @override
  _ScheduleFormScreenState createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
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
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final dosages = dataProvider.getDosagesForMedication(widget.medication.id);
    _dosageNameController = TextEditingController(text: widget.schedule?.dosageName ?? '');
    _selectedDosage = widget.schedule != null && dosages.isNotEmpty
        ? dosages.firstWhere(
          (d) => d.id == widget.schedule!.dosageId,
      orElse: () => dosages.first,
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
      dosageName: _dosageNameController.text.isEmpty
          ? _selectedDosage!.name
          : _dosageNameController.text,
      time: _time,
      dosageAmount: _selectedDosage!.totalDose,
      dosageUnit: _selectedDosage!.doseUnit,
      frequencyType: _frequencyType,
      notificationTime: _notificationTime,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppThemes.informationBackgroundColor,
        title: Text(
          widget.schedule == null ? 'Add Schedule' : 'Update Schedule',
          style: AppThemes.informationTitleStyle,
        ),
        content: RichText(
          text: TextSpan(
            style: AppThemes.informationContentTextStyle?.copyWith(height: 1.5),
            children: [
              const TextSpan(
                text: 'Dosage: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: schedule.dosageName),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: 'Amount: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                  text: '${schedule.dosageAmount} ${schedule.dosageUnit}',
                  style: TextStyle(color: AppConstants.primaryColor)),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: 'Time: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: schedule.time.format(context)),
              const TextSpan(text: '\n'),
              const TextSpan(
                text: 'Frequency: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: schedule.frequencyType.displayName),
              if (_notificationTime != null) ...[
                const TextSpan(text: '\n'),
                const TextSpan(
                  text: 'Notification: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: '$_notificationTime minutes before'),
              ],
            ],
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppConstants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: AppConstants.dialogButtonStyle,
                child: const Text('Confirm'),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true) {
      setState(() => _isSaving = false);
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    try {
      if (widget.schedule == null) {
        await dataProvider.addScheduleAsync(schedule);
      } else {
        await dataProvider.updateScheduleAsync(schedule.id, schedule);
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
    final dataProvider = Provider.of<DataProvider>(context);
    final dosages = dataProvider.getDosagesForMedication(widget.medication.id);

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