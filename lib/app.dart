import 'package:flutter/material.dart';
import 'package:word_wallpaper_placer/screens/main_screen.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam',
      theme: ThemeData.dark(),
      initialRoute: MainScreen.route,
      routes: {
        MainScreen.route: (context) => MainScreen(),
      },
    );
  }
}
