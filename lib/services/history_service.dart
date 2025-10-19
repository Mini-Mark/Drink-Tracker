import 'package:drinktracker/models/drink_entry.dart';
import 'package:drinktracker/repositories/local_storage_repository.dart';
import 'package:intl/intl.dart';

/// Service for managing drink history
/// This service integrates with the repository layer for data persistence
class HistoryService {
  final LocalStorageRepository _repository;

  HistoryService(this._repository);

  /// Get all drink entries from storage
  Future<List<DrinkEntry>> getAllEntries() async {
    return _repository.getDrinkEntries();
  }

  /// Get entries grouped by date
  /// Returns a map where keys are formatted dates and values are lists of entries
  Future<Map<String, List<DrinkEntry>>> getEntriesGroupedByDate() async {
    final entries = await getAllEntries();
    final Map<String, List<DrinkEntry>> grouped = {};

    for (var entry in entries) {
      if (!grouped.containsKey(entry.date)) {
        grouped[entry.date] = [];
      }
      grouped[entry.date]!.add(entry);
    }

    // Sort entries within each date group by timestamp (newest first)
    grouped.forEach((key, value) {
      value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });

    return grouped;
  }

  /// Delete a drink entry by ID
  Future<void> deleteEntry(String entryId) async {
    final entries = await getAllEntries();
    entries.removeWhere((entry) => entry.id == entryId);
    await _repository.saveDrinkEntries(entries);
  }

  /// Format timestamp for display
  String formatTimestamp(DateTime timestamp) {
    return DateFormat('MM/dd/yyyy hh:mma').format(timestamp);
  }

  /// Format date for grouping
  String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
