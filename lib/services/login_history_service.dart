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
      final deviceInfo = await _getDeviceInfo();
      final packageInfo = await PackageInfo.fromPlatform();
      
      final loginSession = {
        'loginAt': FieldValue.serverTimestamp(),
        'deviceInfo': deviceInfo,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('login_history')
          .add(loginSession);
    } catch (e) {
      debugPrint('Failed to record login: $e');
    }
  }

  Future<Set<DateTime>> getLoginDays(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('login_history')
          .orderBy('loginAt', descending: true)
          .get();

      final loginDays = <DateTime>{};
      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final loginAt = (data['loginAt'] as Timestamp?)?.toDate();
        if (loginAt != null) {
          final dateOnly = DateTime(loginAt.year, loginAt.month, loginAt.day);
          loginDays.add(dateOnly);
        }
      }

      return loginDays;
    } catch (e) {
      debugPrint('Failed to get login days: $e');
      return {};
    }
  }

  Future<Map<String, int>> getLoginStats(String userId) async {
    try {
      final loginDays = await getLoginDays(userId);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final totalDays = loginDays.length;
      
      final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
      final thisWeekEnd = thisWeekStart.add(const Duration(days: 6));
      final thisWeekCount = loginDays.where((date) => 
          date.isAfter(thisWeekStart.subtract(const Duration(days: 1))) && 
          date.isBefore(thisWeekEnd.add(const Duration(days: 1)))).length;
      
      final streak = _calculateStreak(loginDays, today);

      return {
        'totalDays': totalDays,
        'thisWeek': thisWeekCount,
        'streak': streak,
      };
    } catch (e) {
      debugPrint('Failed to get login stats: $e');
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