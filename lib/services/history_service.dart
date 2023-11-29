import 'package:drinktracker/data_json/history.json.dart';
import 'package:intl/intl.dart';

class HistoryService {
  addHistory({required int drinksID, required int amount}) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('MM/dd/yyyy hh:mma').format(now);
    historyList.add({
      "drinks_id": drinksID,
      "ml_amount": amount,
      "datetime": formattedDate,
    });
  }
}
