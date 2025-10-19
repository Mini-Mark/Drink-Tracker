# Design Document: Drink Tracker Logic Integration

## Overview

This design document outlines the architecture and implementation strategy for enhancing the Drink Tracker Flutter application by integrating comprehensive business logic with the existing UI components. The app currently has basic UI elements and data structures but lacks persistent storage, proper state management, user onboarding, gamification features (aquarium system with fish), achievements, coins, and a shop system.

The enhancement will transform the app from a simple water tracking interface into a fully-featured gamified hydration companion with persistent data storage, user profiles, and engaging visual feedback through an aquarium ecosystem.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  (UI Widgets: Home, Statistics, History, Settings, Shop)    │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                    State Management Layer                    │
│         (Provider/ChangeNotifier for reactive state)         │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                      Business Logic Layer                    │
│  (Services: Profile, Water Tracking, Achievement, Coin,      │
│   Shop, Aquarium)                                            │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                      Data Access Layer                       │
│         (Repository Pattern with SharedPreferences)          │
└───────────────────┬─────────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────────┐
│                      Data Storage Layer                      │
│              (SharedPreferences - Local Storage)             │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

- **Framework**: Flutter (Dart)
- **State Management**: Provider package
- **Local Storage**: shared_preferences package
- **Charts**: fl_chart (already included)
- **Animations**: Flutter's built-in animation framework
- **Date Handling**: intl package (already included)

## Components and Interfaces

### 1. Data Models

#### UserProfile Model
```dart
class UserProfile {
  int age;
  String gender; // 'male', 'female', 'other'
  double weight; // in kg
  double height; // in cm
  String exerciseFrequency; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  int dailyWaterRequirement; // calculated in ml
  DateTime createdAt;
  DateTime updatedAt;
}
```

#### DrinkEntry Model
```dart
class DrinkEntry {
  String id; // UUID
  int drinkId; // reference to drink type
  int mlAmount;
  DateTime timestamp;
  String date; // formatted date for grouping (YYYY-MM-DD)
}
```

#### Achievement Model
```dart
class Achievement {
  String id;
  String name;
  String description;
  int coinReward;
  bool isCompleted;
  int progress; // current progress value
  int target; // target value to complete
  String type; // 'drink_count', 'consecutive_days', 'time_based', 'volume_based', 'variety'
  DateTime? completedAt;
}
```

#### Fish Model
```dart
class Fish {
  String id;
  String name;
  String imagePath;
  int coinCost;
  bool isPurchased;
  DateTime? purchasedAt;
}
```

#### Decoration Model
```dart
class Decoration {
  String id;
  String name;
  String imagePath;
  int coinCost;
  bool isPurchased;
  DateTime? purchasedAt;
}
```

#### UserInventory Model
```dart
class UserInventory {
  int coinBalance;
  List<String> purchasedFishIds;
  List<String> purchasedDecorationIds;
  List<String> activeFishIds; // fish currently displayed in aquarium
  List<String> activeDecorationIds; // decorations currently displayed
}
```

### 2. Repository Layer

#### LocalStorageRepository
Handles all SharedPreferences operations with JSON serialization.

**Methods:**
- `saveUserProfile(UserProfile profile)`
- `getUserProfile() -> UserProfile?`
- `saveDrinkEntries(List<DrinkEntry> entries)`
- `getDrinkEntries() -> List<DrinkEntry>`
- `saveAchievements(List<Achievement> achievements)`
- `getAchievements() -> List<Achievement>`
- `saveUserInventory(UserInventory inventory)`
- `getUserInventory() -> UserInventory`
- `saveFishCatalog(List<Fish> fish)`
- `getFishCatalog() -> List<Fish>`
- `saveDecorationCatalog(List<Decoration> decorations)`
- `getDecorationCatalog() -> List<Decoration>`
- `saveOnboardingComplete(bool isComplete)`
- `isOnboardingComplete() -> bool`

