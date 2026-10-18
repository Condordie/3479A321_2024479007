import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/repositories/game_history_repository.dart';
import 'package:untitled/repositories/json_files_history_repository.dart';
import 'package:untitled/services/preferences_service.dart';
import 'ui/screens/menu_screen.dart';
import 'ui/screens/peg_solitaire_screen.dart';
import 'ui/screens/rules_screen.dart';
import 'ui/screens/history_screen.dart';
import 'viewmodels/peg_solitaire_viewmodel.dart';
import 'package:untitled/services/audio_service.dart';

Future<void> main() async {
  // 1. Asegurar la vinculación con el canal de plataforma nativo (Android/iOS)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Resolver dependencias de infraestructura de forma asíncrona
  final preferencesService = await PreferencesService.create();
  final historyRepository = JsonFileHistoryRepository();
  final audioService = AudioService.instance;

  // 3. Inyectar dependencias en la raíz del árbol
  runApp(
    MultiProvider(
      providers: [
        // Inyección por interfaz abstracta (DIP)
        Provider<IGameHistoryRepository>.value(value: historyRepository),
        Provider<PreferencesService>.value(value: preferencesService),
        Provider<AudioService>.value(value: audioService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solitario Ingles',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/history': (context) => const HistoryScreen(),
        '/rules': (context) => const RulesScreen(),
        '/game': (context) => ChangeNotifierProvider(
              create: (routeContext) => PegSolitaireViewModel(
                historyRepository: routeContext.read<IGameHistoryRepository>(),
                preferencesService: routeContext.read<PreferencesService>(),
                audioService: routeContext.read<AudioService>(),
              ),
              child: PegSolitaireScreen(),
            ),
      },
    );
  }
}