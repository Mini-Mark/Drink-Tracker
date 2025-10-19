import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/drink_entry.dart';
import '../repositories/local_storage_repository.dart';

/// Service for managing water tracking and drink entries
/// Handles adding drinks, retrieving consumption data, and aggregating statistics
class WaterTrackingService {
  final LocalStorageRepository _repository;
  final Uuid _uuid = const Uuid();

  WaterTrackingService(this._repository);

  /// Add a new drink entry with UUID generation and timestamp
  /// Returns the created DrinkEntry
  Future<DrinkEntry> addDrinkEntry(int drinkId, int mlAmount) async {
    final now = DateTime.now();
    final dateString = _formatDate(now);

    final entry = DrinkEntry(
      id: _uuid.v4(),
      drinkId: drinkId,
      mlAmount: mlAmount,
      timestamp: now,
      date: dateString,
    );

    // Get existing entries and add the new one
    final entries = _repository.getDrinkEntries();
    entries.add(entry);
    await _repository.saveDrinkEntries(entries);

    return entry;
  }

  /// Get all drink entries for a specific date
  /// Date filtering is done by comparing the date string (YYYY-MM-DD)
  List<DrinkEntry> getDrinkEntriesForDate(DateTime date) {
    final dateString = _formatDate(date);
    final allEntries = _repository.getDrinkEntries();
    
    return allEntries.where((entry) => entry.date == dateString).toList();
  }

  /// Get total water consumption in ml for a specific date
  int getTotalConsumptionForDate(DateTime date) {
    final entries = getDrinkEntriesForDate(date);
    return entries.fold(0, (sum, entry) => sum + entry.mlAmount);
  }

  /// Get drink entries for a date range (inclusive)
  List<DrinkEntry> getDrinkEntriesForDateRange(DateTime start, DateTime end) {
    final allEntries = _repository.getDrinkEntries();
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return allEntries.where((entry) {
      return entry.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             entry.timestamp.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  /// Get weekly consumption data for the last 7 days
  /// Returns a map where keys are date strings (YYYY-MM-DD) and values are total ml consumed
  Map<String, int> getWeeklyConsumption() {
    final now = DateTime.now();
    final Map<String, int> weeklyData = {};

    // Generate last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = _formatDate(date);
      weeklyData[dateString] = getTotalConsumptionForDate(date);
    }

    return weeklyData;
  }

  /// Get monthly consumption data for the last 30 days
  /// Returns a map where keys are date strings (YYYY-MM-DD) and values are total ml consumed
  Map<String, int> getMonthlyConsumption() {
    final now = DateTime.now();
    final Map<String, int> monthlyData = {};

    // Generate last 30 days
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = _formatDate(date);
      monthlyData[dateString] = getTotalConsumptionForDate(date);
    }

    return monthlyData;
  }

  /// Delete a drink entry by ID
  Future<void> deleteDrinkEntry(String entryId) async {
    final entries = _repository.getDrinkEntries();
    entries.removeWhere((entry) => entry.id == entryId);
    await _repository.saveDrinkEntries(entries);
  }

  /// Format date to YYYY-MM-DD string
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
