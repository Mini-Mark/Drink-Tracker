import 'package:drinktracker/theme/color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';

class StatisticsGraph extends StatefulWidget {
  const StatisticsGraph({super.key});

  @override
  State<StatisticsGraph> createState() => _StatisticsGraphState();
}

enum ChartPeriod { daily, weekly, monthly }

class _StatisticsGraphState extends State<StatisticsGraph> {
  List<String> categories = ["Daily", "Weekly", "Monthly"];

  ChartPeriod _activePeriod = ChartPeriod.daily;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final appState = Provider.of<AppState>(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10, top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(categories.length, (index) {
              final period = ChartPeriod.values[index];
              return InkWell(
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    _activePeriod = period;
                  });
                },
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: _activePeriod == period ? grey.withValues(alpha: 100 / 255) : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      categories[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(
          width: size.width,
          height: 250,
          child: BarChartWidget(period: _activePeriod, appState: appState),
        )
      ],
    );
  }

}

class BarChartWidget extends StatefulWidget {
  final ChartPeriod period;
  final AppState appState;
  
  const BarChartWidget({
    super.key,
    required this.period,
    required this.appState,
  });

  @override
  State<StatefulWidget> createState() => BarChartWidgetState();
}

class BarChartWidgetState extends State<BarChartWidget> {
  final double width = 20;
  final Color barColor = danger;
  final Color avgColor = primary;

  late List<BarChartGroupData> rawBarGroups;
  late List<BarChartGroupData> showingBarGroups;
  late List<String> bottomTitles;
  late double maxY;

