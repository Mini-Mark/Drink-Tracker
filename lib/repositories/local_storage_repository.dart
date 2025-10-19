import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/drink_entry.dart';
import '../models/achievement.dart';
import '../models/fish.dart';
import '../models/decoration.dart';
import '../models/user_inventory.dart';

class LocalStorageRepository {
  // Storage key constants
  static const String KEY_USER_PROFILE = 'user_profile';
  static const String KEY_DRINK_ENTRIES = 'drink_entries';
  static const String KEY_ACHIEVEMENTS = 'achievements';
  static const String KEY_USER_INVENTORY = 'user_inventory';
  static const String KEY_FISH_CATALOG = 'fish_catalog';
  static const String KEY_DECORATION_CATALOG = 'decoration_catalog';
  static const String KEY_ONBOARDING_COMPLETE = 'onboarding_complete';
  static const String KEY_LAST_DAILY_GOAL_AWARD_DATE = 'last_daily_goal_award_date';

  SharedPreferences? _prefs;

  // Initialize SharedPreferences
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ensure SharedPreferences is initialized
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageRepository not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Profile storage methods
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final jsonString = jsonEncode(profile.toJson());
      await prefs.setString(KEY_USER_PROFILE, jsonString);
    } on FormatException catch (e) {
      throw Exception('Failed to encode user profile: Invalid data format - $e');
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  UserProfile? getUserProfile() {
    try {
      final jsonString = prefs.getString(KEY_USER_PROFILE);
      if (jsonString == null) return null;
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(jsonMap);
    } on FormatException catch (e) {
      // JSON parsing error - return null and log error
      print('Error parsing user profile JSON: $e');
      return null;
    } on TypeError catch (e) {
      // Type casting error - corrupted data
      print('Error casting user profile data: $e');
      return null;
    } catch (e) {
      print('Unexpected error getting user profile: $e');
      return null;
    }
  }

  Future<void> saveOnboardingComplete(bool isComplete) async {
    try {
      await prefs.setBool(KEY_ONBOARDING_COMPLETE, isComplete);
    } catch (e) {
      throw Exception('Failed to save onboarding status: $e');
    }
  }

  bool isOnboardingComplete() {
    try {
      return prefs.getBool(KEY_ONBOARDING_COMPLETE) ?? false;
    } catch (e) {
      print('Error getting onboarding status: $e');
      return false; // Default to false if error occurs
    }
  }

  // Drink entry storage methods
  Future<void> saveDrinkEntries(List<DrinkEntry> entries) async {
    try {
      final jsonList = entries.map((entry) => entry.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(KEY_DRINK_ENTRIES, jsonString);
    } on FormatException catch (e) {
      throw Exception('Failed to encode drink entries: Invalid data format - $e');
    } catch (e) {
      throw Exception('Failed to save drink entries: $e');
    }
  }

  List<DrinkEntry> getDrinkEntries() {
    try {
      final jsonString = prefs.getString(KEY_DRINK_ENTRIES);
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => DrinkEntry.fromJson(json as Map<String, dynamic>)).toList();
    } on FormatException catch (e) {
      print('Error parsing drink entries JSON: $e');
      return []; // Return empty list on parse error
    } on TypeError catch (e) {
      print('Error casting drink entries data: $e');
      return [];
    } catch (e) {
      print('Unexpected error getting drink entries: $e');
      return [];
    }
  }

  // Achievement storage methods
  Future<void> saveAchievements(List<Achievement> achievements) async {
    try {
      final jsonList = achievements.map((achievement) => achievement.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(KEY_ACHIEVEMENTS, jsonString);
    } on FormatException catch (e) {
      throw Exception('Failed to encode achievements: Invalid data format - $e');
    } catch (e) {
      throw Exception('Failed to save achievements: $e');
    }
  }

  List<Achievement> getAchievements() {
    try {
      final jsonString = prefs.getString(KEY_ACHIEVEMENTS);
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Achievement.fromJson(json as Map<String, dynamic>)).toList();
    } on FormatException catch (e) {
      print('Error parsing achievements JSON: $e');
      return [];
    } on TypeError catch (e) {
      print('Error casting achievements data: $e');
      return [];
    } catch (e) {
      print('Unexpected error getting achievements: $e');
      return [];
    }
  }

  // User inventory storage methods
  Future<void> saveUserInventory(UserInventory inventory) async {
    try {
      final jsonString = jsonEncode(inventory.toJson());
      await prefs.setString(KEY_USER_INVENTORY, jsonString);
    } on FormatException catch (e) {
      throw Exception('Failed to encode user inventory: Invalid data format - $e');
    } catch (e) {
      throw Exception('Failed to save user inventory: $e');
    }
  }

  UserInventory? getUserInventory() {
    try {
      final jsonString = prefs.getString(KEY_USER_INVENTORY);
      if (jsonString == null) return null;
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserInventory.fromJson(jsonMap);
    } on FormatException catch (e) {
      print('Error parsing user inventory JSON: $e');
      return null;
    } on TypeError catch (e) {
      print('Error casting user inventory data: $e');
      return null;
    } catch (e) {
      print('Unexpected error getting user inventory: $e');
      return null;
    }
  }

  // Fish catalog storage methods
  Future<void> saveFishCatalog(List<Fish> fishList) async {
    try {
      final jsonList = fishList.map((fish) => fish.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(KEY_FISH_CATALOG, jsonString);
    } on FormatException catch (e) {
      throw Exception('Failed to encode fish catalog: Invalid data format - $e');
    } catch (e) {
      throw Exception('Failed to save fish catalog: $e');
    }
  }

  List<Fish> getFishCatalog() {
    try {
      final jsonString = prefs.getString(KEY_FISH_CATALOG);
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Fish.fromJson(json as Map<String, dynamic>)).toList();
    } on FormatException catch (e) {
      print('Error parsing fish catalog JSON: $e');
      return [];
    } on TypeError catch (e) {
      print('Error casting fish catalog data: $e');
      return [];
    } catch (e) {
      print('Unexpected error getting fish catalog: $e');
      return [];
    }
  }

  // Decoration catalog storage methods
  Future<void> saveDecorationCatalog(List<Decoration> decorations) async {
    try {
      final jsonList = decorations.map((decoration) => decoration.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await prefs.setString(KEY_DECORATION_CATALOG, jsonString);
    } on FormatException catch (e) {
      throw Exception('Failed to encode decoration catalog: Invalid data format - $e');
    } catch (e) {
      throw Exception('Failed to save decoration catalog: $e');
    }
  }

  List<Decoration> getDecorationCatalog() {
    try {
      final jsonString = prefs.getString(KEY_DECORATION_CATALOG);
      if (jsonString == null) return [];
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => Decoration.fromJson(json as Map<String, dynamic>)).toList();
    } on FormatException catch (e) {
      print('Error parsing decoration catalog JSON: $e');
      return [];
    } on TypeError catch (e) {
      print('Error casting decoration catalog data: $e');
      return [];
    } catch (e) {
      print('Unexpected error getting decoration catalog: $e');
      return [];
    }
  }

  // Daily goal award tracking methods
  Future<void> saveLastDailyGoalAwardDate(DateTime date) async {
    try {
      await prefs.setString(KEY_LAST_DAILY_GOAL_AWARD_DATE, date.toIso8601String());
    } catch (e) {
      throw Exception('Failed to save last daily goal award date: $e');
    }
  }

  DateTime? getLastDailyGoalAwardDate() {
    try {
      final dateString = prefs.getString(KEY_LAST_DAILY_GOAL_AWARD_DATE);
      if (dateString == null) return null;
      
      return DateTime.parse(dateString);
    } on FormatException catch (e) {
      print('Error parsing last daily goal award date: $e');
      return null;
    } catch (e) {
      print('Unexpected error getting last daily goal award date: $e');
      return null;
    }
  }
}
