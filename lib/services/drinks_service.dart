import 'package:drinktracker/data_json/drinks_json.dart';
import 'package:drinktracker/services/utils_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';

class DrinksService {
  Color defaultColor = secondary;

  getDrinksByID(id) {
    var result =
        Map.from(drinkLists.firstWhere((element) => element["id"] == id));

    result["color"] = result["color"] != null
        ? UtilsService().HexToColor(result["color"])
        : defaultColor;

    return result;
  }

  addDrinks(String name, IconData icon) {
    drinkLists.add(
      {
        "id": drinkLists.length,
        "name": name,
        "icon": icon,
      },
    );
  }
}
