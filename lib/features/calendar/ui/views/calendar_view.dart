// lib/features/calendar/ui/views/calendar_view.dart
import 'package:flutter/material.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/core/services/theme_provider.dart';

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
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final upcomingDoses = schedulePresenter.upcomingDoses;

    Map<DateTime, List<Schedule>> events = {};
    for (var dose in upcomingDoses) {
      if (dose['schedule'] != null) {
        final schedule = dose['schedule'] as Schedule;
        final nextTime = dose['nextTime'] as DateTime;
        final key = DateTime(nextTime.year, nextTime.month, nextTime.day);
        events[key] = events[key] ?? [];
        events[key]!.add(schedule);
      }
    }

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      appBar: AppBar(
        title: const Text('Calendar', style: TextStyle(fontFamily: 'Inter')),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => navigationService.replaceWith('/home'),
        ),
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
                color: AppConstants.accentColor(isDark).withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppConstants.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          if (_selectedDay != null)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: (events[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] ?? [])
                    .map((schedule) => ListTile(
                  title: Text(schedule.dosageName, style: AppConstants.cardTitleStyle(isDark)),
                  subtitle: Text(
                    '${schedule.time.format(context)} - ${formatNumber(schedule.dosageAmount)} ${schedule.dosageUnit}',
                    style: AppConstants.cardBodyStyle(isDark),
                  ),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (index == 0) navigationService.replaceWith('/home');
            if (index == 1) navigationService.replaceWith('/calendar');
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