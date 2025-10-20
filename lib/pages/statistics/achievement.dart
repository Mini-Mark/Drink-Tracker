import 'package:drinktracker/theme/color.dart';
import 'package:drinktracker/theme/font_size.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/app_state.dart';
import '../../models/achievement.dart';

class StatisticsAchievement extends StatefulWidget {
  const StatisticsAchievement({super.key});

  @override
  State<StatisticsAchievement> createState() => _StatisticsAchievementState();
}

class _StatisticsAchievementState extends State<StatisticsAchievement> {
  List<Achievement> _getSortedAchievements(List<Achievement> achievements) {
    List<Achievement> sortedList = List.from(achievements);
    // Sort: completed first (descending), then incomplete
    sortedList.sort(
        (a, b) => (b.isCompleted ? 1 : 0).compareTo(a.isCompleted ? 1 : 0));
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final sortedAchievements =
            _getSortedAchievements(appState.achievements);

        return Container(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
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
              for (var achievement in sortedAchievements)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _achievementCard(context, achievement),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _achievementCard(BuildContext context, Achievement achievement) {
    final progressPercentage = achievement.target > 0
        ? (achievement.progress / achievement.target * 100).clamp(0, 100)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: achievement.isCompleted ? warning : primary.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 40,
                  color: achievement.isCompleted
                      ? dark
                      : dark.withValues(alpha: 0.5),
                ),
                if (achievement.isCompleted)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: white,
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              achievement.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: title_md,
                color: dark,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.description,
                  style: TextStyle(color: dark),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: achievement.isCompleted
                          ? dark
                          : Color.fromARGB(255, 255, 170, 0),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${achievement.coinReward} coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: text_md,
                        color: dark,
                      ),
                    ),
                  ],
                ),
                if (achievement.isCompleted && achievement.completedAt != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Completed: ${DateFormat('MMM d, yyyy').format(achievement.completedAt!)}',
                      style: TextStyle(
                        fontSize: text_sm,
                        color: dark.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            dense: true,
          ),
          // Progress bar for incomplete achievements
          if (!achievement.isCompleted)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress: ${achievement.progress}/${achievement.target}',
                        style: TextStyle(
                          fontSize: text_md,
                          color: dark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${progressPercentage.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: text_md,
                          color: dark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: white.withValues(alpha: 0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(danger),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
