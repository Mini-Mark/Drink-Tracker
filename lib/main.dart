import 'package:drinktracker/pages/bottom_nav.dart';
import 'package:drinktracker/pages/history/main_history.dart';
import 'package:drinktracker/pages/home.dart';
import 'package:drinktracker/pages/settings.dart';
import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:drinktracker/services/app_state.dart';
import 'package:drinktracker/services/settings_service.dart';
import 'package:drinktracker/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final settingsService = SettingsService();
  final notificationService = NotificationService();
  
  // Check if first launch
  final isFirstLaunch = await settingsService.getIsFirstLaunch();
  if (isFirstLaunch) {
    await settingsService.setFirstLaunchComplete();
    await settingsService.setFirstLaunchDate(DateTime.now().toIso8601String());
  }
  
  // Increment app launch count
  await settingsService.incrementAppLaunchCount();
  
  // Initialize notifications
  await notificationService.initialize();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState()..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Drink Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/home',
        routes: {
          '/home': (context) => Home(),
          '/statistics': (context) => BottomNavigator(page: 1),
          '/history': (context) => BottomNavigator(page: 2),
          '/settings': (context) => SettingsPage(),
          // add more routes as needed
        },
      ),
    );
  }
}
