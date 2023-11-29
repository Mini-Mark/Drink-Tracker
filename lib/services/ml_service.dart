import 'package:drinktracker/data_json/ml_json.dart';

class MLService {
  addML(int amount) {
    mlList.add({"amount": amount});
    mlList.sort((a, b) => a["amount"].compareTo(b["amount"]));
  }
}
