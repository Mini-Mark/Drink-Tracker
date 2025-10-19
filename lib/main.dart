import 'package:drinktracker/pages/bottom_nav.dart';
import 'package:drinktracker/pages/onboarding/get_started_screen.dart';
import 'package:drinktracker/pages/onboarding/age_input_screen.dart';
import 'package:drinktracker/pages/onboarding/gender_selection_screen.dart';
import 'package:drinktracker/pages/onboarding/weight_input_screen.dart';
import 'package:drinktracker/pages/onboarding/exercise_frequency_screen.dart';
import 'package:drinktracker/pages/onboarding/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drinktracker/providers/app_state.dart';
import 'package:drinktracker/repositories/local_storage_repository.dart';
import 'package:drinktracker/services/profile_service.dart';
import 'package:drinktracker/services/water_tracking_service.dart';
import 'package:drinktracker/services/achievement_service.dart';
import 'package:drinktracker/services/coin_service.dart';
import 'package:drinktracker/services/shop_service.dart';
import 'package:drinktracker/services/aquarium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize repository
    final repository = LocalStorageRepository();
    await repository.initialize();

    // Initialize services
    final profileService = ProfileService(repository);
    final waterTrackingService = WaterTrackingService(repository);
    final achievementService = AchievementService(repository);
    final coinService = CoinService(repository);
    final shopService = ShopService(repository, coinService);
    final aquariumService = AquariumService(repository);

    // Create AppState with all services
    final appState = AppState(
      repository: repository,
      profileService: profileService,
      waterTrackingService: waterTrackingService,
      achievementService: achievementService,
      coinService: coinService,
      shopService: shopService,
      aquariumService: aquariumService,
    );

    // Load initial data
    await appState.loadInitialData();

    // Set preferred orientations and run app
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) => runApp(MyApp(appState: appState)));
  } catch (e) {
    // If initialization fails, show error screen
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends StatelessWidget {
  final AppState appState;

  const MyApp({Key? key, required this.appState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check onboarding status to determine initial route
    final isOnboardingComplete = appState.checkOnboardingStatus();
    final initialRoute = isOnboardingComplete ? '/home' : '/onboarding';

    return ChangeNotifierProvider.value(
      value: appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Drink Tracker',
        initialRoute: initialRoute,
        routes: {
          '/home': (context) => const BottomNavigator(page: 0),
          '/statistics': (context) => const BottomNavigator(page: 1),
          '/history': (context) => const BottomNavigator(page: 2),
          '/settings': (context) => const BottomNavigator(page: 3),
          '/shop': (context) => const BottomNavigator(page: 4),
          '/onboarding': (context) => const GetStartedScreen(),
          '/onboarding/age': (context) => const AgeInputScreen(),
          '/onboarding/gender': (context) => const GenderSelectionScreen(),
          '/onboarding/weight': (context) => const WeightInputScreen(),
          '/onboarding/exercise': (context) => const ExerciseFrequencyScreen(),
          '/onboarding/summary': (context) => const SummaryScreen(),
        },
      ),
    );
  }
}

/// Error app widget shown when initialization fails
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Failed to Initialize App',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'An error occurred while starting the app:\n\n$error',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Close App',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
