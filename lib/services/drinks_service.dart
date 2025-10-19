import 'dart:convert';
import 'package:drinktracker/data_json/drinks_json.dart';
import 'package:drinktracker/repositories/local_storage_repository.dart';
import 'package:drinktracker/services/utils_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/cupertino.dart';

class DrinksService {
  static const String KEY_DRINKS_LIST = 'drinks_list';
  Color defaultColor = secondary;
  final LocalStorageRepository _storage = LocalStorageRepository();

  /// Initialize and load drinks from storage
  Future<void> initialize() async {
    await _storage.initialize();
    await _loadDrinks();
  }

  /// Load drinks from local storage
  Future<void> _loadDrinks() async {
    try {
      final jsonString = _storage.prefs.getString(KEY_DRINKS_LIST);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        drinkLists.clear();
        for (var item in jsonList) {
          final Map<String, dynamic> drink = Map<String, dynamic>.from(item);
          // Convert icon code back to IconData
          if (drink['iconCode'] != null) {
            drink['icon'] = IconData(drink['iconCode'], fontFamily: 'MaterialIcons');
            drink.remove('iconCode');
          }
          drinkLists.add(drink);
        }
      }
    } catch (e) {
      print('Error loading drinks: $e');
    }
  }

  /// Save drinks to local storage
  Future<void> _saveDrinks() async {
    try {
      // Convert IconData to icon codes for serialization
      final List<Map<String, dynamic>> serializableDrinks = drinkLists.map((drink) {
        final Map<String, dynamic> serializableDrink = Map<String, dynamic>.from(drink);
        if (serializableDrink['icon'] is IconData) {
          serializableDrink['iconCode'] = (serializableDrink['icon'] as IconData).codePoint;
          serializableDrink.remove('icon');
        }
        return serializableDrink;
      }).toList();
      
      final jsonString = jsonEncode(serializableDrinks);
      await _storage.prefs.setString(KEY_DRINKS_LIST, jsonString);
    } catch (e) {
      print('Error saving drinks: $e');
    }
  }

  /// Get drink information by ID
  /// Returns a map containing drink details including name, icon, and color
  Map<String, dynamic> getDrinksByID(int id) {
    var result =
        Map<String, dynamic>.from(drinkLists.firstWhere((element) => element["id"] == id));

    result["color"] = result["color"] != null
        ? UtilsService().hexToColor(result["color"])
        : defaultColor;

    return result;
  }

  /// Get all available drinks
  List<Map<String, dynamic>> getAllDrinks() {
    return List<Map<String, dynamic>>.from(drinkLists);
  }

  /// Get drink name by ID
  String getDrinkNameByID(int id) {
    try {
      var drink = drinkLists.firstWhere((element) => element["id"] == id);
      return drink["name"] as String;
    } catch (e) {
      return "Unknown Drink";
    }
  }

  /// Add a new drink type (for future extensibility)
  Future<void> addDrinks(String name, IconData icon, {String? color}) async {
    final newDrink = {
      "id": drinkLists.length,
      "name": name,
      "icon": icon,
    };
    if (color != null) {
      newDrink["color"] = color;
    }
    drinkLists.add(newDrink);
    await _saveDrinks();
  }

  /// Update an existing drink
  Future<void> updateDrinks(int id, String name, IconData icon,
      {String? color}) async {
    final index = drinkLists.indexWhere((element) => element["id"] == id);
    if (index != -1) {
      drinkLists[index]["name"] = name;
      drinkLists[index]["icon"] = icon;
      if (color != null) {
        drinkLists[index]["color"] = color;
      }
      await _saveDrinks();
    }
  }

  /// Delete a drink by ID
  Future<void> deleteDrinks(int id) async {
    drinkLists.removeWhere((element) => element["id"] == id);
    await _saveDrinks();
  }
}
