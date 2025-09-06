import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class LoginHistoryService {
  static final LoginHistoryService _instance = LoginHistoryService._internal();
  factory LoginHistoryService() => _instance;
  LoginHistoryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> recordLogin(String userId) async {
    try {
      debugPrint('LoginHistoryService: Recording login for user: $userId');
      debugPrint('LoginHistoryService: Firestore project: zeal-product');
      
      final deviceInfo = await _getDeviceInfo().timeout(
        const Duration(seconds: 5),
        onTimeout: () => {
          'platform': 'Unknown',
          'model': 'Timeout',
          'version': 'Unknown',
        },
      );
      
      debugPrint('LoginHistoryService: Device info collected: ${deviceInfo['platform']} - ${deviceInfo['model']}');
      
      final packageInfo = await PackageInfo.fromPlatform().timeout(
        const Duration(seconds: 5),
        onTimeout: () => PackageInfo(
          appName: 'Zeal',
          packageName: 'com.zeal.zeal',
          version: '1.0.0',
          buildNumber: '1',
        ),
      );
      
      debugPrint('LoginHistoryService: App version: ${packageInfo.version} (${packageInfo.buildNumber})');
      
      final loginSession = {
        'loginAt': FieldValue.serverTimestamp(),
        'deviceInfo': deviceInfo,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };

      debugPrint('LoginHistoryService: Writing to Firestore path: users/$userId/login_history');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('login_history')
          .add(loginSession)
          .timeout(const Duration(seconds: 10));
          
      debugPrint('LoginHistoryService: Login recorded successfully');
    } catch (e) {
      debugPrint('LoginHistoryService: Failed to record login: $e');
      debugPrint('LoginHistoryService: Error type: ${e.runtimeType}');
      if (e.toString().contains('permission')) {
        debugPrint('LoginHistoryService: Permission denied - check Firestore rules');
      } else if (e.toString().contains('network')) {
        debugPrint('LoginHistoryService: Network error - check connectivity');
      }
      // Don't throw the error - login history is not critical for app functionality
    }
  }

  Future<Set<DateTime>> getLoginDays(String userId) async {
    try {
      debugPrint('LoginHistoryService: Fetching login days for user: $userId');
      debugPrint('LoginHistoryService: Query path: users/$userId/login_history');
      
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('login_history')
          .orderBy('loginAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));

      debugPrint('LoginHistoryService: Found ${querySnapshot.docs.length} login records');
      
      final loginDays = <DateTime>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final loginAt = (data['loginAt'] as Timestamp?)?.toDate();
        if (loginAt != null) {
          final dateOnly = DateTime(loginAt.year, loginAt.month, loginAt.day);
          loginDays.add(dateOnly);
          debugPrint('LoginHistoryService: Added login day: ${dateOnly.toString().split(' ')[0]}');
        }
      }

      debugPrint('LoginHistoryService: Total unique login days: ${loginDays.length}');
      return loginDays;
    } catch (e) {
      debugPrint('LoginHistoryService: Failed to get login days: $e');
      debugPrint('LoginHistoryService: Error type: ${e.runtimeType}');
      if (e.toString().contains('permission')) {
        debugPrint('LoginHistoryService: Permission denied - check Firestore rules');
      } else if (e.toString().contains('index')) {
        debugPrint('LoginHistoryService: Index required - check Firestore indexes');
      } else if (e.toString().contains('network')) {
        debugPrint('LoginHistoryService: Network error - check connectivity');
      }
      return {};
    }
  }

  Future<Map<String, int>> getLoginStats(String userId) async {
    try {
      debugPrint('LoginHistoryService: Calculating login stats for user: $userId');
      
      final loginDays = await getLoginDays(userId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final totalDays = loginDays.length;
      debugPrint('LoginHistoryService: Total login days: $totalDays');
      
      final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
      final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));
      final thisWeekCount = loginDays.where((date) => 
          date.isAfter(thisWeekStart.subtract(const Duration(days: 1))) && 
          date.isBefore(thisWeekEnd.add(const Duration(days: 1)))).length;
      debugPrint('LoginHistoryService: This week login count: $thisWeekCount');
      
      final streak = _calculateStreak(loginDays, today);
      debugPrint('LoginHistoryService: Current streak: $streak days');

      final stats = {
        'totalDays': totalDays,
        'thisWeek': thisWeekCount,
        'streak': streak,
      };
      
      debugPrint('LoginHistoryService: Login stats calculated successfully');
      return stats;
    } catch (e) {
      debugPrint('LoginHistoryService: Failed to get login stats: $e');
      debugPrint('LoginHistoryService: Returning default stats');
      return {
        'totalDays': 0,
        'thisWeek': 0,
        'streak': 0,
      };
    }
  }

  int _calculateStreak(Set<DateTime> loginDays, DateTime today) {
    if (loginDays.isEmpty) return 0;
    
    final sortedDays = loginDays.toList()..sort((a, b) => b.compareTo(a));
    
    if (!sortedDays.contains(today) && 
        !sortedDays.contains(today.subtract(const Duration(days: 1)))) {
      return 0;
    }
    
    int streak = 0;
    DateTime currentDate = sortedDays.contains(today) 
        ? today 
        : today.subtract(const Duration(days: 1));
    
    while (loginDays.contains(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return {
          'platform': 'Android',
          'model': androidInfo.model,
          'version': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return {
          'platform': 'iOS',
          'model': iosInfo.model,
          'version': iosInfo.systemVersion,
        };
      }
    } catch (e) {
      // Fallback to basic platform detection
      try {
        return {
          'platform': Platform.operatingSystem,
          'model': 'Simulator/Emulator',
          'version': Platform.operatingSystemVersion,
        };
      } catch (e2) {
        // Silent fallback
      }
    }
    
    return {
      'platform': 'Unknown',
      'model': 'Unknown',
      'version': 'Unknown',
    };
  }
}