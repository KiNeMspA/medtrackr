// lib/features/calendar/ui/views/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/core/widgets/app_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final schedules = schedulePresenter.schedules;

    Map<DateTime, List<Schedule>> events = {};
    for (var schedule in schedules) {
      final date = DateTime.now(); // Placeholder: Map to actual schedule date
      final key = DateTime(date.year, date.month, date.day);
      events[key] = events[key] ?? [];
      events[key]!.add(schedule);
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (_selectedDay != null)
            Expanded(
              child: ListView(
                children: (events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
                    .map((schedule) => ListTile(
                  title: Text(schedule.dosageName),
                  subtitle: Text('${schedule.time.format(context)} - ${schedule.dosageAmount} ${schedule.dosageUnit}'),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/medication_form'),
        backgroundColor: AppConstants.primaryColor,
        tooltip: 'Add a new medication',
        child: const Icon(Icons.add, color: Colors.black),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 1,
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