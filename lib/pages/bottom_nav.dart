import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:drinktracker/pages/history/main_history.dart';
import 'package:drinktracker/pages/statistics/main_statistics.dart';
import 'package:drinktracker/pages/settings/settings_screen.dart';
import 'package:drinktracker/pages/shop/shop_screen.dart';
import 'package:drinktracker/pages/home.dart';
import 'package:drinktracker/providers/app_state.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavigator extends StatefulWidget {
  final int page;
  const BottomNavigator({super.key, this.page = 0});

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> {
  final iconList = <IconData>[
    Icons.home_rounded,
    Icons.bar_chart_sharp,
    Icons.history,
    Icons.settings,
    Icons.store,
  ];
  final labelList = ["Home", "Statistics", "History", "Settings", "Shop"];
  
  late int _currentIndex;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.page;
    // Initialize pages list with all 5 pages
    _pages = [
      const Home(),
      const MainStatistics(),
      const MainHistory(),
      const SettingsScreen(),
      const ShopScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Navigation bar
          AnimatedBottomNavigationBar.builder(
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
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
}
