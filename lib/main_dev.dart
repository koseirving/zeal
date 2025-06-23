import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/dev/firebase_options.dart';
import 'config/app_config.dart';
import 'main.dart';

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
      print('Firebase initialized successfully for DEV environment');
    } else {
      print('Firebase already initialized for DEV environment');
    }
  } catch (e) {
    print('Firebase initialization error in DEV: $e');
  }
  
  runApp(const MyApp());
}