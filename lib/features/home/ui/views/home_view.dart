// lib/features/home/ui/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:medtrackr/app/constants.dart';
import 'package:medtrackr/app/enums.dart';
import 'package:medtrackr/app/themes.dart';
import 'package:medtrackr/core/services/navigation_service.dart';
import 'package:medtrackr/core/utils/format_helper.dart';
import 'package:medtrackr/core/services/theme_provider.dart';
import 'package:medtrackr/features/medication/presenters/medication_presenter.dart';
import 'package:medtrackr/features/schedule/presenters/schedule_presenter.dart';
import 'package:medtrackr/features/dosage/presenters/dosage_presenter.dart';
import 'package:medtrackr/features/medication/models/medication.dart';
import 'package:medtrackr/features/schedule/models/schedule.dart';
import 'package:medtrackr/features/dosage/models/dosage.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  bool _isMounted = true;
  bool _isLoading = true;
  bool _showAddMenu = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final medicationPresenter = Provider.of<MedicationPresenter>(context, listen: false);
    final schedulePresenter = Provider.of<SchedulePresenter>(context, listen: false);
    final dosagePresenter = Provider.of<DosagePresenter>(context, listen: false);
    try {
      await Future.wait([
        medicationPresenter.loadMedications(),
        schedulePresenter.loadSchedules(),
        dosagePresenter.loadDosages(),
      ]);
      if (_isMounted) setState(() => _isLoading = false);
    } catch (e) {
      if (_isMounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    final medicationPresenter = Provider.of<MedicationPresenter>(context);
    final schedulePresenter = Provider.of<SchedulePresenter>(context);
    final dosagePresenter = Provider.of<DosagePresenter>(context);
    final medications = medicationPresenter.medications;
    final upcomingDoses = schedulePresenter.upcomingDoses;
    final nextDose = upcomingDoses.isNotEmpty ? upcomingDoses.first : null;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor(isDark),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
          : CustomScrollView(
        slivers: [
          // Top Banner with App Name
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: AppThemes.bannerDecoration(isDark),
                child: const Center(
                  child: Text(
                    'MedTrackr', // Placeholder for logo
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upcoming Doses Section
                  Text(
                    'Next Dose',
                    style: AppConstants.nextDoseTitleStyle(isDark),
                  ),
                  const SizedBox(height: 12),
                  nextDose == null
                      ? Container(
                    decoration: AppConstants.cardDecoration(isDark),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No upcoming doses.',
                        style: AppConstants.nextDoseSubtitleStyle(isDark),
                      ),
                    ),
                  )
                      : _buildNextDoseCard(context, nextDose, schedulePresenter, dosagePresenter),
                  const SizedBox(height: 16),
                  // Calendar Section
                  Text(
                    'Upcoming Schedule',
                    style: AppConstants.nextDoseTitleStyle(isDark),
                  ),
                  const SizedBox(height: 12),
                  _buildMiniCalendar(context, schedulePresenter),
                  const SizedBox(height: 16),
                  // Medications Section
                  Text(
                    'Medications',
                    style: AppConstants.nextDoseTitleStyle(isDark),
                  ),
                  const SizedBox(height: 12),
                  medications.isEmpty
                      ? Center(
                    child: Column(
                      children: [
                        Text(
                          'No medications added.',
                          style: AppConstants.cardTitleStyle(isDark),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => navigationService.navigateTo('/medication_form'),
                          style: AppConstants.homeActionButtonStyle(),
                          child: const Text('Add Medication', style: TextStyle(fontFamily: 'Inter')),
                        ),
                      ],
                    ),
                  )
                      : SizedBox(
                    height: 120, // Smaller height for compact cards
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        return _buildMedicationCard(context, medications[index], dosagePresenter, schedulePresenter);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _showAddMenu = !_showAddMenu);
        },
        backgroundColor: AppConstants.primaryColor,
        child: Icon(_showAddMenu ? Icons.close : Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

  Widget _buildNextDoseCard(
      BuildContext context,
      Map<String, dynamic> dose,
      SchedulePresenter schedulePresenter,
      DosagePresenter dosagePresenter,
      ) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final schedule = dose['schedule'] as Schedule;
    final medication = dose['medication'] as Medication;
    final dosages = dosagePresenter.getDosagesForMedication(medication.id);
    final dosage = dosages.firstWhere(
          (d) => d.id == schedule.dosageId,
      orElse: () => Dosage(
        id: '',
        medicationId: '',
        name: 'Unknown',
        method: DosageMethod.oral,
        doseUnit: '',
        totalDose: 0.0,
        volume: 0.0,
        insulinUnits: 0.0,
      ),
    );

    return Container(
      decoration: AppConstants.prominentCardDecoration(isDark),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.name,
            style: AppConstants.nextDoseTitleStyle(isDark),
          ),
          const SizedBox(height: 8),
          Text(
            '${schedule.dosageName} - ${formatNumber(schedule.dosageAmount)} ${schedule.dosageUnit}',
            style: AppConstants.nextDoseSubtitleStyle(isDark),
          ),
          Text(
            'Time: ${schedule.time.format(context)}',
            style: AppConstants.nextDoseSubtitleStyle(isDark),
          ),
          if (schedule.notificationTime != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reminder: ${schedule.notificationTime} minutes before',
              style: AppConstants.nextDoseSubtitleStyle(isDark),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => dosagePresenter.takeDose(
                  schedule.medicationId,
                  schedule.id,
                  schedule.dosageId,
                ).then((_) => _loadData()).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }),
                style: AppConstants.homeActionButtonStyle(),
                child: const Text('Take', style: TextStyle(fontFamily: 'Inter')),
              ),
              ElevatedButton(
                onPressed: () => schedulePresenter.postponeDose(schedule.id, '30').then((_) => _loadData()),
                style: AppConstants.snoozeButtonStyle(isDark),
                child: const Text('Snooze', style: TextStyle(fontFamily: 'Inter')),
              ),
              ElevatedButton(
                onPressed: () => schedulePresenter.cancelDose(schedule.id).then((_) => _loadData()),
                style: AppConstants.homeCancelButtonStyle(),
                child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(
      BuildContext context,
      Medication medication,
      DosagePresenter dosagePresenter,
      SchedulePresenter schedulePresenter,
      ) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final dosages = dosagePresenter.getDosagesForMedication(medication.id);
    final schedule = schedulePresenter.getScheduleForMedication(medication.id);
    final isTablet = medication.type == MedicationType.tablet || medication.type == MedicationType.capsule;
    final backgroundColor = isTablet ? AppConstants.tabletCardBackground : AppConstants.injectionCardBackground;

    return GestureDetector(
      onTap: () => Provider.of<NavigationService>(context, listen: false).navigateTo('/medication_details', arguments: medication),
      child: Container(
        width: 160, // Compact width
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isTablet ? Icons.tablet : Icons.medical_services,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    medication.name,
                    style: AppConstants.medicationCardTitleStyle(isDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isTablet
                  ? '${formatNumber(medication.remainingQuantity)}/${formatNumber(medication.quantity)} Tablets'
                  : '${formatNumber(medication.remainingQuantity)}/${formatNumber(medication.quantity)} Remaining',
              style: AppConstants.medicationCardSubtitleStyle(isDark),
            ),
            const SizedBox(height: 4),
            Text(
              schedule != null && dosages.isNotEmpty
                  ? 'Next: ${schedule.time.format(context)}'
                  : 'No schedule',
              style: AppConstants.medicationCardSubtitleStyle(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(BuildContext context, SchedulePresenter schedulePresenter) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final events = <DateTime, List<Schedule>>{};
    for (var dose in schedulePresenter.upcomingDoses) {
      final schedule = dose['schedule'] as Schedule;
      final nextTime = dose['nextTime'] as DateTime;
      final key = DateTime(nextTime.year, nextTime.month, nextTime.day);
      events[key] = events[key] ?? [];
      events[key]!.add(schedule);
    }

    return Container(
      decoration: AppConstants.cardDecoration(isDark),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 30)),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month, // Show full month view
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleTextStyle: AppConstants.cardTitleStyle(isDark),
          leftChevronIcon: Icon(Icons.chevron_left, color: AppConstants.primaryColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppConstants.primaryColor),
        ),
        daysOfWeekHeight: 20,
        rowHeight: 40,
        eventLoader: (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppConstants.accentColor(isDark).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: AppConstants.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          Provider.of<NavigationService>(context, listen: false).navigateTo('/calendar');
        },
      ),
    );
  }

  // Add Menu Overlay for FAB
  Widget _buildAddMenu(BuildContext context) {
    final navigationService = Provider.of<NavigationService>(context, listen: false);
    return _showAddMenu
        ? Positioned(
      bottom: 80,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            _buildAddMenuItem(
              context,
              label: 'Add Medication',
              icon: Icons.medication,
              onTap: () {
                setState(() => _showAddMenu = false);
                navigationService.navigateTo('/medication_form');
              },
            ),
            const SizedBox(height: 8),
            _buildAddMenuItem(
              context,
              label: 'Add Schedule',
              icon: Icons.schedule,
              onTap: () {
                setState(() => _showAddMenu = false);
                // Navigate to a screen to select a medication first
                navigationService.navigateTo('/add_schedule');
              },
            ),
          ],
        ),
      ),
    )
        : const SizedBox.shrink();
  }

  Widget _buildAddMenuItem(BuildContext context, {required String label, required IconData icon, required VoidCallback onTap}) {
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
            Icon(icon, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppConstants.cardBodyStyle(isDark)),
          ],
        ),
      ),
    );
  }
}