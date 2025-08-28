import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // User preferences
  Future<bool> getIsFirstLaunch() async {
    final preferences = await prefs;
    return preferences.getBool('is_first_launch') ?? true;
  }

  Future<void> setFirstLaunchComplete() async {
    final preferences = await prefs;
    await preferences.setBool('is_first_launch', false);
  }

  Future<String> getUserName() async {
    final preferences = await prefs;
    return preferences.getString('user_name') ?? '';
  }

  Future<void> setUserName(String name) async {
    final preferences = await prefs;
    await preferences.setString('user_name', name);
  }

  Future<String> getWeightUnit() async {
    final preferences = await prefs;
    return preferences.getString('weight_unit') ?? 'kg';
  }

  Future<void> setWeightUnit(String unit) async {
    final preferences = await prefs;
    await preferences.setString('weight_unit', unit);
  }

  Future<String> getVolumeUnit() async {
    final preferences = await prefs;
    return preferences.getString('volume_unit') ?? 'ml';
  }

  Future<void> setVolumeUnit(String unit) async {
    final preferences = await prefs;
    await preferences.setString('volume_unit', unit);
  }

  // Notification settings
  Future<bool> getNotificationsEnabled() async {
    final preferences = await prefs;
    return preferences.getBool('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final preferences = await prefs;
    await preferences.setBool('notifications_enabled', enabled);
  }

  Future<String> getNotificationTime() async {
    final preferences = await prefs;
    return preferences.getString('notification_time') ?? '09:00';
  }

  Future<void> setNotificationTime(String time) async {
    final preferences = await prefs;
    await preferences.setString('notification_time', time);
  }

  Future<int> getNotificationInterval() async {
    final preferences = await prefs;
    return preferences.getInt('notification_interval') ?? 60; // minutes
  }

  Future<void> setNotificationInterval(int minutes) async {
    final preferences = await prefs;
    await preferences.setInt('notification_interval', minutes);
  }

  // Theme settings
  Future<String> getThemeMode() async {
    final preferences = await prefs;
    return preferences.getString('theme_mode') ?? 'system';
  }

  Future<void> setThemeMode(String mode) async {
    final preferences = await prefs;
    await preferences.setString('theme_mode', mode);
  }

  Future<bool> getUseDynamicColors() async {
    final preferences = await prefs;
    return preferences.getBool('use_dynamic_colors') ?? true;
  }

  Future<void> setUseDynamicColors(bool enabled) async {
    final preferences = await prefs;
    await preferences.setBool('use_dynamic_colors', enabled);
  }

  // Goal settings
  Future<int> getDailyGoal() async {
    final preferences = await prefs;
    return preferences.getInt('daily_goal') ?? 2500;
  }

  Future<void> setDailyGoal(int ml) async {
    final preferences = await prefs;
    await preferences.setInt('daily_goal', ml);
  }

  Future<bool> getShowGoalReminder() async {
    final preferences = await prefs;
    return preferences.getBool('show_goal_reminder') ?? true;
  }

  Future<void> setShowGoalReminder(bool enabled) async {
    final preferences = await prefs;
    await preferences.setBool('show_goal_reminder', enabled);
  }

  // Data export/import settings
  Future<String> getLastBackupDate() async {
    final preferences = await prefs;
    return preferences.getString('last_backup_date') ?? '';
  }

  Future<void> setLastBackupDate(String date) async {
    final preferences = await prefs;
    await preferences.setString('last_backup_date', date);
  }

  Future<bool> getAutoBackup() async {
    final preferences = await prefs;
    return preferences.getBool('auto_backup') ?? false;
  }

  Future<void> setAutoBackup(bool enabled) async {
    final preferences = await prefs;
    await preferences.setBool('auto_backup', enabled);
  }

  // App usage statistics
  Future<int> getAppLaunchCount() async {
    final preferences = await prefs;
    return preferences.getInt('app_launch_count') ?? 0;
  }

  Future<void> incrementAppLaunchCount() async {
    final preferences = await prefs;
    final currentCount = await getAppLaunchCount();
    await preferences.setInt('app_launch_count', currentCount + 1);
  }

  Future<String> getFirstLaunchDate() async {
    final preferences = await prefs;
    return preferences.getString('first_launch_date') ?? '';
  }

  Future<void> setFirstLaunchDate(String date) async {
    final preferences = await prefs;
    await preferences.setString('first_launch_date', date);
  }

  // Clear all settings
  Future<void> clearAllSettings() async {
    final preferences = await prefs;
    await preferences.clear();
  }

  // Export settings
  Future<Map<String, dynamic>> exportSettings() async {
    final preferences = await prefs;
    final keys = preferences.getKeys();
    final Map<String, dynamic> settings = {};
    
    for (String key in keys) {
      final value = preferences.get(key);
      if (value != null) {
        settings[key] = value;
      }
    }
    
    return settings;
  }

  // Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    final preferences = await prefs;
    
    for (String key in settings.keys) {
      final value = settings[key];
      if (value is String) {
        await preferences.setString(key, value);
      } else if (value is int) {
        await preferences.setInt(key, value);
      } else if (value is bool) {
        await preferences.setBool(key, value);
      } else if (value is double) {
        await preferences.setDouble(key, value);
      }
    }
  }
}