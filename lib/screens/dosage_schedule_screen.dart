import 'package:flutter/material.dart';
import 'package:medtrackr/models/medication.dart';
import 'package:medtrackr/models/dosage_schedule.dart';

class DosageScheduleScreen extends StatefulWidget {
  final Medication medication;

  const DosageScheduleScreen({super.key, required this.medication});

  @override
  State<DosageScheduleScreen> createState() => _DosageScheduleScreenState();
}

class _DosageScheduleScreenState extends State<DosageScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  DosageMethod _method = DosageMethod.subcutaneous;
  String _doseUnit = 'mcg';
  double _totalDose = 0.0;
  FrequencyType _frequencyType = FrequencyType.daily;
  List<int> _selectedDays = [];
  TimeOfDay _notificationTime = const TimeOfDay(hour: 22, minute: 0);

  double get concentration {
    return widget.medication.reconstitutionVolume != 0
        ? (widget.medication.quantityUnit == 'mg'
        ? widget.medication.quantity * 1000
        : widget.medication.quantity) /
        widget.medication.reconstitutionVolume
        : 0.0;
  }

  double get volume {
    return _totalDose / concentration;
  }

  double get insulinUnits {
    return volume * 100;
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.(\d)0+$'), r'.$1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosage Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<DosageMethod>(
                value: _method,
                decoration: InputDecoration(
                  labelText: 'Dosage Method',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: DosageMethod.values
                    .map((method) => DropdownMenuItem(
                  value: method,
                  child: Text(method.toString().split('.').last),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _method = value!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _doseUnit,
                decoration: InputDecoration(
                  labelText: 'Dose Unit',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: ['mcg', 'mg'].map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                onChanged: (value) => setState(() => _doseUnit = value!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Total Dose ($_doseUnit)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a dose';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onChanged: (value) => setState(() => _totalDose = double.tryParse(value) ?? 0.0),
                onSaved: (value) => _totalDose = double.parse(value!),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Dose Details:\n'
                        'Volume: ${_formatNumber(volume)} ${widget.medication.reconstitutionVolumeUnit}\n'
                        '1mL Syringe: ${_formatNumber(insulinUnits)} IU',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<FrequencyType>(
                value: _frequencyType,
                decoration: InputDecoration(
                  labelText: 'Dosage Frequency',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                items: FrequencyType.values
                    .map((freq) => DropdownMenuItem(
                  value: freq,
                  child: Text(freq.toString().split('.').last),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _frequencyType = value!),
              ),
              if (_frequencyType == FrequencyType.selectedDays)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: MultiSelectChip(
                    days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                    onSelectionChanged: (selected) => setState(() => _selectedDays = selected),
                  ),
                ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  'Notification Time',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _notificationTime.format(context),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _notificationTime,
                  );
                  if (time != null) {
                    setState(() => _notificationTime = time);
                  }
                },
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Schedule Summary: ${_formatNumber(_totalDose)} $_doseUnit '
                        '(${_formatNumber(volume)} ${widget.medication.reconstitutionVolumeUnit}, '
                        '${_formatNumber(insulinUnits)} IU) ${_frequencyType.toString().split('.').last}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final schedule = DosageSchedule(
                      medicationId: widget.medication.id,
                      method: _method,
                      doseUnit: _doseUnit,
                      totalDose: _totalDose,
                      volume: volume,
                      insulinUnits: insulinUnits,
                      frequencyType: _frequencyType,
                      selectedDays: _frequencyType == FrequencyType.selectedDays ? _selectedDays : null,
                      notificationTime: _notificationTime.format(context),
                    );
                    print('Saving dosage schedule for medication ID: ${widget.medication.id}'); // Debug log
                    Navigator.pop(context, schedule); // Return to HomeScreen
                  }
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Save Dosage',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<String> days;
  final Function(List<int>) onSelectionChanged;

  const MultiSelectChip({super.key, required this.days, required this.onSelectionChanged});

  @override
  State<MultiSelectChip> createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<int> _selectedDays = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: List<Widget>.generate(widget.days.length, (index) {
        return ChoiceChip(
          label: Text(widget.days[index]),
          selected: _selectedDays.contains(index),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(index);
              } else {
                _selectedDays.remove(index);
              }
              widget.onSelectionChanged(_selectedDays);
            });
          },
        );
      }),
    );
  }
}