# Implementation Plan

## Overview
This implementation plan breaks down the Drink Tracker logic integration into discrete, manageable coding tasks. Each task builds incrementally on previous work, ensuring the app remains functional throughout development.

## Current State Analysis
The app currently has:
- Basic UI screens: Home, Statistics (with graph and achievement), History, Bottom Navigation
- Static data structures: drinks list, history list (hardcoded), achievement list (hardcoded), app settings
- Basic services: drinks service, history service, ml service, popup service, utils service
- Theme files: colors and font sizes
- Wave animation widget for water visualization
- Calendar widget for date selection

## What Needs to Be Built
The app needs:
- Data persistence layer (SharedPreferences)
- User profile management and onboarding flow
- State management (Provider) to replace hardcoded data
- Business logic services for water tracking, achievements, coins, shop, and aquarium
- Aquarium gamification system with fish and decorations
- Shop system for purchasing items with coins
- Settings screen for profile editing
- Integration of all existing UI with new backend logic

## Implementation Strategy
1. Build foundation: dependencies, models, repository, services
2. Set up state management with Provider
3. Create onboarding flow for new users
4. Integrate existing screens with new state management
5. Add new features: aquarium, shop, settings
6. Polish with animations and error handling

- [-] 1. Set up core infrastructure and data models






- [x] 1.1 Add required dependencies to pubspec.yaml

  - Add provider package for state management (^6.0.0)
  - Add shared_preferences package for local storage (^2.0.0)
  - Add uuid package for generating unique IDs (^3.0.0)
  - _Requirements: All requirements depend on these packages_


- [x] 1.2 Create data model classes

  - Create lib/models/user_profile.dart with UserProfile class including toJson/fromJson methods
  - Create lib/models/drink_entry.dart with DrinkEntry class including toJson/fromJson methods
  - Create lib/models/achievement.dart with Achievement class including toJson/fromJson methods
  - Create lib/models/fish.dart with Fish class including toJson/fromJson methods
  - Create lib/models/decoration.dart with Decoration class including toJson/fromJson methods
  - Create lib/models/user_inventory.dart with UserInventory class including toJson/fromJson methods
  - _Requirements: 1.1, 1.2, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4, 4.5, 6.1, 6.2, 6.3, 6.4, 6.5, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4, 8.5, 9.1, 9.2, 9.3, 9.4, 9.5, 10.1, 10.2, 10.3, 10.4, 10.5, 11.1, 11.2, 11.3, 11.4, 11.5_
- [x] 2. Implement data persistence layer



- [ ] 2. Implement data persistence layer

- [x] 2.1 Create LocalStorageRepository class







  - Create lib/repositories/local_storage_repository.dart
  - Implement SharedPreferences initialization
  - Create storage key constants
  - _Requirements: 1.5, 2.6, 3.2, 6.3, 7.4, 8.5, 9.1, 10.5_

- [x] 2.2 Implement profile storage methods






  - Add saveUserProfile method with JSON serialization
  - Add getUserProfile method with JSON deserialization
  - Add saveOnboardingComplete and isOnboardingComplete methods
  - _Requirements: 1.3, 1.4, 1.5, 10.3, 10.5_


- [x] 2.3 Implement drink entry storage methods





  - Add saveDrinkEntries method to persist list of drink entries
  - Add getDrinkEntries method to retrieve all entries
  - _Requirements: 2.4, 2.6, 3.2, 9.1, 11.3_


- [x] 2.4 Implement achievement and inventory storage methods





  - Add saveAchievements and getAchievements methods
  - Add saveUserInventory and getUserInventory methods
  - Add saveFishCatalog, getFishCatalog, saveDecorationCatalog, getDecorationCatalog methods
  - _Requirements: 6.1, 6.3, 6.4, 7.1, 7.4, 7.5, 8.1, 8.5_

- [-] 3. Create business logic services


- [ ] 3. Create business logic services
- [x] 3.1 Refactor and enhance existing services



  - Refactor lib/services/drinks_service.dart to work with new data models
  - Refactor lib/services/history_service.dart to integrate with repository layer
  - Keep existing ml_service.dart and utils_service.dart as utility helpers
  - _Requirements: 2.1, 2.2, 9.1, 9.2_

- [x] 3.2 Implement ProfileService



  - Create lib/services/profile_service.dart
  - Implement calculateDailyWaterRequirement method with formula (weight × 30-35ml + exercise adjustment)
  - Implement createProfile method
  - Implement updateProfile method
  - Implement getProfile method
  - _Requirements: 1.2, 1.3, 1.4, 10.2, 10.3, 10.4_


