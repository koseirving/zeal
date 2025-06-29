import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/music_model.dart';
import 'local_storage_service.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;
  MusicService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  
  // Cache for offline support
  List<MusicModel>? _cachedMusic;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  // Get all music with offline support
  Future<List<MusicModel>> getMusic() async {
    try {
      // Try to get from Firestore first
      final music = await _getMusicFromFirestore();
      
      if (music.isNotEmpty) {
        // Cache successful result
        _cachedMusic = music;
        _lastCacheUpdate = DateTime.now();
        
        // Save to local storage for offline access
        await _saveMusicToLocal(music);
        
        return music;
      }
      
      // Fallback to cached data
      return await _getMusicFromCache();
      
    } catch (e) {
      debugPrint('MusicService: Error fetching music: $e');
      
      // Fallback to cached/local data
      return await _getMusicFromCache();
    }
  }

  // Get music from Firestore
  Future<List<MusicModel>> _getMusicFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection('music')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      return querySnapshot.docs
          .map((doc) => MusicModel.fromFirestore(doc))
          .toList();
          
    } catch (e) {
      debugPrint('MusicService: Firestore error: $e');
      rethrow;
    }
  }

  // Get music from cache or local storage
  Future<List<MusicModel>> _getMusicFromCache() async {
    // Check memory cache first
    if (_cachedMusic != null && _lastCacheUpdate != null) {
      final cacheAge = DateTime.now().difference(_lastCacheUpdate!);
      if (cacheAge < _cacheValidDuration) {
        debugPrint('MusicService: Returning from memory cache');
        return _cachedMusic!;
      }
    }
    
    // Try local storage
    try {
      final localMusic = await _getMusicFromLocal();
      if (localMusic.isNotEmpty) {
        debugPrint('MusicService: Returning from local storage');
        _cachedMusic = localMusic;
        return localMusic;
      }
    } catch (e) {
      debugPrint('MusicService: Local storage error: $e');
    }
    
    // Fallback to mock data if all else fails
    return _getMockMusic();
  }

  // Get minimal mock music for emergency fallback only
  List<MusicModel> _getMockMusic() {
    // Return only a single mock item to indicate the service is working
    // but database/cache is unavailable
    return [
      MusicModel(
        id: 'mock_fallback',
        title: 'サンプル音楽',
        artist: 'システムサンプル',
        audioUrl: '',
        imageUrl: '',
        category: 'System',
        duration: 300, // 5 minutes
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Get music by ID
  Future<MusicModel?> getMusicById(String id) async {
    try {
      // Try Firestore first
      final doc = await _firestore
          .collection('music')
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (doc.exists) {
        return MusicModel.fromFirestore(doc);
      }
      
      // Fallback to cached data
      final music = await _getMusicFromCache();
      try {
        return music.firstWhere((m) => m.id == id);
      } catch (e) {
        return null;
      }
      
    } catch (e) {
      debugPrint('MusicService: Error getting music by ID: $e');
      
      // Fallback to cached data
      final music = await _getMusicFromCache();
      try {
        return music.firstWhere((m) => m.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get music by category
  Future<List<MusicModel>> getMusicByCategory(String category) async {
    try {
      // Try Firestore first
      final querySnapshot = await _firestore
          .collection('music')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      final firestoreMusic = querySnapshot.docs
          .map((doc) => MusicModel.fromFirestore(doc))
          .toList();
      
      if (firestoreMusic.isNotEmpty) {
        return firestoreMusic;
      }
      
    } catch (e) {
      debugPrint('MusicService: Error getting music by category: $e');
    }
    
    // Fallback to cached data
    final music = await _getMusicFromCache();
    return music.where((m) => 
      m.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Search music
  Future<List<MusicModel>> searchMusic(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      // Try Firestore first (note: this is a simple implementation, 
      // for better search you might want to use Algolia or similar)
      final querySnapshot = await _firestore
          .collection('music')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      final lowerQuery = query.toLowerCase();
      final firestoreMusic = querySnapshot.docs
          .map((doc) => MusicModel.fromFirestore(doc))
          .where((music) =>
              music.title.toLowerCase().contains(lowerQuery) ||
              music.artist.toLowerCase().contains(lowerQuery) ||
              music.category.toLowerCase().contains(lowerQuery))
          .toList();
      
      if (firestoreMusic.isNotEmpty) {
        return firestoreMusic;
      }
      
    } catch (e) {
      debugPrint('MusicService: Error searching music: $e');
    }
    
    // Fallback to cached data
    final music = await _getMusicFromCache();
    final lowerQuery = query.toLowerCase();
    return music.where((m) => 
      m.title.toLowerCase().contains(lowerQuery) ||
      m.artist.toLowerCase().contains(lowerQuery) ||
      m.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  // Increment play count
  Future<void> incrementPlayCount(String musicId) async {
    try {
      // Update Firestore
      await _firestore
          .collection('music')
          .doc(musicId)
          .update({
        'playCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));
      
      // Also track user's play history if authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'totalMusicPlayed': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
        
        // Add to user's play history
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('music_history')
            .add({
          'musicId': musicId,
          'playedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
      }
      
    } catch (e) {
      debugPrint('MusicService: Error incrementing play count: $e');
      // Don't throw error for analytics - it shouldn't break user experience
    }
  }

  // Save music to local storage
  Future<void> _saveMusicToLocal(List<MusicModel> music) async {
    try {
      final musicData = {
        'music': music.map((m) => m.toMap()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _localStorage.setJson('cached_music', musicData);
      
    } catch (e) {
      debugPrint('MusicService: Error saving music to local storage: $e');
    }
  }

  // Get music from local storage
  Future<List<MusicModel>> _getMusicFromLocal() async {
    try {
      final musicData = await _localStorage.getJson('cached_music');
      
      if (musicData != null && musicData['music'] is List) {
        final musicList = musicData['music'] as List;
        return musicList
            .map((musicMap) => MusicModel.fromMap(musicMap as Map<String, dynamic>))
            .toList();
      }
      
      return [];
      
    } catch (e) {
      debugPrint('MusicService: Error getting music from local storage: $e');
      return [];
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      _cachedMusic = null;
      _lastCacheUpdate = null;
      await _localStorage.remove('cached_music');
    } catch (e) {
      debugPrint('MusicService: Error clearing cache: $e');
    }
  }

  // Force refresh from Firestore
  Future<List<MusicModel>> refreshMusic() async {
    try {
      await clearCache();
      return await getMusic();
    } catch (e) {
      debugPrint('MusicService: Error refreshing music: $e');
      return await _getMusicFromCache();
    }
  }

  // Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedMusic': _cachedMusic != null,
      'cachedMusicCount': _cachedMusic?.length ?? 0,
      'lastCacheUpdate': _lastCacheUpdate?.toIso8601String(),
      'cacheAge': _lastCacheUpdate != null 
          ? DateTime.now().difference(_lastCacheUpdate!).inMinutes 
          : null,
    };
  }
}