### 3. Service Layer

#### ProfileService
Manages user profile and calculates daily water requirements.

**Methods:**
- `createProfile(age, gender, weight, height, exerciseFrequency) -> UserProfile`
- `updateProfile(UserProfile profile) -> UserProfile`
- `calculateDailyWaterRequirement(UserProfile profile) -> int`
- `getProfile() -> UserProfile?`

**Water Requirement Calculation Formula:**
```
Base requirement = weight (kg) × 30-35 ml
Adjustments:
- Exercise: +500ml to +1000ml based on frequency
- Gender: Males typically +10% more
- Age: 65+ may need slight reduction
```

#### WaterTrackingService
Manages drink entries and daily consumption tracking.

**Methods:**
- `addDrinkEntry(drinkId, mlAmount) -> DrinkEntry`
- `getDrinkEntriesForDate(DateTime date) -> List<DrinkEntry>`
- `getTotalConsumptionForDate(DateTime date) -> int`
- `getDrinkEntriesForDateRange(DateTime start, DateTime end) -> List<DrinkEntry>`
- `getWeeklyConsumption() -> Map<String, int>`
- `getMonthlyConsumption() -> Map<String, int>`
- `deleteDrinkEntry(String entryId)`

#### AchievementService
Tracks and manages user achievements.

**Methods:**
- `initializeAchievements() -> List<Achievement>`
- `checkAndUpdateAchievements() -> List<Achievement>` // returns newly completed
- `getAchievements() -> List<Achievement>`
- `getCompletedAchievements() -> List<Achievement>`
- `getIncompleteAchievements() -> List<Achievement>`

**Achievement Types:**
1. Drink Count: "Drink X times"
2. Consecutive Days: "Meet goal X days in a row"
3. Time-Based: "Drink before/after specific time X times"
4. Volume-Based: "Drink more than X ml in single serving"
5. Variety: "Try X different drinks"
6. Aquarium: "Have X fish in aquarium"

#### CoinService
Manages coin economy and rewards.

**Methods:**
- `getCoinBalance() -> int`
- `addCoins(int amount, String reason)`
- `deductCoins(int amount) -> bool`
- `awardDailyGoalCoins()` // +10 coins
- `awardAchievementCoins(Achievement achievement)`

**Coin Rewards:**
- Daily goal completion: 10 coins
- Achievement completion: 20-100 coins based on difficulty
- Consecutive day streaks: Bonus multiplier

#### ShopService
Manages shop inventory and purchases.

**Methods:**
- `getFishCatalog() -> List<Fish>`
- `getDecorationCatalog() -> List<Decoration>`
- `purchaseFish(String fishId) -> bool`
- `purchaseDecoration(String decorationId) -> bool`
- `canAfford(int cost) -> bool`

#### AquariumService
Manages aquarium display logic and fish visibility.

**Methods:**
- `getActiveFish() -> List<Fish>`
- `getActiveDecorations() -> List<Decoration>`
- `calculateVisibleFishCount(int currentML, int targetML) -> int`
- `addFishToAquarium(String fishId)`
- `removeFishFromAquarium(String fishId)`
- `addDecorationToAquarium(String decorationId)`
- `removeDecorationFromAquarium(String decorationId)`

**Fish Visibility Logic:**
- Fish appear progressively as user drinks more water
- Formula: `visibleFish = floor((currentML / targetML) * totalPurchasedFish)`
- Minimum 1 fish visible if any water consumed
- All fish visible when goal reached

### 4. State Management

#### AppState (ChangeNotifier)
Central state management for the entire app.

**Properties:**
- `UserProfile? userProfile`
- `List<DrinkEntry> drinkEntries`
- `List<Achievement> achievements`
- `UserInventory inventory`
- `DateTime selectedDate`
- `bool isLoading`

