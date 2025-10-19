import 'package:drinktracker/models/user_profile.dart';
import 'package:drinktracker/repositories/local_storage_repository.dart';

/// Service for managing user profile and calculating water requirements
class ProfileService {
  final LocalStorageRepository _repository;

  ProfileService(this._repository);

  /// Create a new user profile
  Future<UserProfile> createProfile({
    required int age,
    required String gender,
    required double weight,
    required String exerciseFrequency,
  }) async {
    final dailyRequirement = calculateDailyWaterRequirement(
      weight: weight,
      gender: gender,
      age: age,
      exerciseFrequency: exerciseFrequency,
    );

    final profile = UserProfile(
      age: age,
      gender: gender,
      weight: weight,
      exerciseFrequency: exerciseFrequency,
      dailyWaterRequirement: dailyRequirement,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _repository.saveUserProfile(profile);
    return profile;
  }

  /// Update existing user profile
  Future<UserProfile> updateProfile(UserProfile profile) async {
    // Recalculate daily water requirement
    final dailyRequirement = calculateDailyWaterRequirement(
      weight: profile.weight,
      gender: profile.gender,
      age: profile.age,
      exerciseFrequency: profile.exerciseFrequency,
    );

    final updatedProfile = UserProfile(
      age: profile.age,
      gender: profile.gender,
      weight: profile.weight,
      exerciseFrequency: profile.exerciseFrequency,
      dailyWaterRequirement: dailyRequirement,
      createdAt: profile.createdAt,
      updatedAt: DateTime.now(),
    );

    await _repository.saveUserProfile(updatedProfile);
    return updatedProfile;
  }

  /// Get current user profile
  Future<UserProfile?> getProfile() async {
    return _repository.getUserProfile();
  }

  /// Calculate daily water requirement based on user profile
  /// Formula: weight (kg) × 30-35ml + exercise adjustment + gender adjustment
  int calculateDailyWaterRequirement({
    required double weight,
    required String gender,
    required int age,
    required String exerciseFrequency,
  }) {
    // Base calculation: weight × 33ml (average of 30-35)
    double baseRequirement = weight * 33;

    // Gender adjustment: males typically need 10% more
    if (gender.toLowerCase() == 'male') {
      baseRequirement *= 1.1;
    }

    // Age adjustment: people 65+ may need slightly less
    if (age >= 65) {
      baseRequirement *= 0.95;
    }

    // Exercise frequency adjustment
    double exerciseAdjustment = 0;
    switch (exerciseFrequency.toLowerCase()) {
      case 'sedentary':
        exerciseAdjustment = 0;
        break;
      case 'light':
        exerciseAdjustment = 300;
        break;
      case 'moderate':
        exerciseAdjustment = 500;
        break;
      case 'active':
        exerciseAdjustment = 750;
        break;
      case 'very_active':
        exerciseAdjustment = 1000;
        break;
      default:
        exerciseAdjustment = 0;
    }

    final totalRequirement = baseRequirement + exerciseAdjustment;

    // Round to nearest 50ml for cleaner numbers
    return ((totalRequirement / 50).round() * 50).toInt();
  }
}
