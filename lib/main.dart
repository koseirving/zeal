import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'config/app_config.dart';
import 'config/dev/firebase_options.dart' as dev_options;
import 'config/prod/firebase_options.dart' as prod_options;
import 'screens/home_screen.dart';
import 'screens/content_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/tip_screen.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/login_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set environment to dev for now
  AppConfig.setEnvironment(Environment.dev);
  
  // Initialize Firebase with proper environment-specific options
  try {
    FirebaseOptions options;
    if (AppConfig.isDev) {
      options = dev_options.DefaultFirebaseOptions.currentPlatform;
      debugPrint('Using development Firebase project: zeal-develop');
    } else {
      options = prod_options.DefaultFirebaseOptions.currentPlatform;
      debugPrint('Using production Firebase project: zeal-product');
    }
    
    await Firebase.initializeApp(options: options);
    debugPrint('Firebase initialized successfully with project: ${options.projectId}');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Continue with app startup regardless
  }
  
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
  
  // Initialize anonymous authentication
  try {
    final authService = AuthService();
    
    // Check if user is already authenticated
    if (authService.isAuthenticated) {
      // Record login history for existing user
      if (authService.currentUserId != null) {
        final loginHistoryService = LoginHistoryService();
        await loginHistoryService.recordLogin(authService.currentUserId!);
      }
    } else {
      // Sign in anonymously (this will also record login history)
      await authService.signInAnonymously();
    }
    
    debugPrint('Anonymous authentication completed');
  } catch (e) {
    debugPrint('Failed to initialize anonymous authentication: $e');
    // Continue even if auth fails - app should still work
  }
  
  runApp(const ProviderScope(child: ZealApp()));
}

// Simple router without authentication guards
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