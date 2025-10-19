import '../repositories/local_storage_repository.dart';
import '../models/user_inventory.dart';
import '../models/achievement.dart';

class CoinService {
  final LocalStorageRepository _repository;

  CoinService(this._repository);

  /// Get the current coin balance from user inventory
  int getCoinBalance() {
    try {
      final inventory = _repository.getUserInventory();
      return inventory?.coinBalance ?? 0;
    } catch (e) {
      throw Exception('Failed to get coin balance: $e');
    }
  }

  /// Add coins to the user's balance with a reason for tracking
  Future<void> addCoins(int amount, String reason) async {
    if (amount < 0) {
      throw ArgumentError('Cannot add negative coins');
    }

    try {
      final inventory = _repository.getUserInventory() ?? _createDefaultInventory();
      final updatedInventory = inventory.copyWith(
        coinBalance: inventory.coinBalance + amount,
      );
      await _repository.saveUserInventory(updatedInventory);
    } catch (e) {
      throw Exception('Failed to add coins: $e');
    }
  }

  /// Deduct coins from the user's balance
  /// Returns true if successful, false if insufficient balance
  Future<bool> deductCoins(int amount) async {
    if (amount < 0) {
      throw ArgumentError('Cannot deduct negative coins');
    }

    try {
      final inventory = _repository.getUserInventory() ?? _createDefaultInventory();
      
      // Check if user has enough coins
      if (inventory.coinBalance < amount) {
        return false;
      }

      final updatedInventory = inventory.copyWith(
        coinBalance: inventory.coinBalance - amount,
      );
      await _repository.saveUserInventory(updatedInventory);
      return true;
    } catch (e) {
      throw Exception('Failed to deduct coins: $e');
    }
  }

  /// Award coins when user meets their daily water goal
  /// Awards 10 coins as specified in requirements
  Future<void> awardDailyGoalCoins() async {
    const int dailyGoalReward = 10;
    await addCoins(dailyGoalReward, 'Daily goal completed');
  }

  /// Award coins when user completes an achievement
  /// Uses the coinReward value from the achievement
  Future<void> awardAchievementCoins(Achievement achievement) async {
    if (!achievement.isCompleted) {
      throw ArgumentError('Cannot award coins for incomplete achievement');
    }

    await addCoins(
      achievement.coinReward,
      'Achievement completed: ${achievement.name}',
    );
  }

  /// Create a default inventory if none exists
  UserInventory _createDefaultInventory() {
    return UserInventory(
      coinBalance: 0,
      purchasedFishIds: [],
      purchasedDecorationIds: [],
      activeFishIds: [],
      activeDecorationIds: [],
    );
  }
}
