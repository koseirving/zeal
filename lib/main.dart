import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/video_timeline_screen.dart';
import 'screens/music_player_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/goal_tracker_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize notification service
  await NotificationService.initialize();
  
  // Initialize SharedPreferences
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('Failed to initialize SharedPreferences: $e');
  }
  
  // Set environment to dev for now
  AppConfig.setEnvironment(Environment.dev);
  
  runApp(const ProviderScope(child: ZealApp()));
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/videos',
      builder: (context, state) => const VideoTimelineScreen(),
    ),
    GoRoute(
      path: '/music',
      builder: (context, state) => const MusicPlayerScreen(),
    ),
    GoRoute(
      path: '/affirmations',
      builder: (context, state) => const AffirmationsScreen(),
    ),
    GoRoute(
      path: '/goal-tracker',
      builder: (context, state) => const GoalTrackerScreen(),
    ),
  ],
);

class ZealApp extends StatelessWidget {
  const ZealApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZEAL - Realize Your Dreams',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      routerConfig: _router,
    );
  }
}