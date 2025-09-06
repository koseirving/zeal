import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'config/prod/firebase_options.dart';
import 'config/app_config.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'services/auth_service.dart';
import 'services/login_history_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Set environment
    AppConfig.setEnvironment(Environment.prod);
    
    // Initialize Firebase with prod configuration (check if already initialized)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully for PROD environment');
    } else {
      debugPrint('Firebase already initialized for PROD environment');
    }
    
    // Initialize authentication
    await _initializeAuthentication();
    
    // Initialize notification service
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error in PROD: $e');
  }
  
  runApp(const ProviderScope(child: ZealApp()));
}

// 認証の初期化
Future<void> _initializeAuthentication() async {
  try {
    debugPrint('PROD: Initializing authentication...');
    
    final auth = FirebaseAuth.instance;
    final authService = AuthService();
    final loginHistoryService = LoginHistoryService();
    
    // 現在の認証状態を確認
    final currentUser = auth.currentUser;
    
    if (currentUser != null) {
      debugPrint('PROD: User already authenticated: ${currentUser.uid}');
      // ログイン履歴を記録
      await loginHistoryService.recordLogin(currentUser.uid);
    } else {
      debugPrint('PROD: No authenticated user, signing in anonymously...');
      
      // 匿名サインインを実行
      final user = await authService.signInAnonymously();
      
      if (user != null) {
        debugPrint('PROD: Anonymous sign-in successful: ${user.id}');
      } else {
        debugPrint('PROD: Anonymous sign-in failed');
      }
    }
  } catch (e) {
    debugPrint('PROD: Authentication initialization error: $e');
    // 認証に失敗してもアプリは継続起動
  }
}