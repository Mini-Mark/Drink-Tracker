# Drink Tracker App

A comprehensive Flutter application for tracking daily water and beverage intake with a beautiful UI and robust data persistence system.

## Features

### 🎯 Core Functionality
- **Daily Hydration Tracking**: Track your daily water and beverage intake
- **Visual Progress**: Beautiful animated water level visualization
- **Multiple Beverage Types**: Support for water, coffee, tea, juice, soda, and custom drinks
- **Calendar View**: View and track your hydration history by date
- **Statistics**: Weekly and monthly hydration statistics with charts

### 🗄️ Data Management System
- **SQLite Database**: Robust local data persistence using SQLite
- **State Management**: Provider pattern for efficient state management
- **Data Persistence**: All data is saved locally and persists between app sessions
- **Settings Management**: Comprehensive user preferences and app configuration

### ⚙️ Settings & Customization
- **Personal Information**: Set your name and personal details
- **Daily Goals**: Customizable daily hydration targets
- **Unit Preferences**: Choose between ml, oz, or cups for volume measurement
- **Theme Options**: Light, dark, or system theme modes
- **Notification Settings**: Customizable drink reminders and intervals
- **Data Backup**: Export and import functionality for data backup

### 🔔 Smart Notifications
- **Drink Reminders**: Customizable notification intervals
- **Goal Achievement**: Celebrate when you reach your daily goal
- **Streak Tracking**: Track consecutive days of meeting your hydration goal

## System Architecture

### Database Schema
The app uses SQLite with three main tables:

1. **drinks**: Stores beverage types with icons and colors
2. **history**: Tracks all drink entries with timestamps
3. **settings**: Stores user preferences and app configuration

### Services
- **DatabaseService**: Handles all database operations
- **AppState**: Manages application state using Provider
- **SettingsService**: Manages user preferences using SharedPreferences
- **NotificationService**: Handles drink reminders and notifications

### State Management
The app uses the Provider pattern for efficient state management:
- Centralized app state in `AppState` class
- Reactive UI updates when data changes
- Efficient data loading and caching

## Installation

1. **Prerequisites**
   - Flutter SDK (2.18.6 or higher)
   - Dart SDK
   - Android Studio / VS Code

2. **Setup**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd drinktracker

   # Install dependencies
   flutter pub get

   # Run the app
   flutter run
   ```

## Dependencies

### Core Dependencies
- `flutter`: Flutter framework
- `sqflite`: SQLite database for local storage
- `path`: Path manipulation utilities
- `shared_preferences`: User preferences storage
- `provider`: State management
- `uuid`: Unique identifier generation

### UI Dependencies
- `wave`: Animated wave effects
- `flutter_slidable`: Slidable list items
- `intl`: Internationalization
- `animated_bottom_navigation_bar`: Animated navigation
- `auto_size_text`: Responsive text sizing
- `fl_chart`: Chart visualization
- `dotted_border`: Dotted border decorations

## Usage

### Adding Drinks
1. Tap the "+" button on the home screen
2. Select a beverage type or add a custom drink
3. Choose the quantity (ml)
4. The drink is automatically added to your daily total

### Viewing History
1. Navigate to the History tab
2. View your drink entries by date
3. See detailed statistics and trends

### Customizing Settings
1. Tap the settings button (gear icon)
2. Configure your preferences:
   - Daily hydration goal
   - Notification settings
   - Theme preferences
   - Unit preferences

### Managing Data
- **Export Data**: Backup your data to external storage
- **Import Data**: Restore data from backup
- **Clear Data**: Reset all app data (use with caution)

## Data Structure

### Drink Entry
```json
{
  "id": "uuid",
  "drinks_id": "drink-uuid",
  "ml_amount": 250,
  "datetime": "12/25/2023 02:30pm",
  "created_at": "2023-12-25T14:30:00Z"
}
```

### Drink Type
```json
{
  "id": "uuid",
  "name": "Water",
  "icon": "Icons.water_drop",
  "color": "#2196F3",
  "created_at": "2023-12-25T00:00:00Z",
  "updated_at": "2023-12-25T00:00:00Z"
}
```

## Development

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── pages/                    # UI pages
│   ├── home.dart            # Main home screen
│   ├── settings.dart        # Settings page
│   ├── bottom_nav.dart      # Bottom navigation
│   ├── history/             # History pages
│   ├── statistics/          # Statistics pages
│   ├── popup/               # Popup dialogs
│   └── widgets/             # Reusable widgets
├── services/                # Business logic
│   ├── database_service.dart    # Database operations
│   ├── app_state.dart          # State management
│   ├── settings_service.dart   # User preferences
│   ├── notification_service.dart # Notifications
│   └── popup_service.dart      # Popup management
├── theme/                   # App theming
│   ├── color.dart          # Color definitions
│   └── font_size.dart      # Font size definitions
└── data_json/              # Static data (legacy)
```

### Adding New Features
1. **Database Changes**: Update `DatabaseService` with new tables/queries
2. **State Management**: Add new state properties to `AppState`
3. **UI Updates**: Create new pages/widgets in the `pages` directory
4. **Settings**: Add new preferences to `SettingsService`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue on the GitHub repository.

---

**Note**: This app now includes a complete data persistence system that was missing from the original version. All data is stored locally using SQLite, and the app includes comprehensive settings management, notification system, and data backup capabilities.
