import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class UsageStatsService {
  static final UsageStatsService _instance = UsageStatsService._internal();
  factory UsageStatsService() => _instance;
  UsageStatsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalStorageService _localStorage = LocalStorageService();

  static const String _cacheKeyPrefix = 'usage_stats_';

  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      // Try to get from cache first
      final cachedStats = await _getCachedStats(userId);
      if (cachedStats != null) {
        return cachedStats;
      }

      // Get from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('usage_stats')
          .doc('stats')
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        final data = doc.data()!;
        final stats = {
          'totalFocusMinutes': (data['totalFocusMinutes'] ?? 0) as int,
          'totalDays': (data['totalDays'] ?? 0) as int,
        };
        
        // Cache the result
        await _cacheStats(userId, stats);
        
        return stats;
      }

      // Initialize if doesn't exist
      final initialStats = {
        'totalFocusMinutes': 0,
        'totalDays': 0,
      };
      
      await _initializeStats(userId);
      return initialStats;
    } catch (e) {
      debugPrint('Failed to get user stats: $e');
      
      // Try to return cached data on error
      final cachedStats = await _getCachedStats(userId);
      if (cachedStats != null) {
        return cachedStats;
      }
      
      return {
        'totalFocusMinutes': 0,
        'totalDays': 0,
      };
    }
  }

  Future<void> recordFocusTime(String userId, int minutes) async {
    if (minutes <= 0) return;
    
    try {
      final statsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('usage_stats')
          .doc('stats');

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(statsRef);
        
        if (doc.exists) {
          final currentMinutes = doc.data()?['totalFocusMinutes'] ?? 0;
          transaction.update(statsRef, {
            'totalFocusMinutes': currentMinutes + minutes,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(statsRef, {
            'totalFocusMinutes': minutes,
            'totalDays': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }).timeout(const Duration(seconds: 10));
      
      // Clear cache to force refresh
      await _clearCache(userId);
    } catch (e) {
      debugPrint('Failed to record focus time: $e');
      // Continue silently - stats are not critical
    }
  }

  Future<void> recordDailyUsage(String userId) async {
    try {
      final statsRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('usage_stats')
          .doc('stats');

      final dailyRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('usage_stats')
          .doc('daily_usage');

      final now = DateTime.now();
      final dateKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await _firestore.runTransaction((transaction) async {
        final dailyDoc = await transaction.get(dailyRef);
        final statsDoc = await transaction.get(statsRef);
        
        // Check if already recorded today
        if (dailyDoc.exists) {
          final lastDate = dailyDoc.data()?['lastDate'];
          if (lastDate == dateKey) {
            return; // Already recorded today
          }
        }
        
        // Update daily record
        transaction.set(dailyRef, {
          'lastDate': dateKey,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Increment total days
        if (statsDoc.exists) {
          final currentDays = statsDoc.data()?['totalDays'] ?? 0;
          transaction.update(statsRef, {
            'totalDays': currentDays + 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(statsRef, {
            'totalFocusMinutes': 0,
            'totalDays': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }).timeout(const Duration(seconds: 10));
      
      // Clear cache to force refresh
      await _clearCache(userId);
    } catch (e) {
      debugPrint('Failed to record daily usage: $e');
      // Continue silently
    }
  }

  Future<void> _initializeStats(String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('usage_stats')
          .doc('stats')
          .set({
        'totalFocusMinutes': 0,
        'totalDays': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Failed to initialize stats: $e');
    }
  }

  Future<Map<String, int>?> _getCachedStats(String userId) async {
    try {
      final cachedData = await _localStorage.getJson('$_cacheKeyPrefix$userId');
      if (cachedData != null) {
        return {
          'totalFocusMinutes': cachedData['totalFocusMinutes'] ?? 0,
          'totalDays': cachedData['totalDays'] ?? 0,
        };
      }
    } catch (e) {
      debugPrint('Failed to get cached stats: $e');
    }
    return null;
  }

  Future<void> _cacheStats(String userId, Map<String, int> stats) async {
    try {
      await _localStorage.setJson('$_cacheKeyPrefix$userId', stats);
    } catch (e) {
      debugPrint('Failed to cache stats: $e');
    }
  }

  Future<void> _clearCache(String userId) async {
    try {
      await _localStorage.remove('$_cacheKeyPrefix$userId');
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  int minutesToHours(int minutes) {
    return (minutes / 60).floor();
  }
}