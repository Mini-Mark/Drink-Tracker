import 'package:drinktracker/data_json/ml_json.dart';

class MLService {
  addML(int amount) {
    mlList.add({"amount": amount});
    mlList.sort((a, b) => a["amount"].compareTo(b["amount"]));
  }

  /// Update an existing ML amount
  void updateML(int oldAmount, int newAmount) {
    final index = mlList.indexWhere((element) => element["amount"] == oldAmount);
    if (index != -1) {
      mlList[index]["amount"] = newAmount;
      mlList.sort((a, b) => a["amount"].compareTo(b["amount"]));
    }
  }

  /// Delete an ML amount
  void deleteML(int amount) {
    mlList.removeWhere((element) => element["amount"] == amount);
  }
}
