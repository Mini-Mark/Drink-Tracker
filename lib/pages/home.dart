import 'package:drinktracker/data_json/app_settings.dart';
import 'package:drinktracker/data_json/history.json.dart';
import 'package:drinktracker/data_json/image_src.dart';
import 'package:drinktracker/pages/popup/manage_drinks/choose_drinks.dart';
import 'package:drinktracker/pages/widgets/animated_wave.dart';
import 'package:drinktracker/services/popup_service.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DateTime _currentDate;

  DateTime _today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    _currentDate = _today;
    super.initState();
  }

  refreshHomePage(second) async {
    Future.delayed(Duration(seconds: second), () {
      setState(() {});
      print("refresh");
    });
  }

  int getML() {
    String targetDateString =
        "${_currentDate.month}/${_currentDate.day}/${_currentDate.year}";

    dynamic entriesOnTargetDate = historyList.where((entry) {
      DateTime entryDate = parseDate(entry["datetime"]);
      String entryDateString =
          "${entryDate.month}/${entryDate.day}/${entryDate.year}";
      return entryDateString == targetDateString;
    }).toList();

    int totalML =
        entriesOnTargetDate.fold(0, (sum, entry) => sum + entry["ml_amount"]);

    return totalML;
  }

  // Parse the date string in the format "MM/DD/YYYY hh:mma"
  DateTime parseDate(String dateString) {
    List<String> parts = dateString.split(new RegExp(r'[ /:]'));
    int month = int.parse(parts[0]);
    int day = int.parse(parts[1]);
    int year = int.parse(parts[2]);

    return DateTime(year, month, day);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    int imageStep =
        (getML() ~/ (appSettings['maximum_ML'] / imageSrc().water_step.length))
            .clamp(0, imageSrc().water_step.length - 1);

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
            ),
          ),
          Container(
              width: size.width,
              height: size.height,
              child: AnimatedWaveAnimation(
                heightPercent: getML() / appSettings['maximum_ML'] * 100,
                callback: refreshHomePage,
              )),
          SafeArea(
            child: Column(children: [
              CalendarWidget(
                onChangeFocus: (value) {
                  setState(() {
                    _currentDate = value;
                  });
                },
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      (_currentDate == _today)
                          ? "Today"
                          : "${_currentDate.year}/${_currentDate.month}/${_currentDate.day}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: dark,
                          fontSize: title_lg),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "${getML()} ML",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: secondary,
                          fontSize: title_xl),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: "Goal is ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: black.withAlpha(80)),
                      ),
                      TextSpan(
                        text: "${appSettings['maximum_ML']} ML",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: dark.withAlpha(200)),
                      )
                    ], style: TextStyle(fontSize: text_md)))
                  ],
                ),
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
                          shape: CircleBorder(),
                          color: white,
                          child: FloatingActionButton(
                            heroTag: null,
                            backgroundColor: secondary,
                            onPressed: () async {
                              PopupService().show(context,
                                  callback: refreshHomePage,
                                  dialog: Popup_ChooseDrink(),
                                  outsideHint: "hold to edit");
                            },
                            child: Transform.scale(
                              scale: 1.4,
                              child: Icon(
                                Icons.add,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      child: Transform.scale(
                        scale: 0.8,
                        child: Material(
                          elevation: 0,
                          shape: CircleBorder(),
                          color: secondary,
                          child: FloatingActionButton(
                            heroTag: null,
                            backgroundColor: secondary,
                            onPressed: () {
                              try {
                                Navigator.pushNamed(context, "/statistics");
                              } catch (e) {
                                print("Error navigating to statictis: $e");
                              }
                            },
                            child: Transform.scale(
                              scale: 1.4,
                              child: Icon(
                                Icons.bar_chart_sharp,
                                color: white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      child: Transform.scale(
                        scale: 0.8,
                        child: Material(
                          elevation: 0,
                          shape: CircleBorder(),
                          color: secondary,
                          child: FloatingActionButton(
                            heroTag: null,
                            backgroundColor: secondary,
                            onPressed: () {
                              try {
                                Navigator.pushNamed(context, "/history");
                              } catch (e) {
                                print("Error navigating to history: $e");
                              }
                            },
                            child: Transform.scale(
                              scale: 1.4,
                              child: Icon(
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
  }
}

class CalendarWidget extends StatefulWidget {
  final ValueChanged<DateTime> onChangeFocus;

  const CalendarWidget({Key? key, required this.onChangeFocus})
      : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  int _focusDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var today = DateTime.now();
    var firstDayOfMonth = DateTime(today.year, today.month, 1);
    var daysInMonth = DateTime(today.year, today.month + 1, 0).day;

    var indexOfToday = today.day - 1;
    var indexOfThreeDaysAgo = indexOfToday - 3;
    indexOfThreeDaysAgo = indexOfThreeDaysAgo < 0 ? 0 : indexOfThreeDaysAgo;

    var scrollController = ScrollController(
        initialScrollOffset: indexOfThreeDaysAgo * (size.width * 0.1428));

    return Container(
      width: size.width,
      height: size.height * 0.095,
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.only(top: 10),
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: List.generate(
          daysInMonth,
          (index) {
            var currentDate = firstDayOfMonth.add(Duration(days: index));
            bool isToday = currentDate.day == today.day &&
                currentDate.month == today.month &&
                currentDate.year == today.year;

            return InkWell(
              onTap: (currentDate.day <= today.day)
                  ? () {
                      setState(() {
                        _focusDay = currentDate.day;
                      });

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
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      width: 27,
                      height: 27,
                      alignment: Alignment.center,
                      decoration: (_focusDay == currentDate.day)
                          ? BoxDecoration(
                              color: white,
                              border: Border.all(color: primary),
                              boxShadow: [
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
                    SizedBox(height: 7),
                    if (isToday)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: secondary, // Change to your desired color
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
