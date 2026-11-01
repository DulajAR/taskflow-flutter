import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

const Color taskFlowPrimary = Color(0xFF6855E8);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  ThemeData _buildLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: taskFlowPrimary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F8FC),
        elevation: 0,
      ),
      cardTheme: CardThemeData(color: colorScheme.surface, elevation: 0),
    );
  }

  ThemeData _buildDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: taskFlowPrimary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121218),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121218),
        elevation: 0,
      ),
      cardTheme: CardThemeData(color: const Color(0xFF1E1E29), elevation: 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TaskFlow',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: themeProvider.themeMode,
          home: const HomeScreen(),
        );
      },
    );
  }
}