**Methods:**
- `loadInitialData()`
- `addDrinkEntry(drinkId, mlAmount)`
- `updateProfile(UserProfile profile)`
- `purchaseItem(itemId, itemType)`
- `changeSelectedDate(DateTime date)`
- `refreshAchievements()`

### 5. UI Components

#### Onboarding Flow
- **GetStartedScreen**: Welcome screen with app introduction
- **AgeInputScreen**: Collect user age
- **GenderSelectionScreen**: Select gender
- **WeightInputScreen**: Collect weight
- **HeightInputScreen**: Collect height
- **ExerciseFrequencyScreen**: Select exercise frequency
- **SummaryScreen**: Show calculated daily water requirement

#### Home Screen Enhancements
- **AquariumWidget**: Animated aquarium with fish and decorations
- **WaterProgressIndicator**: Wave animation showing progress
- **CalendarWidget**: Horizontal scrollable calendar (existing, enhance)
- **AddDrinkButton**: Floating action button (existing, enhance)
- **DailyStatsDisplay**: Current consumption vs goal

#### Statistics Screen
- **ChartWidget**: Bar chart with daily/weekly/monthly toggle
- **PeriodSelector**: Toggle between time periods
- **StatsSummary**: Average consumption, best day, streak info

#### Achievement Screen
- **AchievementList**: Scrollable list of achievements
- **AchievementCard**: Individual achievement with progress bar
- **CompletedBadge**: Visual indicator for completed achievements

#### Shop Screen
- **CoinBalanceDisplay**: Show current coin balance
- **FishShopSection**: Grid of purchasable fish
- **DecorationShopSection**: Grid of purchasable decorations
- **PurchaseDialog**: Confirmation dialog for purchases

#### Settings Screen
- **ProfileEditor**: Edit user profile fields
- **WaterGoalDisplay**: Show current daily requirement
- **AppSettings**: Additional app preferences

#### History Screen (Enhance Existing)
- **HistoryList**: Grouped by date, reverse chronological
- **DrinkEntryCard**: Show drink type, volume, time
- **DeleteAction**: Swipe to delete entry

## Data Models

### Storage Keys (SharedPreferences)
```dart
static const String KEY_USER_PROFILE = 'user_profile';
static const String KEY_DRINK_ENTRIES = 'drink_entries';
static const String KEY_ACHIEVEMENTS = 'achievements';
static const String KEY_USER_INVENTORY = 'user_inventory';
static const String KEY_FISH_CATALOG = 'fish_catalog';
static const String KEY_DECORATION_CATALOG = 'decoration_catalog';
static const String KEY_ONBOARDING_COMPLETE = 'onboarding_complete';
```

### Initial Data Seeds

#### Fish Catalog (5 fish)
1. Goldfish - 50 coins
2. Clownfish - 75 coins
3. Blue Tang - 100 coins
4. Angelfish - 125 coins
5. Seahorse - 150 coins

#### Decoration Catalog (5 decorations)
1. Coral - 30 coins
2. Treasure Chest - 50 coins
3. Castle - 75 coins
4. Seaweed - 25 coins
5. Starfish - 40 coins

#### Achievement Definitions
1. "First Sip" - Add first drink entry (20 coins)
2. "Hydration Beginner" - Drink 10 times (30 coins)
3. "Hydration Expert" - Drink 50 times (50 coins)
4. "Hydration Master" - Drink 100 times (100 coins)
5. "Consistent Drinker" - Meet goal 3 days in a row (40 coins)
6. "Week Warrior" - Meet goal 7 days in a row (70 coins)
7. "Early Bird" - Drink before 9 AM, 10 times (35 coins)
8. "Night Owl" - Drink after 10 PM, 10 times (35 coins)
9. "Big Gulp" - Drink more than 500ml in single serving (25 coins)
10. "Variety Explorer" - Try 5 different drinks (45 coins)
11. "Fish Collector" - Have 3 fish in aquarium (50 coins)
12. "Aquarium Master" - Have all 5 fish (100 coins)

