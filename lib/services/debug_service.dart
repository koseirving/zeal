import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DebugService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Test Firestore connection
  static Future<Map<String, dynamic>> testFirestoreConnection() async {
    debugPrint('DebugService: Starting connection test...');
    
    final result = <String, dynamic>{
      'connectionTest': false,
      'authStatus': false,
      'videoCount': 0,
      'musicCount': 0,
      'affirmationCount': 0,
      'error': null,
      'steps': [],
    };

    try {
      // Step 1: Check auth status
      debugPrint('DebugService: Step 1 - Checking auth status...');
      result['steps'].add('Checking auth status...');
      
      final user = _auth.currentUser;
      result['authStatus'] = user != null;
      result['userId'] = user?.uid;
      result['isAnonymous'] = user?.isAnonymous;
      
      debugPrint('DebugService: Auth status - User: ${user?.uid}, Anonymous: ${user?.isAnonymous}');
      result['steps'].add('Auth: ${user != null ? "OK" : "No user"}');

      // Step 2: Test basic Firestore connection with timeout
      debugPrint('DebugService: Step 2 - Testing Firestore connection...');
      result['steps'].add('Testing Firestore connection...');
      
      try {
        await _firestore.enableNetwork();
        result['connectionTest'] = true;
        debugPrint('DebugService: Firestore connection successful');
        result['steps'].add('Firestore connection: OK');
      } catch (e) {
        debugPrint('DebugService: Firestore enableNetwork failed: $e');
        result['connectionError'] = e.toString();
        result['steps'].add('Firestore connection: FAILED');
      }

      // Step 3: Count documents in each collection with individual timeouts
      debugPrint('DebugService: Step 3 - Counting documents...');
      result['steps'].add('Counting documents...');
      
      try {
        debugPrint('DebugService: Counting videos...');
        final videosSnapshot = await _firestore
            .collection('videos')
            .count()
            .get()
            .timeout(const Duration(seconds: 10));
        result['videoCount'] = videosSnapshot.count;
        debugPrint('DebugService: Video count: ${videosSnapshot.count}');
        result['steps'].add('Videos: ${videosSnapshot.count}');
      } catch (e) {
        debugPrint('DebugService: Video count failed: $e');
        result['videoError'] = e.toString();
        result['steps'].add('Videos: ERROR');
      }

      try {
        debugPrint('DebugService: Counting music...');
        final musicSnapshot = await _firestore
            .collection('music')
            .count()
            .get()
            .timeout(const Duration(seconds: 10));
        result['musicCount'] = musicSnapshot.count;
        debugPrint('DebugService: Music count: ${musicSnapshot.count}');
        result['steps'].add('Music: ${musicSnapshot.count}');
      } catch (e) {
        debugPrint('DebugService: Music count failed: $e');
        result['musicError'] = e.toString();
        result['steps'].add('Music: ERROR');
      }

      try {
        debugPrint('DebugService: Counting affirmations...');
        final affirmationsSnapshot = await _firestore
            .collection('affirmations')
            .count()
            .get()
            .timeout(const Duration(seconds: 10));
        result['affirmationCount'] = affirmationsSnapshot.count;
        debugPrint('DebugService: Affirmation count: ${affirmationsSnapshot.count}');
        result['steps'].add('Affirmations: ${affirmationsSnapshot.count}');
      } catch (e) {
        debugPrint('DebugService: Affirmation count failed: $e');
        result['affirmationError'] = e.toString();
        result['steps'].add('Affirmations: ERROR');
      }

      // Step 4: Test write operation
      debugPrint('DebugService: Step 4 - Testing write operation...');
      result['steps'].add('Testing write operation...');
      
      try {
        await _firestore
            .collection('debug_test')
            .add({
          'timestamp': FieldValue.serverTimestamp(),
          'userId': user?.uid,
          'testMessage': 'Connection test successful',
        }).timeout(const Duration(seconds: 10));
        result['writeTest'] = true;
        debugPrint('DebugService: Write test successful');
        result['steps'].add('Write test: OK');
      } catch (e) {
        debugPrint('DebugService: Write test failed: $e');
        result['writeTest'] = false;
        result['writeError'] = e.toString();
        result['steps'].add('Write test: FAILED');
      }

    } catch (e) {
      final errorMsg = e.toString();
      result['error'] = errorMsg;
      result['steps'].add('FATAL ERROR: $errorMsg');
      debugPrint('DebugService: Fatal error in connection test: $e');
    }

    debugPrint('DebugService: Connection test completed');
    debugPrint('DebugService: Result: $result');
    return result;
  }

  // Create sample data for testing
  static Future<void> createSampleData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('DebugService: No authenticated user for sample data creation');
        return;
      }

      // Create sample video
      await _firestore.collection('videos').add({
        'title': 'Sample Motivational Video',
        'description': 'This is a sample video created for testing Firestore integration.',
        'videoUrl': 'https://sample-videos.com/zip/10/mp4/SampleVideo_1280x720_1mb.mp4',
        'thumbnailUrl': 'https://via.placeholder.com/300x400/6366F1/FFFFFF?text=Sample+Video',
        'category': 'Testing',
        'likes': 0,
        'views': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': user.uid,
        'tags': ['sample', 'test'],
      });

      // Create sample music
      await _firestore.collection('music').add({
        'title': 'Sample Focus Music',
        'artist': 'Test Artist',
        'audioUrl': 'https://www.soundjay.com/misc/sounds/magic-chime-02.wav',
        'imageUrl': '',
        'category': 'Testing',
        'duration': 120,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': user.uid,
        'tags': ['sample', 'test'],
        'playCount': 0,
      });

      // Create sample affirmation
      await _firestore.collection('affirmations').add({
        'text': 'This is a sample affirmation created for testing Firestore integration.',
        'category': 'Testing',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'createdBy': user.uid,
        'tags': ['sample', 'test'],
        'viewCount': 0,
      });

      debugPrint('DebugService: Sample data created successfully');
    } catch (e) {
      debugPrint('DebugService: Failed to create sample data: $e');
      rethrow;
    }
  }
}