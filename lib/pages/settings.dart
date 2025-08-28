import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drinktracker/services/app_state.dart';
import 'package:drinktracker/services/settings_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsService _settingsService = SettingsService();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  String _selectedWeightUnit = 'kg';
  String _selectedVolumeUnit = 'ml';
  String _selectedThemeMode = 'system';
  bool _notificationsEnabled = true;
  bool _showGoalReminder = true;
  bool _useDynamicColors = true;
  bool _autoBackup = false;
  int _notificationInterval = 60;
  String _notificationTime = '09:00';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final userName = await _settingsService.getUserName();
    final dailyGoal = await _settingsService.getDailyGoal();
    final weightUnit = await _settingsService.getWeightUnit();
    final volumeUnit = await _settingsService.getVolumeUnit();
    final themeMode = await _settingsService.getThemeMode();
    final notificationsEnabled = await _settingsService.getNotificationsEnabled();
    final showGoalReminder = await _settingsService.getShowGoalReminder();
    final useDynamicColors = await _settingsService.getUseDynamicColors();
    final autoBackup = await _settingsService.getAutoBackup();
    final notificationInterval = await _settingsService.getNotificationInterval();
    final notificationTime = await _settingsService.getNotificationTime();

    setState(() {
      _nameController.text = userName;
      _goalController.text = dailyGoal.toString();
      _selectedWeightUnit = weightUnit;
      _selectedVolumeUnit = volumeUnit;
      _selectedThemeMode = themeMode;
      _notificationsEnabled = notificationsEnabled;
      _showGoalReminder = showGoalReminder;
      _useDynamicColors = useDynamicColors;
      _autoBackup = autoBackup;
      _notificationInterval = notificationInterval;
      _notificationTime = notificationTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: dark)),
        backgroundColor: white,
        elevation: 0,
        iconTheme: IconThemeData(color: dark),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Personal Information'),
            _buildTextField(
              controller: _nameController,
              label: 'Your Name',
              onChanged: (value) => _settingsService.setUserName(value),
            ),
            SizedBox(height: 20),
            
            _buildSectionTitle('Daily Goal'),
            _buildTextField(
              controller: _goalController,
              label: 'Daily Goal (ml)',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final goal = int.tryParse(value);
                if (goal != null && goal > 0) {
                  _settingsService.setDailyGoal(goal);
                  Provider.of<AppState>(context, listen: false).updateMaximumML(goal);
                }
              },
            ),
            SizedBox(height: 20),
            
            _buildSectionTitle('Units'),
            _buildDropdown(
              label: 'Weight Unit',
              value: _selectedWeightUnit,
              items: ['kg', 'lbs'],
              onChanged: (value) {
                setState(() => _selectedWeightUnit = value!);
                _settingsService.setWeightUnit(value!);
              },
            ),
            _buildDropdown(
              label: 'Volume Unit',
              value: _selectedVolumeUnit,
              items: ['ml', 'oz', 'cups'],
              onChanged: (value) {
                setState(() => _selectedVolumeUnit = value!);
                _settingsService.setVolumeUnit(value!);
              },
            ),
            SizedBox(height: 20),
            
            _buildSectionTitle('Theme'),
            _buildDropdown(
              label: 'Theme Mode',
              value: _selectedThemeMode,
              items: ['system', 'light', 'dark'],
              onChanged: (value) {
                setState(() => _selectedThemeMode = value!);
                _settingsService.setThemeMode(value!);
              },
            ),
            _buildSwitchTile(
              title: 'Use Dynamic Colors',
              value: _useDynamicColors,
              onChanged: (value) {
                setState(() => _useDynamicColors = value);
                _settingsService.setUseDynamicColors(value);
              },
            ),
            SizedBox(height: 20),
            
            _buildSectionTitle('Notifications'),
            _buildSwitchTile(
              title: 'Enable Notifications',
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                _settingsService.setNotificationsEnabled(value);
              },
            ),
            _buildSwitchTile(
              title: 'Show Goal Reminders',
              value: _showGoalReminder,
              onChanged: (value) {
                setState(() => _showGoalReminder = value);
                _settingsService.setShowGoalReminder(value);
              },
            ),
            _buildDropdown(
              label: 'Notification Interval (minutes)',
              value: _notificationInterval.toString(),
              items: ['30', '60', '90', '120'],
              onChanged: (value) {
                final interval = int.tryParse(value!);
                if (interval != null) {
                  setState(() => _notificationInterval = interval);
                  _settingsService.setNotificationInterval(interval);
                }
              },
            ),
            SizedBox(height: 20),
            
            _buildSectionTitle('Data & Backup'),
            _buildSwitchTile(
              title: 'Auto Backup',
              value: _autoBackup,
              onChanged: (value) {
                setState(() => _autoBackup = value);
                _settingsService.setAutoBackup(value);
              },
            ),
            _buildButton(
              title: 'Export Data',
              onPressed: () => _exportData(),
            ),
            _buildButton(
              title: 'Import Data',
              onPressed: () => _importData(),
            ),
            _buildButton(
              title: 'Clear All Data',
              onPressed: () => _clearAllData(),
              isDestructive: true,
            ),
            SizedBox(height: 20),
            
            _buildSectionTitle('About'),
            _buildInfoTile('App Version', '1.0.0'),
            _buildInfoTile('Build Number', '1'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: title_md,
          fontWeight: FontWeight.bold,
          color: dark,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String title,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? Colors.red : secondary,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(color: white),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  void _exportData() {
    // TODO: Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _importData() {
    // TODO: Implement data import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Import functionality coming soon!')),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text('Are you sure you want to clear all data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AppState>(context, listen: false).clearAllData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('All data cleared successfully!')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}