import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/home_screen.dart';
import 'screens/content_screen.dart';
import 'screens/affirmations_screen.dart';
import 'screens/tip_screen.dart';

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
      debugShowCheckedModeBanner: false,
    );
  }
}