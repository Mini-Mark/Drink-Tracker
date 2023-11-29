import 'package:drinktracker/data_json/history.json.dart';
import 'package:drinktracker/pages/bottom_nav.dart';
import 'package:drinktracker/services/drinks_service.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class MainHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    String lastDateLabel = '';

    return SafeArea(
      child: Scrollbar(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "History",
                  style: TextStyle(
                      fontSize: title_lg,
                      fontWeight: FontWeight.bold,
                      color: light_secondary),
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _getUniqueDateCount(historyList),
                      itemBuilder: (context, index) {
                        final uniqueDates = _getUniqueDates(historyList);
                        final currentDate = DateTime.now();
                        final itemDate = uniqueDates[index];
                        final difference =
                            currentDate.difference(itemDate).inDays;

                        String dateLabel = '';

                        if (difference == 0) {
                          dateLabel = 'Today';
                        } else if (difference == 1) {
                          dateLabel = 'Yesterday';
                        } else {
                          dateLabel = DateFormat("MM/dd/yyyy").format(itemDate);
                        }

                        final itemsForDate = historyList.where((item) {
                          final itemDate =
                              DateFormat("MM/dd/yyyy").parse(item['datetime']);
                          return itemDate.isAtSameMomentAs(uniqueDates[index]);
                        }).toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: index == 0 ? 0 : 20, bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateLabel,
                                    style: TextStyle(
                                      fontSize: title_md,
                                      fontWeight: FontWeight.bold,
                                      color: light_secondary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "swipe-left to edit",
                                        style: TextStyle(
                                            fontSize: text_sm, color: black),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Icon(
                                        Icons.swipe_left_alt,
                                        color: dark,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: size.width,
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: itemsForDate.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: _history_card(
                                        context, itemsForDate[index]),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getUniqueDateCount(historyList) {
    final uniqueDates = _getUniqueDates(historyList);
    return uniqueDates.length;
  }

  List<DateTime> _getUniqueDates(historyList) {
    final dateSet = <DateTime>{};
    for (var item in historyList) {
      final itemDate = DateFormat("MM/dd/yyyy").parse(item['datetime']);
      dateSet.add(itemDate);
    }
    return dateSet.toList()..sort((a, b) => b.compareTo(a));
  }

  Widget _history_card(context, data) {
    var drinkData = DrinksService().getDrinksByID(data['drinks_id']);

    return Slidable(
        endActionPane: ActionPane(
          motion: DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: null,
              backgroundColor: white,
              label: '',
              flex: 1,
            ),
            SlidableAction(
              onPressed: (context) {},
              backgroundColor: warning,
              foregroundColor: dark,
              icon: Icons.edit,
              label: 'Edit',
              flex: 6,
            ),
            SlidableAction(
              onPressed: null,
              backgroundColor: white,
              label: '',
              flex: 1,
            ),
            SlidableAction(
              onPressed: (context) {},
              backgroundColor: danger,
              foregroundColor: dark,
              icon: Icons.delete,
              label: 'Delete',
              flex: 6,
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            drinkData["icon"],
            size: 40,
          ),
          tileColor: grey,
          textColor: dark,
          iconColor: dark,
          title: Text(
            drinkData['name'],
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: title_md),
          ),
          subtitle: Text(
            "${data['ml_amount']}ml",
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${data['datetime'].split(' ')[1]}",
                style: TextStyle(color: dark.withAlpha(100)),
              ),
              Text(
                "${data['datetime'].split(' ')[0]}",
                style: TextStyle(color: dark.withAlpha(100)),
              ),
            ],
          ),
          dense: true,
        ));
  }
}
