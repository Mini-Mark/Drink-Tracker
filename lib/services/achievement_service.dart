import '../models/achievement.dart';
import '../models/drink_entry.dart';
import '../models/user_inventory.dart';
import '../repositories/local_storage_repository.dart';

/// Service for managing achievements and tracking user progress
/// Handles achievement initialization, progress checking, and completion detection
class AchievementService {
  final LocalStorageRepository _repository;

  AchievementService(this._repository);

  /// Initialize achievements with 12 predefined achievements
  /// Returns the list of initialized achievements
  List<Achievement> initializeAchievements() {
    return [
      // Drink count achievements
      Achievement(
        id: 'first_sip',
        name: 'First Sip',
        description: 'Add your first drink entry',
        coinReward: 20,
        isCompleted: false,
        progress: 0,
        target: 1,
        type: 'drink_count',
      ),
      Achievement(
        id: 'hydration_beginner',
        name: 'Hydration Beginner',
        description: 'Drink 10 times',
        coinReward: 30,
        isCompleted: false,
        progress: 0,
        target: 10,
        type: 'drink_count',
      ),
      Achievement(
        id: 'hydration_expert',
        name: 'Hydration Expert',
        description: 'Drink 50 times',
        coinReward: 50,
        isCompleted: false,
        progress: 0,
        target: 50,
        type: 'drink_count',
      ),
      Achievement(
        id: 'hydration_master',
        name: 'Hydration Master',
        description: 'Drink 100 times',
        coinReward: 100,
        isCompleted: false,
        progress: 0,
        target: 100,
        type: 'drink_count',
      ),
      
      // Consecutive days achievements
      Achievement(
        id: 'consistent_drinker',
        name: 'Consistent Drinker',
        description: 'Meet your goal 3 days in a row',
        coinReward: 40,
        isCompleted: false,
        progress: 0,
        target: 3,
        type: 'consecutive_days',
      ),
      Achievement(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Meet your goal 7 days in a row',
        coinReward: 70,
        isCompleted: false,
        progress: 0,
        target: 7,
        type: 'consecutive_days',
      ),
      
      // Time-based achievements
      Achievement(
        id: 'early_bird',
        name: 'Early Bird',
        description: 'Drink before 9 AM, 10 times',
        coinReward: 35,
        isCompleted: false,
        progress: 0,
        target: 10,
        type: 'time_based',
      ),
      Achievement(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Drink after 10 PM, 10 times',
        coinReward: 35,
        isCompleted: false,
        progress: 0,
        target: 10,
        type: 'time_based',
      ),
      
      // Volume-based achievement
      Achievement(
        id: 'big_gulp',
        name: 'Big Gulp',
        description: 'Drink more than 500ml in a single serving',
        coinReward: 25,
        isCompleted: false,
        progress: 0,
        target: 1,
        type: 'volume_based',
      ),
      
      // Variety achievement
      Achievement(
        id: 'variety_explorer',
        name: 'Variety Explorer',
        description: 'Try 5 different drinks',
        coinReward: 45,
        isCompleted: false,
        progress: 0,
        target: 5,
        type: 'variety',
      ),
      
      // Aquarium achievements
      Achievement(
        id: 'fish_collector',
        name: 'Fish Collector',
        description: 'Have 3 fish in your aquarium',
        coinReward: 50,
        isCompleted: false,
        progress: 0,
        target: 3,
        type: 'aquarium',
      ),
      Achievement(
        id: 'aquarium_master',
        name: 'Aquarium Master',
        description: 'Have 5 fish in your aquarium',
        coinReward: 100,
        isCompleted: false,
        progress: 0,
        target: 5,
        type: 'aquarium',
      ),
    ];
  }

  /// Check and update all achievements based on current data
  /// Returns list of newly completed achievements
  Future<List<Achievement>> checkAndUpdateAchievements(
    List<DrinkEntry> drinkEntries,
    UserInventory? inventory,
    int dailyWaterRequirement,
  ) async {
    final achievements = _repository.getAchievements();
    
    // If no achievements exist, initialize them
    if (achievements.isEmpty) {
      final initialAchievements = initializeAchievements();
      await _repository.saveAchievements(initialAchievements);
      return [];
    }

    final List<Achievement> newlyCompleted = [];
    final List<Achievement> updatedAchievements = [];

    for (final achievement in achievements) {
      if (achievement.isCompleted) {
        updatedAchievements.add(achievement);
        continue;
      }

      Achievement updated;
      
      switch (achievement.type) {
        case 'drink_count':
          updated = _checkDrinkCount(achievement, drinkEntries);
          break;
        case 'consecutive_days':
          updated = _checkConsecutiveDays(achievement, drinkEntries, dailyWaterRequirement);
          break;
        case 'time_based':
          updated = _checkTimeBased(achievement, drinkEntries);
          break;
        case 'volume_based':
          updated = _checkVolumeBased(achievement, drinkEntries);
          break;
        case 'variety':
          updated = _checkVariety(achievement, drinkEntries);
          break;
        case 'aquarium':
          updated = _checkAquarium(achievement, inventory);
          break;
        default:
          updated = achievement;
      }

      if (!achievement.isCompleted && updated.isCompleted) {
        newlyCompleted.add(updated);
      }

      updatedAchievements.add(updated);
    }

    await _repository.saveAchievements(updatedAchievements);
    return newlyCompleted;
  }

