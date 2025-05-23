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
  String _doseUnit = 'mcg';
  double _totalDose = 0.0;
  FrequencyType _frequencyType = FrequencyType.daily;
  List<int> _selectedDays = [];
  TimeOfDay _notificationTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  Widget build(BuildContext context) {
    final volume = widget.medication.concentration != 0 ? _totalDose / widget.medication.concentration : 0.0;
    final insulinUnits = volume * 100; // U-100 syringe: 1 mL = 100 IU
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosage Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildDropdownFormField(
                label: 'Dosage Method',
                value: _method,
                items: DosageMethod.values,
                itemToString: (method) => method.toString().split('.').last,
                onChanged: (value) => setState(() => _method = value!),
              ),
              _buildDropdownFormField(
                label: 'Dose Unit',
                value: _doseUnit,
                items: ['mcg', 'mg'],
                itemToString: (unit) => unit,
                onChanged: (value) => setState(() => _doseUnit = value!),
              ),
              _buildTextFormField(
                label: 'Total Dose ($_doseUnit)',
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
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Dose Details:\n'
                        'Volume: ${_formatNumber(volume)} ${widget.medication.reconstitutionVolumeUnit}\n'
                        '1mL Syringe: ${_formatNumber(insulinUnits)} IU',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              _buildDropdownFormField(
                label: 'Dosage Frequency',
                value: _frequencyType,
                items: FrequencyType.values,
                itemToString: (freq) => freq.toString().split('.').last,
                onChanged: (value) => setState(() => _frequencyType = value!),
              ),
              if (_frequencyType == FrequencyType.selectedDays)
                MultiSelectChip(
                  days: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
                  onSelectionChanged: (selected) => setState(() => _selectedDays = selected),
                ),
              ListTile(
                title: const Text('Notification Time', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_notificationTime.format(context), style: const TextStyle(color: Colors.blueGrey)),
                trailing: const Icon(Icons.access_time, color: Colors.blue),
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
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Schedule Summary: ${_formatNumber(_totalDose)} $_doseUnit '
                        '(${_formatNumber(volume)} ${widget.medication.reconstitutionVolumeUnit}, '
                        '${_formatNumber(insulinUnits)} IU) ${_frequencyType.toString().split('.').last}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
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
                    Navigator.pop(context);
                    Navigator.pop(context, schedule);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '').replaceAll(RegExp(r'\.(\d)0+$'), r'.$1');
  }

  Widget _buildTextFormField({
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    void Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdownFormField<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemToString,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items.map((item) => DropdownMenuItem(value: item, child: Text(itemToString(item)))).toList(),
        onChanged: onChanged,
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
      runSpacing: 8.0,
      children: List<Widget>.generate(
        widget.days.length,
            (index) => ChoiceChip(
          label: Text(widget.days[index]),
          selected: selectedDays.contains(index),
          selectedColor: Colors.blue.shade100,
          backgroundColor: Colors.grey.shade200,
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