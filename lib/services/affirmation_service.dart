import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/affirmation_model.dart';
import 'local_storage_service.dart';

class AffirmationService {
  static final AffirmationService _instance = AffirmationService._internal();
  factory AffirmationService() => _instance;
  AffirmationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  
  // Cache for offline support
  List<AffirmationModel>? _cachedAffirmations;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  // Get all affirmations with offline support
  Future<List<AffirmationModel>> getAffirmations() async {
    try {
      // Try to get from Firestore first
      final affirmations = await _getAffirmationsFromFirestore();
      
      if (affirmations.isNotEmpty) {
        // Cache successful result
        _cachedAffirmations = affirmations;
        _lastCacheUpdate = DateTime.now();
        
        // Save to local storage for offline access
        await _saveAffirmationsToLocal(affirmations);
        
        return affirmations;
      }
      
      // Fallback to cached data
      return await _getAffirmationsFromCache();
      
    } catch (e) {
      debugPrint('AffirmationService: Error fetching affirmations: $e');
      
      // Fallback to cached/local data
      return await _getAffirmationsFromCache();
    }
  }

  // Get affirmations from Firestore
  Future<List<AffirmationModel>> _getAffirmationsFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection('affirmations')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      return querySnapshot.docs
          .map((doc) => AffirmationModel.fromFirestore(doc))
          .toList();
          
    } catch (e) {
      debugPrint('AffirmationService: Firestore error: $e');
      rethrow;
    }
  }

  // Get affirmations from cache or local storage
  Future<List<AffirmationModel>> _getAffirmationsFromCache() async {
    // Check memory cache first
    if (_cachedAffirmations != null && _lastCacheUpdate != null) {
      final cacheAge = DateTime.now().difference(_lastCacheUpdate!);
      if (cacheAge < _cacheValidDuration) {
        debugPrint('AffirmationService: Returning from memory cache');
        return _cachedAffirmations!;
      }
    }
    
    // Try local storage
    try {
      final localAffirmations = await _getAffirmationsFromLocal();
      if (localAffirmations.isNotEmpty) {
        debugPrint('AffirmationService: Returning from local storage');
        _cachedAffirmations = localAffirmations;
        return localAffirmations;
      }
    } catch (e) {
      debugPrint('AffirmationService: Local storage error: $e');
    }
    
    // Fallback to mock data if all else fails
    debugPrint('AffirmationService: Returning mock data as fallback');
    return _getMockAffirmations();
  }

  // Get mock affirmations for fallback
  List<AffirmationModel> _getMockAffirmations() {
    return [
      AffirmationModel(
        id: '1',
        text: 'I am capable of achieving my dreams and goals.',
        category: 'Success',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      AffirmationModel(
        id: '2',
        text: 'I choose to focus on what I can control and let go of what I cannot.',
        category: 'Mindfulness',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AffirmationModel(
        id: '3',
        text: 'Every challenge I face is an opportunity to grow stronger.',
        category: 'Growth',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      AffirmationModel(
        id: '4',
        text: 'I am worthy of love, respect, and all the good things life has to offer.',
        category: 'Self-Love',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      AffirmationModel(
        id: '5',
        text: 'I trust in my ability to make the right decisions for my life.',
        category: 'Confidence',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AffirmationModel(
        id: '6',
        text: 'Today I choose to see the beauty and possibilities around me.',
        category: 'Positivity',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
      AffirmationModel(
        id: '7',
        text: 'I am grateful for all the lessons life has taught me.',
        category: 'Gratitude',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      AffirmationModel(
        id: '8',
        text: 'I have the power to create the life I desire.',
        category: 'Empowerment',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now().subtract(const Duration(days: 8)),
      ),
      AffirmationModel(
        id: '9',
        text: 'I embrace change as a natural part of my growth journey.',
        category: 'Growth',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
      AffirmationModel(
        id: '10',
        text: 'I am resilient and can overcome any obstacle in my path.',
        category: 'Strength',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      AffirmationModel(
        id: '11',
        text: 'I radiate positive energy and attract positive experiences.',
        category: 'Positivity',
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        updatedAt: DateTime.now().subtract(const Duration(days: 11)),
      ),
      AffirmationModel(
        id: '12',
        text: 'I am proud of how far I have come and excited for where I am going.',
        category: 'Self-Love',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      AffirmationModel(
        id: '13',
        text: 'I deserve success and I am willing to work for it.',
        category: 'Success',
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
        updatedAt: DateTime.now().subtract(const Duration(days: 13)),
      ),
      AffirmationModel(
        id: '14',
        text: 'I am at peace with my past and excited about my future.',
        category: 'Peace',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
      AffirmationModel(
        id: '15',
        text: 'I trust the process of life and know that everything happens for a reason.',
        category: 'Faith',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }

  // Get daily affirmation
  Future<AffirmationModel?> getDailyAffirmation() async {
    try {
      final affirmations = await getAffirmations();
      
      if (affirmations.isEmpty) return null;
      
      // Use a deterministic random based on today's date
      final today = DateTime.now();
      final daysSinceEpoch = today.difference(DateTime(1970)).inDays;
      final random = Random(daysSinceEpoch);
      
      final randomIndex = random.nextInt(affirmations.length);
      final dailyAffirmation = affirmations[randomIndex];
      
      // Track view if user is authenticated
      await _trackAffirmationView(dailyAffirmation.id);
      
      return dailyAffirmation;
      
    } catch (e) {
      debugPrint('AffirmationService: Error getting daily affirmation: $e');
      return null;
    }
  }

  // Get affirmations by category
  Future<List<AffirmationModel>> getAffirmationsByCategory(String category) async {
    try {
      // Try Firestore first
      final querySnapshot = await _firestore
          .collection('affirmations')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      final firestoreAffirmations = querySnapshot.docs
          .map((doc) => AffirmationModel.fromFirestore(doc))
          .toList();
      
      if (firestoreAffirmations.isNotEmpty) {
        return firestoreAffirmations;
      }
      
    } catch (e) {
      debugPrint('AffirmationService: Error getting affirmations by category: $e');
    }
    
    // Fallback to cached data
    final affirmations = await _getAffirmationsFromCache();
    return affirmations.where((affirmation) => 
      affirmation.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Get affirmation by ID
  Future<AffirmationModel?> getAffirmationById(String id) async {
    try {
      // Try Firestore first
      final doc = await _firestore
          .collection('affirmations')
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (doc.exists) {
        final affirmation = AffirmationModel.fromFirestore(doc);
        await _trackAffirmationView(id);
        return affirmation;
      }
      
      // Fallback to cached data
      final affirmations = await _getAffirmationsFromCache();
      try {
        final affirmation = affirmations.firstWhere((a) => a.id == id);
        await _trackAffirmationView(id);
        return affirmation;
      } catch (e) {
        return null;
      }
      
    } catch (e) {
      debugPrint('AffirmationService: Error getting affirmation by ID: $e');
      
      // Fallback to cached data
      final affirmations = await _getAffirmationsFromCache();
      try {
        return affirmations.firstWhere((a) => a.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get categories
  Future<List<String>> getCategories() async {
    try {
      final affirmations = await getAffirmations();
      
      final categories = affirmations
          .map((affirmation) => affirmation.category)
          .toSet()
          .toList();
      
      categories.sort();
      return categories;
      
    } catch (e) {
      debugPrint('AffirmationService: Error getting categories: $e');
      return [];
    }
  }

  // Search affirmations
  Future<List<AffirmationModel>> searchAffirmations(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // Try Firestore first (note: this is a simple implementation, 
      // for better search you might want to use Algolia or similar)
      final querySnapshot = await _firestore
          .collection('affirmations')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      final lowerQuery = query.toLowerCase();
      final firestoreAffirmations = querySnapshot.docs
          .map((doc) => AffirmationModel.fromFirestore(doc))
          .where((affirmation) =>
              affirmation.text.toLowerCase().contains(lowerQuery) ||
              affirmation.category.toLowerCase().contains(lowerQuery))
          .toList();
      
      if (firestoreAffirmations.isNotEmpty) {
        return firestoreAffirmations;
      }
      
    } catch (e) {
      debugPrint('AffirmationService: Error searching affirmations: $e');
    }
    
    // Fallback to cached data
    final affirmations = await _getAffirmationsFromCache();
    final lowerQuery = query.toLowerCase();
    return affirmations.where((affirmation) => 
      affirmation.text.toLowerCase().contains(lowerQuery) ||
      affirmation.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Get random affirmations
  Future<List<AffirmationModel>> getRandomAffirmations(int count) async {
    try {
      final affirmations = await getAffirmations();
      
      if (affirmations.isEmpty) return [];
      
      final random = Random();
      final shuffled = List<AffirmationModel>.from(affirmations)..shuffle(random);
      
      final result = shuffled.take(count).toList();
      
      // Track views for random affirmations
      for (final affirmation in result) {
        await _trackAffirmationView(affirmation.id);
      }
      
      return result;
      
    } catch (e) {
      debugPrint('AffirmationService: Error getting random affirmations: $e');
      return [];
    }
  }

  // Track affirmation view
  Future<void> _trackAffirmationView(String affirmationId) async {
    try {
      // Update Firestore
      await _firestore
          .collection('affirmations')
          .doc(affirmationId)
          .update({
        'viewCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));
      
      // Also track user's view history if authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'totalAffirmationsViewed': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
        
        // Add to user's view history
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('affirmation_history')
            .add({
          'affirmationId': affirmationId,
          'viewedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
      }
      
    } catch (e) {
      debugPrint('AffirmationService: Error tracking affirmation view: $e');
      // Don't throw error for analytics - it shouldn't break user experience
    }
  }

  // Save affirmations to local storage
  Future<void> _saveAffirmationsToLocal(List<AffirmationModel> affirmations) async {
    try {
      final affirmationsData = {
        'affirmations': affirmations.map((a) => a.toMap()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _localStorage.setJson('cached_affirmations', affirmationsData);
      
    } catch (e) {
      debugPrint('AffirmationService: Error saving affirmations to local storage: $e');
    }
  }

  // Get affirmations from local storage
  Future<List<AffirmationModel>> _getAffirmationsFromLocal() async {
    try {
      final affirmationsData = await _localStorage.getJson('cached_affirmations');
      
      if (affirmationsData != null && affirmationsData['affirmations'] is List) {
        final affirmationsList = affirmationsData['affirmations'] as List;
        return affirmationsList
            .map((affirmationMap) => AffirmationModel.fromMap(affirmationMap as Map<String, dynamic>))
            .toList();
      }
      
      return [];
      
    } catch (e) {
      debugPrint('AffirmationService: Error getting affirmations from local storage: $e');
      return [];
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      _cachedAffirmations = null;
      _lastCacheUpdate = null;
      await _localStorage.remove('cached_affirmations');
    } catch (e) {
      debugPrint('AffirmationService: Error clearing cache: $e');
    }
  }

  // Force refresh from Firestore
  Future<List<AffirmationModel>> refreshAffirmations() async {
    try {
      await clearCache();
      return await getAffirmations();
    } catch (e) {
      debugPrint('AffirmationService: Error refreshing affirmations: $e');
      return await _getAffirmationsFromCache();
    }
  }

  // Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedAffirmations': _cachedAffirmations != null,
      'cachedAffirmationCount': _cachedAffirmations?.length ?? 0,
      'lastCacheUpdate': _lastCacheUpdate?.toIso8601String(),
      'cacheAge': _lastCacheUpdate != null 
          ? DateTime.now().difference(_lastCacheUpdate!).inMinutes 
          : null,
    };
  }
}