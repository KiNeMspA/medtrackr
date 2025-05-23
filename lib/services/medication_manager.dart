static Future<void> _scheduleNotifications(DosageSchedule schedule) async {
final timeParts = schedule.notificationTime.split(':');
final hour = int.parse(timeParts[0]);
final minute = int.parse(timeParts[1].split(' ')[0]);
final now = DateTime.now();
if (schedule.frequencyType == FrequencyType.daily) {
final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
await NotificationService.scheduleNotification(
id: schedule.medicationId.hashCode,
title: 'MedTrackr Reminder',
body: 'Time to take ${schedule.totalDose} ${schedule.doseUnit} of medication',
scheduledTime: scheduledTime,
);
} else if (schedule.frequencyType == FrequencyType.selectedDays && schedule.selectedDays != null) {
for (int day in schedule.selectedDays!) {
final scheduledTime = DateTime(now.year, now.month, now.day + (day - now.weekday + 7) % 7, hour, minute);
await NotificationService.scheduleNotification(
id: (schedule.medicationId.hashCode + day),
title: 'MedTrackr Reminder',
body: 'Time to take ${schedule.totalDose} ${schedule.doseUnit} of medication',
scheduledTime: scheduledTime,
);
}
}
}