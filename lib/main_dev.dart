import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/dev/firebase_options.dart';
import 'config/app_config.dart';
import 'main.dart';
import 'services/notification_service.dart';

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
    
    // Initialize notification service
    await NotificationService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error in DEV: $e');
  }
  
  runApp(const ProviderScope(child: ZealApp()));
}