import 'package:drinktracker/data_json/drinks_json.dart';
import 'package:drinktracker/services/utils_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/cupertino.dart';

class DrinksService {
  Color defaultColor = secondary;

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
  void addDrinks(String name, IconData icon) {
    drinkLists.add(
      {
        "id": drinkLists.length,
        "name": name,
        "icon": icon,
      },
    );
  }
}