  /// Get all completed achievements
  List<Achievement> getCompletedAchievements() {
    final achievements = _repository.getAchievements();
    return achievements.where((a) => a.isCompleted).toList();
  }

  /// Get all incomplete achievements
  List<Achievement> getIncompleteAchievements() {
    final achievements = _repository.getAchievements();
    return achievements.where((a) => !a.isCompleted).toList();
  }

  /// Check drink count achievements
  Achievement _checkDrinkCount(Achievement achievement, List<DrinkEntry> drinkEntries) {
    final progress = drinkEntries.length;
    final isCompleted = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isCompleted: isCompleted,
      completedAt: isCompleted && achievement.completedAt == null ? DateTime.now() : achievement.completedAt,
    );
  }

  /// Check consecutive days achievements
  Achievement _checkConsecutiveDays(
    Achievement achievement,
    List<DrinkEntry> drinkEntries,
    int dailyWaterRequirement,
  ) {
    if (drinkEntries.isEmpty) {
      return achievement.copyWith(progress: 0);
    }

    // Group entries by date and calculate daily totals
    final Map<String, int> dailyTotals = {};
    for (final entry in drinkEntries) {
      dailyTotals[entry.date] = (dailyTotals[entry.date] ?? 0) + entry.mlAmount;
    }

    // Get dates where goal was met, sorted in descending order
    final goalMetDates = dailyTotals.entries
        .where((e) => e.value >= dailyWaterRequirement)
        .map((e) => DateTime.parse(e.key))
        .toList()
      ..sort((a, b) => b.compareTo(a));

    if (goalMetDates.isEmpty) {
      return achievement.copyWith(progress: 0);
    }

    // Calculate current streak from most recent date
    int currentStreak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Check if the most recent goal met date is today or yesterday
    final mostRecentDate = DateTime(
      goalMetDates.first.year,
      goalMetDates.first.month,
      goalMetDates.first.day,
    );
    
    final daysDifference = todayDate.difference(mostRecentDate).inDays;
    
    // If the most recent date is more than 1 day ago, streak is broken
    if (daysDifference > 1) {
      return achievement.copyWith(progress: 0);
    }

    // Count consecutive days
    for (int i = 1; i < goalMetDates.length; i++) {
      final currentDate = DateTime(
        goalMetDates[i - 1].year,
        goalMetDates[i - 1].month,
        goalMetDates[i - 1].day,
      );
      final previousDate = DateTime(
        goalMetDates[i].year,
        goalMetDates[i].month,
        goalMetDates[i].day,
      );
      
      if (currentDate.difference(previousDate).inDays == 1) {
        currentStreak++;
      } else {
        break;
      }
    }

    final isCompleted = currentStreak >= achievement.target;

    return achievement.copyWith(
      progress: currentStreak,
      isCompleted: isCompleted,
      completedAt: isCompleted && achievement.completedAt == null ? DateTime.now() : achievement.completedAt,
    );
  }

  /// Check time-based achievements (early bird, night owl)
  Achievement _checkTimeBased(Achievement achievement, List<DrinkEntry> drinkEntries) {
    int count = 0;

    for (final entry in drinkEntries) {
      final hour = entry.timestamp.hour;
      
      if (achievement.id == 'early_bird' && hour < 9) {
        count++;
      } else if (achievement.id == 'night_owl' && hour >= 22) {
        count++;
      }
    }

    final isCompleted = count >= achievement.target;

    return achievement.copyWith(
      progress: count,
      isCompleted: isCompleted,
      completedAt: isCompleted && achievement.completedAt == null ? DateTime.now() : achievement.completedAt,
    );
  }

  /// Check volume-based achievements
  Achievement _checkVolumeBased(Achievement achievement, List<DrinkEntry> drinkEntries) {
    int count = 0;

    for (final entry in drinkEntries) {
      if (entry.mlAmount > 500) {
        count++;
      }
    }

    final isCompleted = count >= achievement.target;

    return achievement.copyWith(
      progress: count,
      isCompleted: isCompleted,
      completedAt: isCompleted && achievement.completedAt == null ? DateTime.now() : achievement.completedAt,
    );
  }

  /// Check variety achievements
  Achievement _checkVariety(Achievement achievement, List<DrinkEntry> drinkEntries) {
    final uniqueDrinkIds = drinkEntries.map((e) => e.drinkId).toSet();
    final progress = uniqueDrinkIds.length;
    final isCompleted = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isCompleted: isCompleted,
      completedAt: isCompleted && achievement.completedAt == null ? DateTime.now() : achievement.completedAt,
    );
  }

  /// Check aquarium achievements
  Achievement _checkAquarium(Achievement achievement, UserInventory? inventory) {
    if (inventory == null) {
      return achievement.copyWith(progress: 0);
    }

    final progress = inventory.purchasedFishIds.length;
    final isCompleted = progress >= achievement.target;

    return achievement.copyWith(
      progress: progress,
      isCompleted: isCompleted,
      completedAt: isCompleted && achievement.completedAt == null ? DateTime.now() : achievement.completedAt,
    );
  }
}
