import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/dev/firebase_options.dart';
import 'config/app_config.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/login_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Set environment
    AppConfig.setEnvironment(Environment.dev);
    
    // Initialize Firebase with dev configuration (check if already initialized)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully for DEV environment');
    } else {
      debugPrint('Firebase already initialized for DEV environment');
    }
    
    // Initialize authentication
    await _initializeAuthentication();
    
    // Initialize notification service
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error in DEV: $e');
  }
  
  runApp(const ProviderScope(child: ZealApp()));
}

// 認証の初期化
Future<void> _initializeAuthentication() async {
  try {
    debugPrint('DEV: Initializing authentication...');
    
    final auth = FirebaseAuth.instance;
    final authService = AuthService();
    final loginHistoryService = LoginHistoryService();
    
    // 現在の認証状態を確認
    final currentUser = auth.currentUser;
    
    if (currentUser != null) {
      debugPrint('DEV: User already authenticated: ${currentUser.uid}');
      // ログイン履歴を記録
      await loginHistoryService.recordLogin(currentUser.uid);
    } else {
      debugPrint('DEV: No authenticated user, signing in anonymously...');
      
      // 匿名サインインを実行
      final user = await authService.signInAnonymously();
      
      if (user != null) {
        debugPrint('DEV: Anonymous sign-in successful: ${user.id}');
      } else {
        debugPrint('DEV: Anonymous sign-in failed');
      }
    }
  } catch (e) {
    debugPrint('DEV: Authentication initialization error: $e');
    // 認証に失敗してもアプリは継続起動
  }
}