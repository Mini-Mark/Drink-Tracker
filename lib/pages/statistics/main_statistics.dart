import 'package:drinktracker/pages/statistics/achievement.dart';
import 'package:drinktracker/pages/statistics/graph.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';

class MainStatistics extends StatefulWidget {
  const MainStatistics({super.key});

  @override
  State<MainStatistics> createState() => _MainStatisticsState();
}

class _MainStatisticsState extends State<MainStatistics> {
  @override
  Widget build(BuildContext context) {
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
                    "Statistics",
                    style: TextStyle(
                        fontSize: title_lg,
                        fontWeight: FontWeight.bold,
                        color: light_secondary),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  StatisticsGraph(),
                  SizedBox(
                    height: 5,
                  ),
                  StatisticsAchievement()
                ]),
          )),
    ));
  }
}