- [x] 3.3 Implement WaterTrackingService





  - Create lib/services/water_tracking_service.dart
  - Implement addDrinkEntry method with UUID generation and timestamp
  - Implement getDrinkEntriesForDate method with date filtering
  - Implement getTotalConsumptionForDate method
  - Implement getWeeklyConsumption and getMonthlyConsumption aggregation methods
  - _Requirements: 2.2, 2.3, 2.4, 3.1, 3.2, 5.3, 5.4, 9.2, 9.3, 11.2, 11.3_


- [x] 3.4 Implement AchievementService





  - Create lib/services/achievement_service.dart
  - Implement initializeAchievements with 12 predefined achievements (use existing achievement_json.dart as reference)
  - Implement checkAndUpdateAchievements method to evaluate all achievement conditions
  - Implement achievement type checkers (drink_count, consecutive_days, time_based, volume_based, variety, aquarium)
  - Implement getCompletedAchievements and getIncompleteAchievements methods
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_


- [x] 3.5 Implement CoinService





  - Create lib/services/coin_service.dart
  - Implement getCoinBalance, addCoins, deductCoins methods
  - Implement awardDailyGoalCoins method (10 coins when goal met)
  - Implement awardAchievementCoins method
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_



- [x] 3.6 Implement ShopService




  - Create lib/services/shop_service.dart
  - Implement getFishCatalog and getDecorationCatalog methods
  - Implement purchaseFish and purchaseDecoration methods with coin validation
  - Implement canAfford method
  - Initialize default fish catalog (5 fish) and decoration catalog (5 decorations)
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 3.7 Implement AquariumService





  - Create lib/services/aquarium_service.dart
  - Implement calculateVisibleFishCount method based on water consumption percentage
  - Implement getActiveFish and getActiveDecorations methods
  - Implement addFishToAquarium, removeFishFromAquarium methods
  - Implement addDecorationToAquarium, removeDecorationFromAquarium methods
  - _Requirements: 3.5, 3.6, 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 4. Set up state management with Provider






- [x] 4.1 Create AppState class






  - Create lib/providers/app_state.dart extending ChangeNotifier
  - Add properties: userProfile, drinkEntries, achievements, inventory, selectedDate, isLoading
  - Inject all service dependencies (ProfileService, WaterTrackingService, etc.)
  - _Requirements: All requirements - central state management_


- [x] 4.2 Implement AppState initialization and data loading






  - Implement loadInitialData method to load all data from repository
  - Implement checkOnboardingStatus method
  - Handle loading states and error scenarios
  - _Requirements: 1.1, 1.4, 2.1, 3.4_

- [x] 4.3 Implement AppState drink tracking methods







  - Implement addDrinkEntry method that updates state and triggers achievement checks
  - Implement changeSelectedDate method
  - Implement getTotalConsumptionForSelectedDate getter
  - Implement refreshAchievements method
  - _Requirements: 2.3, 2.4, 2.5, 3.1, 3.2, 6.3, 7.2, 7.3_



- [x] 4.4 Implement AppState shop and inventory methods






  - Implement purchaseItem method (fish or decoration)
  - Implement addFishToAquarium and removeFromAquarium methods
  - Implement getCoinBalance getter
  - _Requirements: 7.5, 8.3, 8.4, 8.5_
-

- [x] 4.5 Update main.dart to provide AppState







  - Wrap MaterialApp with ChangeNotifierProvider
  - Initialize AppState with all services
  - Update initial route logic to check onboarding status
  - _Requirements: 1.1, 12.1, 12.2, 12.5_


- [x] 5. Create onboarding flow screens





- [x] 5.1 Create GetStartedScreen







  - Create lib/pages/onboarding/get_started_screen.dart
  - Design welcome UI with app introduction and benefits
  - Add "Get Started" button to navigate to age input
  - _Requirements: 1.1_



-

- [x] 5.2 Create profile input screens




  - Create lib/pages/onboarding/age_input_screen.dart with number input
  - Create lib/pages/onboarding/gender_selection_screen.dart with radio buttons
  - Create lib/pages/onboarding/weight_input_screen.dart with number input
  - Create lib/pages/onboarding/height_input_screen.dart with number input
  - Create lib/pages/onboarding/exercise_frequency_screen.dart with dropdown/radio buttons
  - Add input validation for each screen
  - _Requirements: 1.2_

- [x] 5.3 Create onboarding summary and completion




