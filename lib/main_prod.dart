import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/prod/firebase_options.dart';
import 'config/app_config.dart';
import 'main.dart';

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
      print('Firebase initialized successfully for PROD environment');
    } else {
      print('Firebase already initialized for PROD environment');
    }
  } catch (e) {
    print('Firebase initialization error in PROD: $e');
  }
  
  runApp(const MyApp());
}