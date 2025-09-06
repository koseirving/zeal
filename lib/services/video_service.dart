import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import 'local_storage_service.dart';
import 'auth_service.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;
  VideoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalStorageService _localStorage = LocalStorageService();
  
  // Cache for offline support
  List<VideoModel>? _cachedVideos;
  DateTime? _lastCacheUpdate;
  static const Duration _cacheValidDuration = Duration(hours: 1);

  // Get all videos with offline support
  Future<List<VideoModel>> getVideos() async {
    try {
      debugPrint('VideoService: getVideos() called');
      debugPrint('VideoService: Environment: ${_auth.currentUser != null ? "Authenticated" : "Not authenticated"}');
      debugPrint('VideoService: User ID: ${_auth.currentUser?.uid ?? "None"}');
      
      // 認証確認と自動サインイン
      await _ensureAuthenticated();
      
      // Try to get from Firestore first
      final videos = await _getVideosFromFirestore();
      
      if (videos.isNotEmpty) {
        debugPrint('VideoService: Successfully retrieved ${videos.length} videos from Firestore');
        // Cache successful result
        _cachedVideos = videos;
        _lastCacheUpdate = DateTime.now();
        
        // Save to local storage for offline access
        await _saveVideosToLocal(videos);
        
        return videos;
      }
      
      debugPrint('VideoService: No videos found in Firestore, falling back to cache');
      // Fallback to cached data
      return await _getVideosFromCache();
      
    } catch (e) {
      debugPrint('VideoService: Error fetching videos: $e');
      debugPrint('VideoService: Falling back to cached/local data');
      
      // Fallback to cached/local data
      return await _getVideosFromCache();
    }
  }

  // 認証状態を確認し、必要に応じて匿名サインインを実行
  Future<void> _ensureAuthenticated() async {
    try {
      if (_auth.currentUser == null) {
        debugPrint('VideoService: No authenticated user, attempting anonymous sign-in...');
        
        final AuthService authService = AuthService();
        final user = await authService.signInAnonymously();
        
        if (user != null) {
          debugPrint('VideoService: Anonymous sign-in successful: ${user.id}');
        } else {
          debugPrint('VideoService: Anonymous sign-in failed');
          throw Exception('Authentication failed - unable to access videos');
        }
      } else {
        debugPrint('VideoService: User already authenticated: ${_auth.currentUser!.uid}');
      }
    } catch (e) {
      debugPrint('VideoService: Authentication error: $e');
      rethrow;
    }
  }

  // Get videos from Firestore
  Future<List<VideoModel>> _getVideosFromFirestore() async {
    try {
      debugPrint('VideoService: Attempting to fetch videos from Firestore...');
      debugPrint('VideoService: Project ID: zeal-product');
      
      final querySnapshot = await _firestore
          .collection('videos')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      debugPrint('VideoService: Query executed successfully');
      debugPrint('VideoService: Found ${querySnapshot.docs.length} documents');
      
      final videos = querySnapshot.docs
          .map((doc) {
            debugPrint('VideoService: Processing doc ID: ${doc.id}');
            return VideoModel.fromFirestore(doc);
          })
          .toList();
      
      // Sort by createdAt in memory since we can't use orderBy without index
      videos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      debugPrint('VideoService: Successfully fetched ${videos.length} videos from Firestore');
      return videos;
          
    } catch (e) {
      debugPrint('VideoService: Firestore error: $e');
      debugPrint('VideoService: Error type: ${e.runtimeType}');
      if (e.toString().contains('permission')) {
        debugPrint('VideoService: Permission denied - check Firestore rules');
      } else if (e.toString().contains('index')) {
        debugPrint('VideoService: Index required - check Firestore indexes');
      } else if (e.toString().contains('network')) {
        debugPrint('VideoService: Network error - check connectivity');
      }
      rethrow;
    }
  }

  // Get videos from cache or local storage
  Future<List<VideoModel>> _getVideosFromCache() async {
    debugPrint('VideoService: Attempting to retrieve videos from cache...');
    
    // Check memory cache first
    if (_cachedVideos != null && _lastCacheUpdate != null) {
      final cacheAge = DateTime.now().difference(_lastCacheUpdate!);
      if (cacheAge < _cacheValidDuration) {
        debugPrint('VideoService: Returning ${_cachedVideos!.length} videos from memory cache (age: ${cacheAge.inMinutes} minutes)');
        return _cachedVideos!;
      } else {
        debugPrint('VideoService: Memory cache expired (age: ${cacheAge.inMinutes} minutes)');
      }
    } else {
      debugPrint('VideoService: No memory cache available');
    }
    
    // Try local storage
    try {
      debugPrint('VideoService: Attempting to load from local storage...');
      final localVideos = await _getVideosFromLocal();
      if (localVideos.isNotEmpty) {
        debugPrint('VideoService: Returning ${localVideos.length} videos from local storage');
        _cachedVideos = localVideos;
        return localVideos;
      } else {
        debugPrint('VideoService: No videos found in local storage');
      }
    } catch (e) {
      debugPrint('VideoService: Local storage error: $e');
    }
    
    // Return empty list if all else fails in production
    debugPrint('VideoService: ERROR - No data available from any source');
    debugPrint('VideoService: Returning empty list');
    return [];
  }


  // Get video by ID
  Future<VideoModel?> getVideoById(String id) async {
    try {
      // Try Firestore first
      final doc = await _firestore
          .collection('videos')
          .doc(id)
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (doc.exists) {
        return VideoModel.fromFirestore(doc);
      }
      
      // Fallback to cached data
      final videos = await _getVideosFromCache();
      try {
        return videos.firstWhere((video) => video.id == id);
      } catch (e) {
        return null;
      }
      
    } catch (e) {
      debugPrint('VideoService: Error getting video by ID: $e');
      
      // Fallback to cached data
      final videos = await _getVideosFromCache();
      try {
        return videos.firstWhere((video) => video.id == id);
      } catch (e) {
        return null;
      }
    }
  }

  // Get videos by category
  Future<List<VideoModel>> getVideosByCategory(String category) async {
    try {
      // Try Firestore first
      final querySnapshot = await _firestore
          .collection('videos')
          .where('isActive', isEqualTo: true)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      final firestoreVideos = querySnapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc))
          .toList();
      
      if (firestoreVideos.isNotEmpty) {
        return firestoreVideos;
      }
      
    } catch (e) {
      debugPrint('VideoService: Error getting videos by category: $e');
    }
    
    // Fallback to cached data
    final videos = await _getVideosFromCache();
    return videos.where((video) => 
      video.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  // Increment view count
  Future<void> incrementViews(String videoId) async {
    try {
      // Update Firestore
      await _firestore
          .collection('videos')
          .doc(videoId)
          .update({
        'views': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 5));
      
      // Also track user's view history if authenticated
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          'totalVideosWatched': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
        
        // Add to user's view history
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('video_history')
            .add({
          'videoId': videoId,
          'viewedAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5));
      }
      
    } catch (e) {
      debugPrint('VideoService: Error incrementing views: $e');
      // Don't throw error for analytics - it shouldn't break user experience
    }
  }

  // Like/Unlike video
  Future<void> likeVideo(String videoId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw 'User must be logged in to like videos';
      }
      
      // Check if user already liked this video
      final likeDoc = await _firestore
          .collection('video_likes')
          .doc('${user.uid}_$videoId')
          .get()
          .timeout(const Duration(seconds: 5));
      
      if (likeDoc.exists) {
        // Unlike: Remove like and decrement count
        await _firestore
            .collection('video_likes')
            .doc('${user.uid}_$videoId')
            .delete();
        
        await _firestore
            .collection('videos')
            .doc(videoId)
            .update({
          'likes': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
      } else {
        // Like: Add like and increment count
        await _firestore
            .collection('video_likes')
            .doc('${user.uid}_$videoId')
            .set({
          'userId': user.uid,
          'videoId': videoId,
          'likedAt': FieldValue.serverTimestamp(),
        });
        
        await _firestore
            .collection('videos')
            .doc(videoId)
            .update({
          'likes': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
    } catch (e) {
      debugPrint('VideoService: Error liking video: $e');
      rethrow;
    }
  }

  // Save videos to local storage
  Future<void> _saveVideosToLocal(List<VideoModel> videos) async {
    try {
      final videosData = {
        'videos': videos.map((v) => v.toMap()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _localStorage.setJson('cached_videos', videosData);
      
    } catch (e) {
      debugPrint('VideoService: Error saving videos to local storage: $e');
    }
  }

  // Get videos from local storage
  Future<List<VideoModel>> _getVideosFromLocal() async {
    try {
      final videosData = await _localStorage.getJson('cached_videos');
      
      if (videosData != null && videosData['videos'] is List) {
        final videosList = videosData['videos'] as List;
        return videosList
            .map((videoMap) => VideoModel.fromMap(videoMap as Map<String, dynamic>))
            .toList();
      }
      
      return [];
      
    } catch (e) {
      debugPrint('VideoService: Error getting videos from local storage: $e');
      return [];
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      _cachedVideos = null;
      _lastCacheUpdate = null;
      await _localStorage.remove('cached_videos');
    } catch (e) {
      debugPrint('VideoService: Error clearing cache: $e');
    }
  }

  // Force refresh from Firestore
  Future<List<VideoModel>> refreshVideos() async {
    try {
      await clearCache();
      return await getVideos();
    } catch (e) {
      debugPrint('VideoService: Error refreshing videos: $e');
      return await _getVideosFromCache();
    }
  }

  // Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedVideos': _cachedVideos != null,
      'cachedVideoCount': _cachedVideos?.length ?? 0,
      'lastCacheUpdate': _lastCacheUpdate?.toIso8601String(),
      'cacheAge': _lastCacheUpdate != null 
          ? DateTime.now().difference(_lastCacheUpdate!).inMinutes 
          : null,
    };
  }
}