import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/quiz_session.dart';
import 'models/unit.dart';
import 'providers/quiz_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vocab_provider.dart';
import 'screens/add_edit_unit_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/results_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/unit_detail_screen.dart';

class VocabApp extends StatelessWidget {
  const VocabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VocabProvider()..init()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()..init()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Vocabulary Quiz',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.teal,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            routes: {
              '/': (context) => const HomeScreen(),
              '/stats': (context) => const StatsScreen(),
            },
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/unit':
                  final unit = settings.arguments as Unit;
                  return MaterialPageRoute(
                    builder: (context) => UnitDetailScreen(unit: unit),
                  );
                case '/quiz':
                  final unit = settings.arguments as Unit;
                  return MaterialPageRoute(
                    builder: (context) => QuizScreen(unit: unit),
                  );
                case '/results':
                  final args = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder: (context) => ResultsScreen(
                      session: args['session'] as QuizSession,
                      isNewBest: args['isNewBest'] as bool,
                    ),
                  );
                case '/add-unit':
                  return MaterialPageRoute(
                    builder: (context) => const AddEditUnitScreen(),
                  );
                case '/edit-unit':
                  final unit = settings.arguments as Unit;
                  return MaterialPageRoute(
                    builder: (context) => AddEditUnitScreen(unit: unit),
                  );
                default:
                  return null;
              }
            },
          );
        },
      ),
    );
  }
}
