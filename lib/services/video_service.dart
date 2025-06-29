import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import 'local_storage_service.dart';

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
      // Try to get from Firestore first
      final videos = await _getVideosFromFirestore();
      
      if (videos.isNotEmpty) {
        // Cache successful result
        _cachedVideos = videos;
        _lastCacheUpdate = DateTime.now();
        
        // Save to local storage for offline access
        await _saveVideosToLocal(videos);
        
        return videos;
      }
      
      // Fallback to cached data
      return await _getVideosFromCache();
      
    } catch (e) {
      debugPrint('VideoService: Error fetching videos: $e');
      
      // Fallback to cached/local data
      return await _getVideosFromCache();
    }
  }

  // Get videos from Firestore
  Future<List<VideoModel>> _getVideosFromFirestore() async {
    try {
      final querySnapshot = await _firestore
          .collection('videos')
          .where('isActive', isEqualTo: true)
          .get()
          .timeout(const Duration(seconds: 10));
      
      final videos = querySnapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt in memory since we can't use orderBy without index
      videos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return videos;
          
    } catch (e) {
      debugPrint('VideoService: Firestore error: $e');
      rethrow;
    }
  }

  // Get videos from cache or local storage
  Future<List<VideoModel>> _getVideosFromCache() async {
    // Check memory cache first
    if (_cachedVideos != null && _lastCacheUpdate != null) {
      final cacheAge = DateTime.now().difference(_lastCacheUpdate!);
      if (cacheAge < _cacheValidDuration) {
        debugPrint('VideoService: Returning from memory cache');
        return _cachedVideos!;
      }
    }
    
    // Try local storage
    try {
      final localVideos = await _getVideosFromLocal();
      if (localVideos.isNotEmpty) {
        debugPrint('VideoService: Returning from local storage');
        _cachedVideos = localVideos;
        return localVideos;
      }
    } catch (e) {
      debugPrint('VideoService: Local storage error: $e');
    }
    
    // Fallback to mock data if all else fails
    debugPrint('VideoService: Returning mock data as fallback');
    return _getMockVideos();
  }

  // Get mock videos for fallback
  List<VideoModel> _getMockVideos() {
    return [
      VideoModel(
        id: '1',
        title: 'Never Give Up - Motivational Speech',
        description: 'A powerful speech about perseverance and achieving your dreams. Learn how to push through challenges and never give up on your goals.',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnailUrl: 'https://via.placeholder.com/300x400/6366F1/FFFFFF?text=Never+Give+Up',
        category: 'Motivation',
        likes: 1240,
        views: 15670,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VideoModel(
        id: '2',
        title: 'Success Mindset - Daily Habits',
        description: 'Discover the daily habits that successful people practice every day. Transform your mindset and achieve extraordinary results.',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        thumbnailUrl: 'https://via.placeholder.com/300x400/8B5CF6/FFFFFF?text=Success+Mindset',
        category: 'Success',
        likes: 890,
        views: 12450,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      VideoModel(
        id: '3',
        title: 'Overcome Fear - Face Your Challenges',
        description: 'Learn how to overcome fear and step out of your comfort zone. Build confidence and tackle any challenge that comes your way.',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        thumbnailUrl: 'https://via.placeholder.com/300x400/A855F7/FFFFFF?text=Overcome+Fear',
        category: 'Personal Growth',
        likes: 567,
        views: 8920,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      VideoModel(
        id: '4',
        title: 'Dream Big - Visualization Techniques',
        description: 'Master the art of visualization to manifest your dreams. Learn powerful techniques used by top performers worldwide.',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        thumbnailUrl: 'https://via.placeholder.com/300x400/06B6D4/FFFFFF?text=Dream+Big',
        category: 'Visualization',
        likes: 2100,
        views: 25300,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      VideoModel(
        id: '5',
        title: 'Morning Motivation - Start Strong',
        description: 'Energize your mornings with this powerful motivational message. Set the tone for a productive and successful day.',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        thumbnailUrl: 'https://via.placeholder.com/300x400/F59E0B/FFFFFF?text=Morning+Power',
        category: 'Morning Motivation',
        likes: 1780,
        views: 19650,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
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