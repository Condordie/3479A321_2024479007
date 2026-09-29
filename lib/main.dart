import 'package:flutter/material.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/peg_solitaire_screen.dart';
import 'ui/screens/rules_screen.dart';
import 'ui/screens/history_screen.dart'; // cuando la crees
import 'package:provider/provider.dart';
import 'viewmodels/peg_solitaire_viewmodel.dart';
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
        '/history': (context) => const HistoryScreen(),
        '/rules': (context) => const RulesScreen(),
        '/game': (context) => ChangeNotifierProvider(
              create: (_) => PegSolitaireViewModel(),
              child: PegSolitaireScreen(),
            ),
      },
    );
  }
}