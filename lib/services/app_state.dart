import 'package:flutter/material.dart';
import 'package:drinktracker/services/database_service.dart';

class AppState extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  // Current state
  List<Map<String, dynamic>> _drinks = [];
  List<Map<String, dynamic>> _todayHistory = [];
  int _todayTotalML = 0;
  int _maximumML = 2500;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get drinks => _drinks;
  List<Map<String, dynamic>> get todayHistory => _todayHistory;
  int get todayTotalML => _todayTotalML;
  int get maximumML => _maximumML;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  
  // Progress percentage
  double get progressPercentage => _todayTotalML / _maximumML;

  // Initialize app state
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _loadSettings();
      await _loadDrinks();
      await _loadTodayHistory();
    } catch (e) {
      print('Error initializing app state: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Settings management
  Future<void> _loadSettings() async {
    _maximumML = await _databaseService.getMaximumML();
    notifyListeners();
  }

  Future<void> updateMaximumML(int ml) async {
    await _databaseService.setMaximumML(ml);
    _maximumML = ml;
    notifyListeners();
  }

  // Drinks management
  Future<void> _loadDrinks() async {
    _drinks = await _databaseService.getAllDrinks();
    notifyListeners();
  }

  Future<String> addDrink(String name, String icon, String? color) async {
    final id = await _databaseService.addDrink(name, icon, color);
    await _loadDrinks();
    return id;
  }

  Future<void> updateDrink(String id, String name, String icon, String? color) async {
    await _databaseService.updateDrink(id, name, icon, color);
    await _loadDrinks();
  }

  Future<void> deleteDrink(String id) async {
    await _databaseService.deleteDrink(id);
    await _loadDrinks();
  }

  // History management
  Future<void> _loadTodayHistory() async {
    _todayHistory = await _databaseService.getHistoryByDate(_selectedDate);
    _todayTotalML = await _databaseService.getTotalMLForDate(_selectedDate);
    notifyListeners();
  }

  Future<void> loadHistoryForDate(DateTime date) async {
    _selectedDate = date;
    await _loadTodayHistory();
  }

  Future<String> addHistoryEntry(String drinksId, int mlAmount) async {
    final id = await _databaseService.addHistoryEntry(drinksId, mlAmount);
    await _loadTodayHistory();
    return id;
  }

  Future<void> deleteHistoryEntry(String id) async {
    await _databaseService.deleteHistoryEntry(id);
    await _loadTodayHistory();
  }

  // Statistics
  Future<Map<String, dynamic>> getWeeklyStats(DateTime startDate) async {
    return await _databaseService.getWeeklyStats(startDate);
  }

  Future<Map<String, dynamic>> getMonthlyStats(int year, int month) async {
    return await _databaseService.getMonthlyStats(year, month);
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadDrinks();
    await _loadTodayHistory();
  }

  // Get drink by ID
  Map<String, dynamic>? getDrinkById(String id) {
    try {
      return _drinks.firstWhere((drink) => drink['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Get drink icon data
  IconData getDrinkIcon(String iconString) {
    switch (iconString) {
      case 'Icons.water_drop':
        return Icons.water_drop;
      case 'Icons.coffee':
        return Icons.coffee;
      case 'Icons.local_cafe':
        return Icons.local_cafe;
      case 'Icons.local_bar':
        return Icons.local_bar;
      case 'Icons.local_drink':
        return Icons.local_drink;
      case 'Icons.sports_bar':
        return Icons.sports_bar;
      case 'Icons.local_pizza':
        return Icons.local_pizza;
      case 'Icons.icecream':
        return Icons.icecream;
      case 'Icons.cake':
        return Icons.cake;
      default:
        return Icons.water_drop;
    }
  }

  // Get drink color
  Color getDrinkColor(String? colorString) {
    if (colorString == null) return Colors.blue;
    
    switch (colorString) {
      case '#2196F3':
        return Colors.blue;
      case '#795548':
        return Colors.brown;
      case '#4CAF50':
        return Colors.green;
      case '#FF9800':
        return Colors.orange;
      case '#E91E63':
        return Colors.pink;
      case '#9C27B0':
        return Colors.purple;
      case '#F44336':
        return Colors.red;
      case '#607D8B':
        return Colors.blueGrey;
      default:
        return Colors.blue;
    }
  }

  // Database maintenance
  Future<void> clearAllData() async {
    await _databaseService.clearAllData();
    await initialize();
  }
}