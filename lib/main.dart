import 'package:flutter/material.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/peg_solitaire_screen.dart';
import 'ui/screens/RulesScreen.dart';
//import 'ui/screens/history_screen.dart'; // cuando la crees
// import 'ui/theme/app_theme.dart'; // si ya tienes AppTheme

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solitario Ingles',
      theme: ThemeData(primarySwatch: Colors.blue), // o AppTheme.lightTheme si ya la tienes
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/game': (context) => PegSolitaireScreen(),
        //'/history': (context) => const HistoryScreen(),
        '/rules': (context) => const RulesScreen(),
      },
    );
  }
}