  int touchedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  @override
  void didUpdateWidget(BarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period || oldWidget.appState != widget.appState) {
      _updateChartData();
    }
  }

  /// Update chart data based on selected period
  void _updateChartData() {
    final chartData = _getChartData();
    rawBarGroups = chartData['barGroups'] as List<BarChartGroupData>;
    showingBarGroups = rawBarGroups;
    bottomTitles = chartData['labels'] as List<String>;
    maxY = chartData['maxY'] as double;
  }

  /// Get chart data based on the selected period
  Map<String, dynamic> _getChartData() {
    switch (widget.period) {
      case ChartPeriod.daily:
        return _getDailyChartData();
      case ChartPeriod.weekly:
        return _getWeeklyChartData();
      case ChartPeriod.monthly:
        return _getMonthlyChartData();
    }
  }

  /// Get daily chart data: last 7 days consumption
  Map<String, dynamic> _getDailyChartData() {
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];
    double maxValue = 0;

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final consumption = widget.appState.getTotalConsumptionForDate(date);
      final consumptionInLiters = consumption / 1000.0;
      
      if (consumptionInLiters > maxValue) {
        maxValue = consumptionInLiters;
      }

      barGroups.add(makeGroupData(6 - i, consumptionInLiters));
      
      // Format label as day abbreviation (Mon, Tue, etc.)
      labels.add(DateFormat('EEE').format(date).substring(0, 2));
    }

    // Set maxY to a reasonable value (at least 2L, rounded up)
    final calculatedMaxY = maxValue > 0 ? (maxValue * 1.2).ceilToDouble() : 2.0;

    return {
      'barGroups': barGroups,
      'labels': labels,
      'maxY': calculatedMaxY < 2.0 ? 2.0 : calculatedMaxY,
    };
  }

  /// Get weekly chart data: last 4 weeks consumption
  Map<String, dynamic> _getWeeklyChartData() {
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];
    double maxValue = 0;

    for (int i = 3; i >= 0; i--) {
      // Calculate week start (7 days ago for each week)
      final weekEnd = now.subtract(Duration(days: i * 7));
      final weekStart = weekEnd.subtract(const Duration(days: 6));
      
      // Sum consumption for the week
      double weekConsumption = 0;
      for (int day = 0; day < 7; day++) {
        final date = weekStart.add(Duration(days: day));
        weekConsumption += widget.appState.getTotalConsumptionForDate(date);
      }
      
      final weekConsumptionInLiters = weekConsumption / 1000.0;
      
      if (weekConsumptionInLiters > maxValue) {
        maxValue = weekConsumptionInLiters;
      }

      barGroups.add(makeGroupData(3 - i, weekConsumptionInLiters));
      
      // Format label as "W1", "W2", etc.
      labels.add('W${4 - i}');
    }

    // Set maxY to a reasonable value (at least 10L for weekly, rounded up)
    final calculatedMaxY = maxValue > 0 ? (maxValue * 1.2).ceilToDouble() : 10.0;

    return {
      'barGroups': barGroups,
      'labels': labels,
      'maxY': calculatedMaxY < 10.0 ? 10.0 : calculatedMaxY,
    };
  }

  /// Get monthly chart data: last 6 months consumption
  Map<String, dynamic> _getMonthlyChartData() {
    final now = DateTime.now();
    final List<BarChartGroupData> barGroups = [];
    final List<String> labels = [];
    double maxValue = 0;

    for (int i = 5; i >= 0; i--) {
      // Calculate month
      final monthDate = DateTime(now.year, now.month - i, 1);
      
      // Get number of days in the month
      final nextMonth = DateTime(monthDate.year, monthDate.month + 1, 1);
      final lastDayOfMonth = nextMonth.subtract(const Duration(days: 1));
      final daysInMonth = lastDayOfMonth.day;
      
      // Sum consumption for the month
      double monthConsumption = 0;
      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(monthDate.year, monthDate.month, day);
        // Only count days up to today if it's the current month
        if (date.isAfter(now)) break;
        monthConsumption += widget.appState.getTotalConsumptionForDate(date);
      }
      
      final monthConsumptionInLiters = monthConsumption / 1000.0;
      
      if (monthConsumptionInLiters > maxValue) {
        maxValue = monthConsumptionInLiters;
      }

      barGroups.add(makeGroupData(5 - i, monthConsumptionInLiters));
      
      // Format label as month abbreviation (Jan, Feb, etc.)
      labels.add(DateFormat('MMM').format(monthDate));
    }

    // Set maxY to a reasonable value (at least 30L for monthly, rounded up)
    final calculatedMaxY = maxValue > 0 ? (maxValue * 1.2).ceilToDouble() : 30.0;

    return {
      'barGroups': barGroups,
      'labels': labels,
      'maxY': calculatedMaxY < 30.0 ? 30.0 : calculatedMaxY,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toStringAsFixed(1)}L',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, response) {
                      if (response == null || response.spot == null) {
                        setState(() {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                        });
                        return;
                      }

                      touchedGroupIndex = response.spot!.touchedBarGroupIndex;

                      setState(() {
                        if (!event.isInterestedForInteractions) {
                          touchedGroupIndex = -1;
                          showingBarGroups = List.of(rawBarGroups);
                          return;
                        }
                        showingBarGroups = List.of(rawBarGroups);
                        if (touchedGroupIndex != -1) {
                          var sum = 0.0;
                          for (final rod
                              in showingBarGroups[touchedGroupIndex].barRods) {
                            sum += rod.toY;
                          }
                          final avg = sum /
                              showingBarGroups[touchedGroupIndex]
                                  .barRods
                                  .length;

                          showingBarGroups[touchedGroupIndex] =
                              showingBarGroups[touchedGroupIndex].copyWith(
                            barRods: showingBarGroups[touchedGroupIndex]
                                .barRods
                                .map((rod) {
                              return rod.copyWith(
                                  toY: avg, color: avgColor);
                            }).toList(),
                          );
                        }
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getBottomTitles,
                        reservedSize: 50,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: getLeftTitles,
                      ),
                    ),
                  ),
                  borderData:
                      FlBorderData(show: true, border: Border.all(color: grey)),
                  gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: grey.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: grey.withValues(alpha: 0.3),
                          strokeWidth: 1,
                        );
                      }),
                  barGroups: showingBarGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get left axis titles (Y-axis) showing liters
  Widget getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    
    String text = '${value.toInt()}L';
    
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(text, style: style),
    );
  }

  /// Get bottom axis titles (X-axis) showing dates/periods
  Widget getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff7589a2),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    final index = value.toInt();
    if (index < 0 || index >= bottomTitles.length) {
      return const SizedBox.shrink();
    }

    final Widget text = Text(
      bottomTitles[index],
      style: style,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  /// Create bar chart group data
  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      barsSpace: 4,
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: barColor,
          width: width,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
        ),
      ],
    );
  }
}
