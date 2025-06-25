import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SimpleDebugService {
  
  static Future<Map<String, dynamic>> runBasicTests() async {
    final result = <String, dynamic>{};
    
    try {
      // Test 1: Firebase App
      debugPrint('SimpleDebug: Testing Firebase app...');
      final app = Firebase.app();
      result['firebaseApp'] = {
        'name': app.name,
        'options': app.options.toString(),
      };
      debugPrint('SimpleDebug: Firebase app OK');
      
      // Test 2: Firebase Auth
      debugPrint('SimpleDebug: Testing Firebase Auth...');
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      result['auth'] = {
        'hasCurrentUser': currentUser != null,
        'userId': currentUser?.uid,
        'isAnonymous': currentUser?.isAnonymous,
        'authStateChanges': 'listening',
      };
      
      // If no user, try to sign in anonymously
      if (currentUser == null) {
        debugPrint('SimpleDebug: No current user, attempting anonymous sign in...');
        try {
          final userCredential = await auth.signInAnonymously();
          result['auth']['signInResult'] = 'success';
          result['auth']['newUserId'] = userCredential.user?.uid;
          debugPrint('SimpleDebug: Anonymous sign in successful: ${userCredential.user?.uid}');
        } catch (e) {
          result['auth']['signInError'] = e.toString();
          debugPrint('SimpleDebug: Anonymous sign in failed: $e');
        }
      }
      
      // Test 3: Firestore basic connection
      debugPrint('SimpleDebug: Testing Firestore...');
      final firestore = FirebaseFirestore.instance;
      
      try {
        // Simple read test - try to get a single document that doesn't exist
        final docRef = firestore.collection('test').doc('connection_test');
        final docSnapshot = await docRef.get().timeout(const Duration(seconds: 15));
        
        result['firestore'] = {
          'connectionTest': 'success',
          'docExists': docSnapshot.exists,
          'metadata': {
            'isFromCache': docSnapshot.metadata.isFromCache,
            'hasPendingWrites': docSnapshot.metadata.hasPendingWrites,
          }
        };
        debugPrint('SimpleDebug: Firestore connection successful');
        
        // Test 4: Simple write test
        debugPrint('SimpleDebug: Testing Firestore write...');
        try {
          await docRef.set({
            'timestamp': FieldValue.serverTimestamp(),
            'testMessage': 'Simple connection test',
            'userId': auth.currentUser?.uid,
          }).timeout(const Duration(seconds: 15));
          
          result['firestore']['writeTest'] = 'success';
          debugPrint('SimpleDebug: Firestore write successful');
          
          // Clean up
          await docRef.delete();
          debugPrint('SimpleDebug: Test document deleted');
          
        } catch (e) {
          result['firestore']['writeError'] = e.toString();
          debugPrint('SimpleDebug: Firestore write failed: $e');
        }
        
      } catch (e) {
        result['firestore'] = {
          'connectionTest': 'failed',
          'error': e.toString(),
        };
        debugPrint('SimpleDebug: Firestore connection failed: $e');
      }
      
    } catch (e) {
      result['fatalError'] = e.toString();
      debugPrint('SimpleDebug: Fatal error: $e');
    }
    
    debugPrint('SimpleDebug: Test completed. Result: $result');
    return result;
  }
}