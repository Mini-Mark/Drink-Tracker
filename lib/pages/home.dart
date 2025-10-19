import 'package:drinktracker/data_json/image_src.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/widgets/animated_wave.dart';
import 'package:drinktracker/pages/widgets/aquarium_widget.dart';
import 'package:drinktracker/pages/widgets/ripple_animation.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _showSplash = false;

  @override
  void initState() {
    super.initState();
  }

  refreshHomePage(second) async {
    // Trigger splash animation
    setState(() {
      _showSplash = true;
    });

    Future.delayed(Duration(seconds: second), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        var size = MediaQuery.of(context).size;

        // Get data from AppState
        final selectedDate = appState.selectedDate;
        final currentML = appState.getTotalConsumptionForSelectedDate();
        final dailyRequirement =
            appState.userProfile?.dailyWaterRequirement ?? 2000;

        // Calculate image step based on consumption (with safety checks)
        final waterSteps = imageSrc().water_step;
        int imageStep = 0;
        if (waterSteps.isNotEmpty && dailyRequirement > 0) {
          imageStep = (currentML ~/ (dailyRequirement / waterSteps.length))
              .clamp(0, waterSteps.length - 1);
        }

        // Check if selected date is today
        final today = DateTime.now();
        final isToday = selectedDate.year == today.year &&
            selectedDate.month == today.month &&
            selectedDate.day == today.day;

        return Scaffold(
          backgroundColor: white,
          body: Stack(
            children: [
              Container(
                width: size.width,
                height: size.height,
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  imageSrc().water_step[imageStep],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
              SizedBox(
                width: size.width,
                height: size.height,
                child: AnimatedWaveAnimation(
                  heightPercent: dailyRequirement > 0
                      ? (currentML / dailyRequirement * 100).clamp(0.0, 100.0)
                      : 0.0,
                  callback: refreshHomePage,
                ),
              ),
              // Add aquarium widget
              const AquariumWidget(),
              // Splash animation overlay
              if (_showSplash)
                SplashAnimationOverlay(
                  onComplete: () {
                    if (mounted) {
                      setState(() {
                        _showSplash = false;
                      });
                    }
                  },
                ),
              SafeArea(
                child: Column(children: [
                  CalendarWidget(
                    selectedDate: selectedDate,
                    onChangeFocus: (value) {
                      appState.changeSelectedDate(value);
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Column(
                    children: [
                      Text(
                        isToday
                            ? "Today"
                            : "${selectedDate.year}/${selectedDate.month}/${selectedDate.day}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dark,
                            fontSize: title_lg),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        "$currentML ML",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondary,
                            fontSize: title_xl),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text.rich(TextSpan(children: [
                        const TextSpan(
                          text: "Goal is ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xCCC8C8C8)),
                        ),
                        TextSpan(
                          text: "$dailyRequirement ML",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: dark.withAlpha(200)),
                        )
                      ], style: const TextStyle(fontSize: text_md)))
                    ],
                  ),
                ]),
              ),
              Container(
                  width: size.width,
                  height: size.height,
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: 15.0,
                        right: size.width * 0.05,
                        left: size.width * 0.1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Transform.scale(
                            scale: 0.8,
                            child: Material(
                              elevation: 0,
                              shape: const CircleBorder(),
                              color: white,
                              child: FloatingActionButton(
                                heroTag: null,
                                backgroundColor: secondary,
                                onPressed: () async {
                                  PopupService().show(context,
                                      callback: refreshHomePage,
                                      dialog: const Popup_ChooseDrink(),
                                      outsideHint: "hold to edit");
                                },
                                child: Transform.scale(
                                  scale: 1.4,
                                  child: const Icon(
                                    Icons.add,
                                    color: white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Flexible(
                          child: Transform.scale(
                            scale: 0.8,
                            child: Material(
                              elevation: 0,
                              shape: const CircleBorder(),
                              color: secondary,
                              child: FloatingActionButton(
                                heroTag: null,
                                backgroundColor: secondary,
                                onPressed: () {
                                  try {
                                    Navigator.pushNamed(context, "/statistics");
                                  } catch (e) {
                                    // Error navigating
                                  }
                                },
                                child: Transform.scale(
                                  scale: 1.4,
                                  child: const Icon(
                                    Icons.bar_chart_sharp,
                                    color: white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Flexible(
                          child: Transform.scale(
                            scale: 0.8,
                            child: Material(
                              elevation: 0,
                              shape: const CircleBorder(),
                              color: secondary,
                              child: FloatingActionButton(
                                heroTag: null,
                                backgroundColor: secondary,
                                onPressed: () {
                                  try {
                                    Navigator.pushNamed(context, "/history");
                                  } catch (e) {
                                    // Error navigating
                                  }
                                },
                                child: Transform.scale(
                                  scale: 1.4,
                                  child: const Icon(
                                    Icons.history,
                                    color: white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class CalendarWidget extends StatefulWidget {
  final ValueChanged<DateTime> onChangeFocus;
  final DateTime selectedDate;

  const CalendarWidget({
    Key? key,
    required this.onChangeFocus,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late ScrollController _scrollController;
  bool _isScrollInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isScrollInitialized) {
      _initializeScrollPosition();
    }
  }

  void _initializeScrollPosition() {
    if (_isScrollInitialized) return;
    _isScrollInitialized = true;

    final today = DateTime.now();
    final indexOfToday = today.day - 1;
    var indexOfThreeDaysAgo = indexOfToday - 3;
    indexOfThreeDaysAgo = indexOfThreeDaysAgo < 0 ? 0 : indexOfThreeDaysAgo;

    final size = MediaQuery.of(context).size;
    final targetOffset = indexOfThreeDaysAgo * (size.width * 0.1428);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var today = DateTime.now();
    var firstDayOfMonth = DateTime(today.year, today.month, 1);
    var daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    return SizedBox(
      width: size.width,
      height: size.height * 0.095,
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 10),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: List.generate(
          daysInMonth,
          (index) {
            var currentDate = firstDayOfMonth.add(Duration(days: index));
            bool isToday = currentDate.day == today.day &&
                currentDate.month == today.month &&
                currentDate.year == today.year;

            // Check if this date is the selected date
            bool isSelected = currentDate.year == widget.selectedDate.year &&
                currentDate.month == widget.selectedDate.month &&
                currentDate.day == widget.selectedDate.day;

            return InkWell(
              onTap: (currentDate.day <= today.day)
                  ? () {
                      widget.onChangeFocus(DateTime(currentDate.year,
                          currentDate.month, currentDate.day));
                    }
                  : null,
              child: Container(
                width: size.width * 0.1428,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      getDayOfWeek(currentDate.weekday),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (isToday)
                            ? secondary
                            : (currentDate.day > today.day)
                                ? black.withAlpha(80)
                                : dark,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: 27,
                      height: 27,
                      alignment: Alignment.center,
                      decoration: isSelected
                          ? BoxDecoration(
                              color: white,
                              border: Border.all(color: primary),
                              boxShadow: const [
                                BoxShadow(color: grey, blurRadius: 5)
                              ],
                              borderRadius: BorderRadius.circular(25),
                            )
                          : null,
                      child: Text(
                        "${currentDate.day}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: (isToday)
                              ? secondary
                              : (currentDate.day > today.day)
                                  ? black.withAlpha(80)
                                  : dark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    if (isToday)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: secondary,
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String getDayOfWeek(int day) {
    switch (day) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}
