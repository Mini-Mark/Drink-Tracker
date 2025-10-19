import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/drink_entry.dart';
import '../models/achievement.dart';
import '../models/user_inventory.dart';
import '../models/fish.dart';
import '../models/decoration.dart';
import '../services/profile_service.dart';
import '../services/water_tracking_service.dart';
import '../services/achievement_service.dart';
import '../services/coin_service.dart';
import '../services/shop_service.dart';
import '../services/aquarium_service.dart';
import '../repositories/local_storage_repository.dart';

/// Central state management for the Drink Tracker app
/// Manages all app state and coordinates between services
class AppState extends ChangeNotifier {
  // Service dependencies
  final LocalStorageRepository _repository;
  final ProfileService _profileService;
  final WaterTrackingService _waterTrackingService;
  final AchievementService _achievementService;
  final CoinService _coinService;
  final ShopService _shopService;
  final AquariumService _aquariumService;

  // State properties
  UserProfile? _userProfile;
  List<DrinkEntry> _drinkEntries = [];
  List<Achievement> _achievements = [];
  UserInventory? _inventory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  // Constructor with service injection
  AppState({
    required LocalStorageRepository repository,
    required ProfileService profileService,
    required WaterTrackingService waterTrackingService,
    required AchievementService achievementService,
    required CoinService coinService,
    required ShopService shopService,
    required AquariumService aquariumService,
  })  : _repository = repository,
        _profileService = profileService,
        _waterTrackingService = waterTrackingService,
        _achievementService = achievementService,
        _coinService = coinService,
        _shopService = shopService,
        _aquariumService = aquariumService;

  // Getters for state properties
  UserProfile? get userProfile => _userProfile;
  List<DrinkEntry> get drinkEntries => _drinkEntries;
  List<Achievement> get achievements => _achievements;
  UserInventory? get inventory => _inventory;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;

  // Initialization and data loading methods

