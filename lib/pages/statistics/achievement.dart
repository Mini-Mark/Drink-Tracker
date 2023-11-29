import 'package:drinktracker/data_json/achievement_json.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class StatisticsAchievement extends StatefulWidget {
  const StatisticsAchievement({super.key});

  @override
  State<StatisticsAchievement> createState() => _StatisticsAchievementState();
}

class _StatisticsAchievementState extends State<StatisticsAchievement> {
  getSortAchievementList() {
    List<Map<String, dynamic>> sortData = List.from(achievementList);

    sortData
        .sort((a, b) => (b["success"] ? 1 : 0).compareTo(a["success"] ? 1 : 0));

    return sortData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Achievement",
            style: TextStyle(
              fontSize: title_md,
              fontWeight: FontWeight.bold,
              color: light_secondary,
            ),
          ),
        ),
        for (var item in getSortAchievementList())
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _archievement_card(context, item),
          ),
      ]),
    );
  }

  _archievement_card(context, data) {
    return ListTile(
      leading: Icon(
        Icons.emoji_events,
        size: 40,
      ),
      tileColor: data["success"] ? warning : grey,
      textColor: dark,
      iconColor: dark,
      title: Text(
        "${data['name']}",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: title_md),
      ),
      subtitle: Text(
        "${data['detail']}",
      ),
      dense: true,
    );
  }
}
