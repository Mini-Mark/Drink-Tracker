import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:drinktracker/pages/history/main_history.dart';
import 'package:drinktracker/pages/home.dart';
import 'package:drinktracker/pages/statistics/main_statistics.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class BottomNavigator extends StatefulWidget {
  int page;
  BottomNavigator({super.key, this.page = 0});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.bar_chart_sharp,
    Icons.history,
  ];
  final labelList = ["Home", "Statistics", "History"];
  final routeList = [null, MainStatistics(), MainHistory()];

  late int _currentIndex;

  @override
  void initState() {
    _currentIndex = widget.page;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: routeList[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          itemCount: iconList.length,
          gapLocation: GapLocation.none,
          tabBuilder: (int index, bool isActive) {
            final color = isActive ? white : white.withAlpha(125);
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconList[index],
                  size: 24,
                  color: color,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: AutoSizeText(
                    labelList[index],
                    maxLines: 1,
                    style: TextStyle(color: color),
                  ),
                )
              ],
            );
          },
          backgroundColor: light_secondary,
          activeIndex: _currentIndex,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          onTap: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, "/home");
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          }),
    );
  }
}