  /// Load all initial data from repository
  /// Should be called when app starts
  Future<void> loadInitialData() async {
    _setLoading(true);
    
    try {
      // Load user profile
      _userProfile = await _profileService.getProfile();
      
      // Load drink entries
      _drinkEntries = _repository.getDrinkEntries();
      
      // Load achievements (initialize if empty)
      _achievements = _repository.getAchievements();
      if (_achievements.isEmpty) {
        _achievements = _achievementService.initializeAchievements();
        await _repository.saveAchievements(_achievements);
      }
      
      // Load user inventory (create default if null)
      _inventory = _repository.getUserInventory();
      if (_inventory == null) {
        _inventory = UserInventory(
          coinBalance: 0,
          purchasedFishIds: [],
          purchasedDecorationIds: [],
          activeFishIds: [],
          activeDecorationIds: [],
        );
        await _repository.saveUserInventory(_inventory!);
      }
      
      // Set selected date to today
      _selectedDate = DateTime.now();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading initial data: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Check if user has completed onboarding
  /// Returns true if onboarding is complete, false otherwise
  bool checkOnboardingStatus() {
    try {
      return _repository.isOnboardingComplete();
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Set loading state and notify listeners
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Drink tracking methods

  /// Add a new drink entry and trigger achievement checks
  /// Returns the created DrinkEntry, whether daily goal was just completed, and newly completed achievements
  Future<Map<String, dynamic>> addDrinkEntry(int drinkId, int mlAmount) async {
    try {
      final dailyRequirement = _userProfile?.dailyWaterRequirement ?? 2000;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Get consumption BEFORE adding the new entry
      final consumptionBefore = _waterTrackingService.getTotalConsumptionForDate(today);
      final wasGoalMet = consumptionBefore >= dailyRequirement;
      
      // Add drink entry through service
      final entry = await _waterTrackingService.addDrinkEntry(drinkId, mlAmount);
      
      // Update local state
      _drinkEntries = _repository.getDrinkEntries();
      
      // Get consumption AFTER adding the new entry
      final consumptionAfter = _waterTrackingService.getTotalConsumptionForDate(today);
      final isGoalMetNow = consumptionAfter >= dailyRequirement;
      
      // Check if goal was just completed with this entry
      bool goalJustCompleted = false;
      if (!wasGoalMet && isGoalMetNow) {
        // Goal was just completed! Check if we already awarded coins today
        final lastAwardDate = _repository.getLastDailyGoalAwardDate();
        
        if (lastAwardDate == null || 
            lastAwardDate.year != today.year ||
            lastAwardDate.month != today.month ||
            lastAwardDate.day != today.day) {
          // Award coins for the first time today
          await _coinService.awardDailyGoalCoins();
          await _repository.saveLastDailyGoalAwardDate(today);
          _inventory = _repository.getUserInventory();
          goalJustCompleted = true;
        }
      }
      
      // Refresh achievements and get newly completed ones
      final newlyCompletedAchievements = await refreshAchievements();
      
      notifyListeners();
      
      return {
        'entry': entry,
        'goalCompleted': goalJustCompleted,
        'newlyCompletedAchievements': newlyCompletedAchievements,
      };
    } catch (e) {
      debugPrint('Error adding drink entry: $e');
      rethrow;
    }
  }

  /// Change the selected date for viewing consumption data
  void changeSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Get total water consumption for the currently selected date
  int getTotalConsumptionForSelectedDate() {
    return _waterTrackingService.getTotalConsumptionForDate(_selectedDate);
  }

  /// Get total water consumption for a specific date
  int getTotalConsumptionForDate(DateTime date) {
    return _waterTrackingService.getTotalConsumptionForDate(date);
  }

  /// Get drink entries for the selected date
  List<DrinkEntry> getDrinkEntriesForSelectedDate() {
    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    return _drinkEntries.where((entry) => entry.date == dateStr).toList();
  }

  /// Delete a drink entry by ID
  /// Updates state and refreshes achievements
  Future<void> deleteDrinkEntry(String entryId) async {
    try {
      await _waterTrackingService.deleteDrinkEntry(entryId);
      
      // Update local state
      _drinkEntries = _repository.getDrinkEntries();
      
      // Refresh achievements as deletion may affect achievement progress
      await refreshAchievements();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting drink entry: $e');
      rethrow;
    }
  }

  /// Refresh achievements by checking all conditions
  /// Returns list of newly completed achievements
  Future<List<Achievement>> refreshAchievements() async {
    try {
      final dailyRequirement = _userProfile?.dailyWaterRequirement ?? 2000;
      
      final newlyCompleted = await _achievementService.checkAndUpdateAchievements(
        _drinkEntries,
        _inventory,
        dailyRequirement,
      );
      
      // Update local achievements state
      _achievements = _repository.getAchievements();
      
      // Award coins for newly completed achievements
      for (final achievement in newlyCompleted) {
        await _coinService.awardAchievementCoins(achievement);
      }
      
      // Update inventory to reflect coin changes
      _inventory = _repository.getUserInventory();
      
      notifyListeners();
      return newlyCompleted;
    } catch (e) {
      debugPrint('Error refreshing achievements: $e');
      rethrow;
    }
  }

  // Shop and inventory methods

  /// Purchase an item (fish or decoration) from the shop
  /// Returns a map with success status and newly completed achievements
  Future<Map<String, dynamic>> purchaseItem(String itemId, String itemType) async {
    try {
      bool success = false;
      
      if (itemType == 'fish') {
        success = await _shopService.purchaseFish(itemId);
        
        // If purchase successful, automatically add fish to aquarium
        if (success) {
          await _aquariumService.addFishToAquarium(itemId);
        }
      } else if (itemType == 'decoration') {
        success = await _shopService.purchaseDecoration(itemId);
        
        // If purchase successful, automatically add decoration to aquarium
        if (success) {
          await _aquariumService.addDecorationToAquarium(itemId);
        }
      }
      
      if (success) {
        // Update inventory state
        _inventory = _repository.getUserInventory();
        
        // Refresh achievements (aquarium achievements may be unlocked)
        final newlyCompletedAchievements = await refreshAchievements();
        
        notifyListeners();
        
        return {
          'success': true,
          'newlyCompletedAchievements': newlyCompletedAchievements,
        };
      }
      
      return {
        'success': false,
        'newlyCompletedAchievements': [],
      };
    } catch (e) {
      debugPrint('Error purchasing item: $e');
      return {
        'success': false,
        'newlyCompletedAchievements': [],
      };
    }
  }

  /// Add a fish to the aquarium display
  Future<void> addFishToAquarium(String fishId) async {
    try {
      await _aquariumService.addFishToAquarium(fishId);
      _inventory = _repository.getUserInventory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding fish to aquarium: $e');
      rethrow;
    }
  }

  /// Remove a fish from the aquarium display
  Future<void> removeFishFromAquarium(String fishId) async {
    try {
      await _aquariumService.removeFishFromAquarium(fishId);
      _inventory = _repository.getUserInventory();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing fish from aquarium: $e');
      rethrow;
    }
  }

  /// Get current coin balance
  int getCoinBalance() {
    return _inventory?.coinBalance ?? 0;
  }

  /// Get fish catalog from shop service
  List<Fish> getFishCatalog() {
    return _shopService.getFishCatalog();
  }

  /// Get decoration catalog from shop service
  List<Decoration> getDecorationCatalog() {
    return _shopService.getDecorationCatalog();
  }

  // Profile management methods

  /// Create a new user profile during onboarding
  /// Calculates daily water requirement and marks onboarding as complete
  Future<UserProfile> createProfile({
    required int age,
    required String gender,
    required double weight,
    required String exerciseFrequency,
  }) async {
    try {
      // Create profile through service
      final profile = await _profileService.createProfile(
        age: age,
        gender: gender,
        weight: weight,
        exerciseFrequency: exerciseFrequency,
      );

      // Update local state
      _userProfile = profile;

      // Mark onboarding as complete
      await _repository.saveOnboardingComplete(true);

      notifyListeners();
      return profile;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      rethrow;
    }
  }

  /// Update existing user profile
  /// Recalculates daily water requirement
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final updatedProfile = await _profileService.updateProfile(profile);
      _userProfile = updatedProfile;
      notifyListeners();
      return updatedProfile;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
}
