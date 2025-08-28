import 'package:flutter/material.dart';
import 'package:drinktracker/services/settings_service.dart';
import 'package:drinktracker/services/app_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final SettingsService _settingsService = SettingsService();
  final AppState _appState = AppState();

  // Initialize notifications
  Future<void> initialize() async {
    // Check if notifications are enabled
    final notificationsEnabled = await _settingsService.getNotificationsEnabled();
    if (notificationsEnabled) {
      await _scheduleReminders();
    }
  }

  // Schedule daily reminders
  Future<void> _scheduleReminders() async {
    final interval = await _settingsService.getNotificationInterval();
    final startTime = await _settingsService.getNotificationTime();
    
    // Parse start time (format: "HH:MM")
    final timeParts = startTime.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    // Calculate reminder times throughout the day
    final reminders = _calculateReminderTimes(hour, minute, interval);
    
    // Schedule each reminder
    for (int i = 0; i < reminders.length; i++) {
      await _scheduleReminder(i, reminders[i]);
    }
  }

  List<TimeOfDay> _calculateReminderTimes(int startHour, int startMinute, int intervalMinutes) {
    final reminders = <TimeOfDay>[];
    final startTime = TimeOfDay(hour: startHour, minute: startMinute);
    
    // Add reminders every interval minutes until 10 PM
    var currentTime = startTime;
    while (currentTime.hour < 22) {
      reminders.add(currentTime);
      
      // Add interval minutes
      final totalMinutes = currentTime.hour * 60 + currentTime.minute + intervalMinutes;
      final newHour = totalMinutes ~/ 60;
      final newMinute = totalMinutes % 60;
      
      currentTime = TimeOfDay(hour: newHour, minute: newMinute);
    }
    
    return reminders;
  }

  Future<void> _scheduleReminder(int id, TimeOfDay time) async {
    // This would integrate with a local notification plugin
    // For now, we'll just print the reminder
    print('Scheduled reminder $id for ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
  }

  // Show drink reminder notification
  Future<void> showDrinkReminder() async {
    final showGoalReminder = await _settingsService.getShowGoalReminder();
    final currentProgress = _appState.progressPercentage;
    
    if (showGoalReminder && currentProgress < 0.8) {
      // Show reminder to drink water
      _showNotification(
        title: 'Time to Hydrate! 💧',
        body: 'You\'re ${((1 - currentProgress) * 100).round()}% away from your daily goal.',
        payload: 'drink_reminder',
      );
    }
  }

  // Show goal achievement notification
  Future<void> showGoalAchievement() async {
    _showNotification(
      title: 'Goal Achieved! 🎉',
      body: 'Congratulations! You\'ve reached your daily hydration goal.',
      payload: 'goal_achieved',
    );
  }

  // Show streak notification
  Future<void> showStreakNotification(int streakDays) async {
    _showNotification(
      title: 'Streak Alert! 🔥',
      body: 'You\'ve maintained your hydration goal for $streakDays days!',
      payload: 'streak_achieved',
    );
  }

  // Generic notification method
  void _showNotification({
    required String title,
    required String body,
    String? payload,
  }) {
    // This would integrate with a local notification plugin
    // For now, we'll just print the notification
    print('Notification: $title - $body');
  }

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? enabled,
    String? time,
    int? interval,
  }) async {
    if (enabled != null) {
      await _settingsService.setNotificationsEnabled(enabled);
    }
    
    if (time != null) {
      await _settingsService.setNotificationTime(time);
    }
    
    if (interval != null) {
      await _settingsService.setNotificationInterval(interval);
    }
    
    // Reinitialize notifications if enabled
    if (enabled == true) {
      await initialize();
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // This would cancel all scheduled notifications
    print('All notifications cancelled');
  }

  // Check if it's time for a reminder
  bool _isTimeForReminder(TimeOfDay currentTime, TimeOfDay reminderTime) {
    return currentTime.hour == reminderTime.hour && 
           currentTime.minute == reminderTime.minute;
  }

  // Process notification tap
  void onNotificationTap(String payload) {
    switch (payload) {
      case 'drink_reminder':
        // Navigate to home page to add drink
        print('Navigate to add drink');
        break;
      case 'goal_achieved':
        // Show achievement celebration
        print('Show achievement celebration');
        break;
      case 'streak_achieved':
        // Show streak celebration
        print('Show streak celebration');
        break;
    }
  }
}