## Error Handling

### Error Types
1. **Storage Errors**: Failed to save/load from SharedPreferences
2. **Validation Errors**: Invalid user input (negative values, out of range)
3. **Purchase Errors**: Insufficient coins, already purchased
4. **Data Corruption**: Invalid JSON format in storage

### Error Handling Strategy
- Use try-catch blocks in repository layer
- Return Result<T, Error> types for operations that can fail
- Show user-friendly error messages via SnackBar
- Log errors for debugging
- Provide fallback default values for corrupted data

### Validation Rules
- Age: 1-120 years
- Weight: 20-300 kg
- Height: 50-250 cm
- Drink volume: 1-2000 ml per entry
- Coin balance: Cannot go negative

## Testing Strategy

### Unit Tests
- **Model Tests**: Serialization/deserialization, validation
- **Service Tests**: Business logic, calculations, state changes
- **Repository Tests**: Storage operations with mocked SharedPreferences

### Widget Tests
- **Onboarding Flow**: Navigation, input validation, profile creation
- **Home Screen**: Drink entry addition, calendar navigation, aquarium display
- **Shop**: Purchase flow, coin deduction, inventory update
- **Achievement**: Progress tracking, completion detection

### Integration Tests
- **End-to-End Flow**: Complete onboarding → add drinks → earn coins → purchase fish
- **Data Persistence**: Save data → restart app → verify data loaded
- **Achievement Unlocking**: Perform actions → verify achievements unlock

### Test Data
- Create mock user profiles with various characteristics
- Generate sample drink entries across multiple dates
- Simulate achievement progress scenarios

## Performance Considerations

### Optimization Strategies
1. **Lazy Loading**: Load only necessary data for current screen
2. **Caching**: Cache frequently accessed data in memory
3. **Batch Operations**: Group multiple storage writes together
4. **Efficient Queries**: Filter data in memory rather than loading all
5. **Animation Performance**: Use const constructors, avoid rebuilds

### Data Limits
- Maximum drink entries: 10,000 (auto-archive older entries)
- Maximum history display: Last 90 days
- Achievement check frequency: On drink entry add, daily goal check

## Migration Strategy

### Phase 1: Foundation (Core Infrastructure)
- Set up state management with Provider
- Implement data models and repository layer
- Add SharedPreferences storage

### Phase 2: User Profile & Onboarding
- Create onboarding screens
- Implement profile service and water calculation
- Add profile settings screen

### Phase 3: Enhanced Water Tracking
- Upgrade drink entry system with persistence
- Implement date-based filtering
- Enhance history screen

### Phase 4: Gamification (Coins & Achievements)
- Implement coin system
- Create achievement tracking
- Add achievement screen

### Phase 5: Shop & Aquarium
- Build shop system
- Create fish and decoration catalogs
- Implement aquarium display logic
- Add fish animations

### Phase 6: Statistics Enhancement
- Implement weekly/monthly aggregation
- Enhance chart visualization
- Add statistics insights

### Phase 7: Polish & Testing
- Add animations and transitions
- Implement error handling
- Write tests
- Performance optimization

## Security Considerations

- **Data Privacy**: All data stored locally, no external transmission
- **Input Sanitization**: Validate all user inputs
- **Data Integrity**: Use JSON schema validation
- **Backup**: Consider export/import functionality for user data

## Accessibility

- **Screen Reader Support**: Add semantic labels to all interactive elements
- **Color Contrast**: Ensure WCAG AA compliance
- **Font Scaling**: Support dynamic font sizes
- **Touch Targets**: Minimum 44x44 dp for all buttons

## Future Enhancements (Out of Scope)

- Cloud sync across devices
- Social features (share achievements)
- Reminders and notifications
- Custom drink types creation
- Advanced statistics (hydration trends, predictions)
- Multiple aquarium themes
- Fish breeding system
- Daily challenges
