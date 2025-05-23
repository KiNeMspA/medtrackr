import 'package:flutter/material.dart';
import 'package:medtrackr/models/dosage_schedule.dart';
import 'package:medtrackr/models/medication.dart';

class DosageScheduleScreen extends StatefulWidget {
  final Medication medication;

  const DosageScheduleScreen({super.key, required this.medication});

  @override
  State<DosageScheduleScreen> createState() => _DosageScheduleScreenState();
}

class _DosageScheduleScreenState extends State<DosageScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  DosageMethod _method = DosageMethod.subcutaneous;
  double _totalDose = 0.0;
  FrequencyType _frequencyType = FrequencyType.daily;
  int _frequencyValue = 1;
  List<int> _selectedDays = [];
  int _cycleOn = 1;
  int _cycleOff = 0;
  bool _repeatCycle = false;

  @override
  Widget build(BuildContext context) {
    final volume = widget.medication.concentration != 0 ? _totalDose / widget.medication.concentration : 0.0;
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
                decoration: const InputDecoration(labelText: 'Dosage Method'),
                items: DosageMethod.values
                    .map((method) => DropdownMenuItem(value: method, child: Text(method.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => setState(() => _method = value!),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Total Dose (${widget.medication.stockUnit})'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a dose';
                  final num = double.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onChanged: (value) => setState(() => _totalDose = double.tryParse(value) ?? 0.0),
              ),
              Text(
                'Volume: ${volume.toStringAsFixed(2)} ${widget.medication.reconstitutionVolumeUnit}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<FrequencyType>(
                value: _frequencyType,
                decoration: const InputDecoration(labelText: 'Dosage Frequency'),
                items: FrequencyType.values
                    .map((freq) => DropdownMenuItem(value: freq, child: Text(freq.toString().split('.').last)))
                    .toList(),
                onChanged: (value) => setState(() => _frequencyType = value!),
              ),
              if (_frequencyType == FrequencyType.timesPerDay || _frequencyType == FrequencyType.timesPerWeek)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Frequency Value'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter a value';
                    final num = int.tryParse(value);
                    if (num == null || num <= 0) return 'Enter a valid number';
                    return null;
                  },
                  onSaved: (value) => _frequencyValue = int.parse(value!),
                ),
              if (_frequencyType == FrequencyType.selectedDays)
                MultiSelectChip(
                  days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                  onSelectionChanged: (selected) => setState(() => _selectedDays = selected),
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cycle On (Days)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a value';
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _cycleOn = int.parse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Cycle Off (Days)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter a value';
                  final num = int.tryParse(value);
                  if (num == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) => _cycleOff = int.parse(value!),
              ),
              SwitchListTile(
                title: const Text('Repeat Cycle'),
                value: _repeatCycle,
                onChanged: (value) => setState(() => _repeatCycle = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Cycle Summary: ${_totalDose.toStringAsFixed(2)} ${widget.medication.stockUnit} (${volume.toStringAsFixed(2)} ${widget.medication.reconstitutionVolumeUnit}) '
                    '${_frequencyType.toString().split('.').last} for $_cycleOn days, ${_cycleOff == 0 ? 'no' : '$_cycleOff'} days off',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final schedule = DosageSchedule(
                      medicationId: widget.medication.id,
                      method: _method,
                      totalDose: _totalDose,
                      volume: volume,
                      frequencyType: _frequencyType,
                      frequencyValue: _frequencyValue,
                      selectedDays: _selectedDays,
                      cycleOn: _cycleOn,
                      cycleOff: _cycleOff,
                      repeatCycle: _repeatCycle,
                    );
                    // TODO: Save schedule (e.g., to local storage)
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
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
  List<int> selectedDays = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: List<Widget>.generate(
        widget.days.length,
            (index) => ChoiceChip(
          label: Text(widget.days[index]),
          selected: selectedDays.contains(index),
          onSelected: (selected) {
            setState(() {
              selected ? selectedDays.add(index) : selectedDays.remove(index);
              widget.onSelectionChanged(selectedDays);
            });
          },
        ),
      ),
    );
  }
}