- [x] 5.3 Create onboarding summary and completion



  - Create lib/pages/onboarding/summary_screen.dart
  - Display calculated daily water requirement
  - Add "Complete Setup" button that saves profile and marks onboarding complete
  - Navigate to home screen on completion
  - _Requirements: 1.3, 1.4, 1.5_
-

- [x] 6. Enhance home screen with aquarium and improved tracking






- [x] 6.1 Create AquariumWidget








  - Create lib/pages/widgets/aquarium_widget.dart
  - Implement fish rendering based on visible fish count from AquariumService
  - Add fish swimming animations using AnimatedPositioned or custom animations
  - Render decorations from user inventory
  - Integrate with existing animated_wave.dart widget
  - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 6.2 Update Home screen to integrate with AppState







  - Refactor lib/pages/home.dart to use Provider.of<AppState>
  - Replace hardcoded historyList and appSettings with AppState data
  - Update getML() to use AppState.getTotalConsumptionForSelectedDate
  - Update calendar to use AppState.selectedDate and changeSelectedDate
  - Keep existing CalendarWidget and integrate with state management
  - _Requirements: 2.1, 2.2, 3.1, 3.2, 3.3, 3.4_


- [x] 6.3 Enhance add drink dialog







  - Update lib/pages/popup/manage_drinks/choose_drinks.dart to use AppState
  - Call AppState.addDrinkEntry when user confirms
  - Show success animation when drink added
  - Trigger aquarium animation update
  - _Requirements: 2.3, 2.4, 2.5, 4.5_



- [x] 6.4 Add daily goal completion detection





  - Implement logic in AppState to detect when daily goal is met
  - Award coins when goal is reached for the first time each day
  - Show celebration animation or notification
  - _Requirements: 2.1, 2.2, 7.3_

- [x] 7. Enhance existing achievement screen







- [x] 7.1 Update StatisticsAchievement widget






  - Refactor lib/pages/statistics/achievement.dart to use AppState
  - Replace hardcoded achievementList with AppState.achievements
  - Add coin reward display to achievement cards
  - Show progress bar for incomplete achievements
  - Show completion badge and date for completed achievements
  - Keep existing sorting logic (completed first)
  - _Requirements: 6.1, 6.2, 6.4, 6.5_

- [x] 7.2 Integrate achievement updates with drink tracking





  - Ensure achievements are checked when drinks are added
  - Show notification when achievement is unlocked
  - _Requirements: 6.3, 6.4_


- [x] 8. Implement shop screen




- [x] 8.1 Create ShopScreen




- [x] 8.1 Create ShopScreen



  - Create lib/pages/shop/shop_screen.dart
  - Display coin balance at top
  - Create tabs or sections for Fish and Decorations
  - _Requirements: 8.1, 8.2_



- [x] 8.2 Create shop item grid widgets





  - Create lib/pages/widgets/fish_shop_item.dart
  - Create lib/pages/widgets/decoration_shop_item.dart
  - Display item image, name, cost, and purchase status
  - Add "Purchase" button that calls AppState.purchaseItem
  - _Requirements: 8.1, 8.2, 8.3_

-


- [x] 8.3 Implement purchase dialog and validation





  - Create purchase confirmation dialog
  - Validate sufficient coins before purchase
  - Show error message if insufficient coins
  - Update UI after successful purchase
  - _Requirements: 8.3, 8.4, 8.5_

- [x] 8.4 Integrate shop screen with navigation







  - Add shop route to main.dart
  - Add shop to bottom navigation menu
  - _Requirements: 12.1, 12.2_

- [x] 9. Enhance existing statistics screen






- [x] 9.1 Update StatisticsGraph widget






  - Refactor lib/pages/statistics/graph.dart to use AppState
  - Add period selector (Daily, Weekly, Monthly) using ToggleButtons or SegmentedControl
  - Replace hardcoded data with AppState data
  - _Requirements: 5.1, 5.2_


- [ ] 9.2 Implement chart data aggregation in graph widget





  - Implement daily chart data: last 7 days consumption
  - Implement weekly chart data: last 4 weeks consumption
  - Implement monthly chart data: last 6 months consumption
  - Use WaterTrackingService methods for data retrieval
  - _Requirements: 5.3, 5.4_


- [x] 9.3 Update chart rendering with real data






  - Update fl_chart rendering to use aggregated data from AppState
  - Style bars with distinct colors
  - Add axis labels and tooltips
  - _Requirements: 5.1, 5.5_

- [x] 10. Enhance existing history screen







- [x] 10.1 Update HistoryScreen to use AppState





  - Update lib/pages/history/main_history.dart to use Provider
  - Replace hardcoded historyList with AppState.drinkEntries
  - Fetch drink entries from AppState
  - Group entries by date
  - _Requirements: 9.1, 9.2_
