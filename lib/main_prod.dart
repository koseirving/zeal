import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/prod/firebase_options.dart';
import 'config/app_config.dart';
import 'main.dart';
import 'services/notification_service.dart';

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
    
    // Initialize notification service
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error in PROD: $e');
  }
  
  runApp(const ProviderScope(child: ZealApp()));
}