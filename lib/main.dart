import 'package:drinktracker/pages/bottom_nav.dart';
import 'package:drinktracker/pages/history/main_history.dart';
import 'package:drinktracker/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:drinktracker/theme/color.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) => runApp(MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/home',
            routes: {
              '/home': (context) => Home(),
              '/statistics': (context) => BottomNavigator(page: 1),
              '/history': (context) => BottomNavigator(page: 2),
              // add more routes as needed
            },
          )));
}
