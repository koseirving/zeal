import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/content_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/tip_screen.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (safe initialization)
  try {
    // Check if default app already exists
    try {
      Firebase.app(); // This will throw if no default app exists
      debugPrint('Firebase already initialized');
    } catch (_) {
      // No default app exists, safe to initialize
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    // Silently handle duplicate app error for development
    if (e.toString().contains('duplicate-app') || e.toString().contains('already exists')) {
      debugPrint('Firebase: Using existing instance');
    } else {
      debugPrint('Firebase initialization error: $e');
    }
    // Continue with app startup regardless
  }
  
  // Set environment to dev for now
  AppConfig.setEnvironment(Environment.dev);
  
  // Initialize notification service
  try {
    await NotificationService.initialize();
    debugPrint('Notification service initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize notification service: $e');
  }
  
  // Initialize Local Storage Service
  try {
    final storageService = LocalStorageService();
    final success = await storageService.initialize();
    final stats = await storageService.getStorageStats();
    debugPrint('Local storage initialized: ${stats['storageType']} (success: $success)');
  } catch (e) {
    debugPrint('Failed to initialize local storage: $e');
  }
  
  runApp(const ProviderScope(child: ZealApp()));
}


final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/content',
      builder: (context, state) {
        final tabParam = state.uri.queryParameters['tab'];
        final initialTab = tabParam != null ? int.tryParse(tabParam) : null;
        return ContentScreen(initialTab: initialTab);
      },
    ),
    GoRoute(
      path: '/affirmations',
      builder: (context, state) => const AffirmationsScreen(),
    ),
    GoRoute(
      path: '/tip',
      builder: (context, state) => const TipScreen(),
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