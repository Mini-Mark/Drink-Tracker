import 'dart:convert';
import 'package:drinktracker/data_json/ml_json.dart';
import 'package:drinktracker/repositories/local_storage_repository.dart';

class MLService {
  static const String keyMlList = 'ml_list';
  final LocalStorageRepository _storage = LocalStorageRepository();

  /// Initialize and load ML list from storage
  Future<void> initialize() async {
    await _storage.initialize();
    await _loadMLList();
  }

  /// Load ML list from local storage
  Future<void> _loadMLList() async {
    try {
      final jsonString = _storage.prefs.getString(keyMlList);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        mlList.clear();
        mlList.addAll(jsonList.map((item) => Map<String, dynamic>.from(item)).toList());
      }
    } catch (e) {
      print('Error loading ML list: $e');
    }
  }

  /// Save ML list to local storage
  Future<void> _saveMLList() async {
    try {
      final jsonString = jsonEncode(mlList);
      await _storage.prefs.setString(keyMlList, jsonString);
    } catch (e) {
      print('Error saving ML list: $e');
    }
  }

  /// Get all ML amounts
  List<Map<String, dynamic>> getAllML() {
    return List<Map<String, dynamic>>.from(mlList);
  }

  /// Add a new ML amount
  Future<void> addML(int amount) async {
    mlList.add({"amount": amount});
    mlList.sort((a, b) => a["amount"].compareTo(b["amount"]));
    await _saveMLList();
  }

  /// Update an existing ML amount
  Future<void> updateML(int oldAmount, int newAmount) async {
    final index = mlList.indexWhere((element) => element["amount"] == oldAmount);
    if (index != -1) {
      mlList[index]["amount"] = newAmount;
      mlList.sort((a, b) => a["amount"].compareTo(b["amount"]));
      await _saveMLList();
    }
  }

  /// Delete an ML amount
  Future<void> deleteML(int amount) async {
    mlList.removeWhere((element) => element["amount"] == amount);
    await _saveMLList();
  }
}