-

- [x] 10.2 Enhance history entry display







  - Display drink type name (lookup from drinkLists in drinks_json.dart)
  - Display volume in ml
  - Display formatted timestamp
  - Sort in reverse chronological order
  - _Requirements: 9.3, 9.4, 9.5_


- [x] 10.3 Add delete functionality


  - Implement swipe-to-delete using flutter_slidable (already in dependencies)
  - Call AppState method to delete entry
  - Update UI after deletion
  - _Requirements: 9.1_

- [x] 11. Create settings screen





- [x] 11.1 Create SettingsScreen







  - Create lib/pages/settings/settings_screen.dart
  - Display current profile information
  - Display current daily water requirement
  - _Requirements: 10.1, 10.4_


- [x] 11.2 Implement profile editing






  - Add editable fields for age, gender, weight, height, exercise frequency
  - Add input validation
  - Add "Save Changes" button
  - _Requirements: 10.2_

- [x] 11.3 Implement profile update logic







  - Call AppState.updateProfile when user saves changes
  - Recalculate daily water requirement
  - Show success message
  - Persist updated profile
  - _Requirements: 10.3, 10.5_

-

- [x] 11.4 Integrate settings screen with navigation






  - Add settings route to main.dart
  - Add settings to bottom navigation menu
  - _Requirements: 12.1, 12.2_
-

- [x] 12. Enhance existing bottom navigation




- [x] 12.1 Update BottomNavigator widget








  - Update lib/pages/bottom_nav.dart to include all 5 pages (Home, Statistics, History, Settings, Shop)
  - Currently has 3 tabs, add Settings and Shop tabs
  - Display coin balance in navigation bar using AppState
  - _Requirements: 12.1, 12.4_


- [x] 12.2 Implement navigation state preservation






  - Update existing navigation to use IndexedStack or similar to preserve page state
  - Keep existing active page highlighting
  - _Requirements: 12.3, 12.5_


- [x] 13. Add animations and polish







- [x] 13.1 Implement drink entry animation





  - Add water splash or ripple animation when drink is added
  - Animate aquarium fish appearance
  - Add wave animation enhancement
  - _Requirements: 2.5, 4.5_




- [x] 13.2 Add achievement unlock animation





  - Show celebration animation when achievement is unlocked
  - Display coin reward notification
  - _Requirements: 6.3, 6.4_



- [x] 13.3 Add shop purchase animation
















- [x] 13.4 Add shop purchase animation






  - Animate coin deduction
  - Show item added to inventory animation
  - Update aquarium with new fish/decoration
  - _Requirements: 8.5_


- [x] 14. Error handling and validation




- [x] 14.1 Implement error handling in repository layer



  - Add try-catch blocks for SharedPreferences operations
  - Handle JSON parsing errors
  - Provide fallback default values
  - _Requirements: All requirements_

- [x] 14.2 Add input validation across all forms



  - Validate age (1-120), weight (20-300kg), height (50-250cm)
  - Validate drink volume (1-2000ml)
  - Show user-friendly error messages
  - _Requirements: 1.2, 2.3, 10.2, 11.2_

- [x] 14.3 Implement error UI feedback



  - Add SnackBar for error messages
  - Add loading indicators during async operations
  - Handle network-independent operation gracefully
  - _Requirements: 8.4_

- [-] 15. Testing and bug fixes



- [ ]* 15.1 Write unit tests for models
  - Test JSON serialization/deserialization for all models
  - Test model validation logic
  - _Requirements: All model-related requirements_

- [ ] 15.2 Write unit tests for services

  - Test ProfileService water calculation formula
  - Test WaterTrackingService aggregation methods
  - Test AchievementService achievement detection logic
  - Test CoinService coin operations
  - Test ShopService purchase validation
  - _Requirements: All service-related requirements_

- [ ]* 15.3 Write widget tests
  - Test onboarding flow navigation
  - Test home screen drink entry
  - Test shop purchase flow
  - Test achievement display
  - _Requirements: All UI-related requirements_

- [ ]* 15.4 Perform integration testing
  - Test complete user flow: onboarding → drink tracking → earn coins → purchase fish
  - Test data persistence across app restarts
  - Test achievement unlocking scenarios
  - _Requirements: All requirements_

- [x] 15.5 Fix bugs and polish UI




  - Address any issues found during testing
  - Improve UI responsiveness
  - Optimize performance
  - _Requirements: All requirements_
