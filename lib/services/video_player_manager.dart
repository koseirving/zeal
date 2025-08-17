import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class VideoPlayerManager {
  static final VideoPlayerManager _instance = VideoPlayerManager._internal();
  factory VideoPlayerManager() => _instance;
  VideoPlayerManager._internal();

  // VideoPlayerControllerのキャッシュ
  final Map<String, VideoPlayerController> _controllers = {};
  final Map<String, bool> _initializationStatus = {};
  final List<String> _lruList = []; // LRU管理用
  
  static const int _maxCachedControllers = 6; // 最大キャッシュ数

  /// VideoPlayerControllerを取得（存在しない場合は作成）
  Future<VideoPlayerController?> getController(VideoModel video) async {
    try {
      // 既存のControllerが存在する場合
      if (_controllers.containsKey(video.id)) {
        _updateLRU(video.id);
        debugPrint('VideoPlayerManager: ⚡ Using cached controller for ${video.id}');
        return _controllers[video.id];
      }

      // 新しいControllerを作成
      debugPrint('VideoPlayerManager: 🔄 Creating new controller for ${video.id}');
      return await _createController(video);
    } catch (e) {
      debugPrint('VideoPlayerManager: Error getting controller for ${video.id}: $e');
      return null;
    }
  }

  /// 動画を事前ロード
  Future<bool> preloadVideo(VideoModel video) async {
    try {
      // 既に事前ロード済みの場合はスキップ
      if (_controllers.containsKey(video.id) && 
          _initializationStatus[video.id] == true) {
        _updateLRU(video.id);
        debugPrint('VideoPlayerManager: Already preloaded ${video.id}');
        return true;
      }

      // 事前ロードを実行
      final controller = await _createController(video);
      if (controller != null) {
        debugPrint('VideoPlayerManager: 🚀 Successfully preloaded ${video.id}');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('VideoPlayerManager: Error preloading ${video.id}: $e');
      return false;
    }
  }

  /// 複数動画の事前ロード（バックグラウンド処理）
  Future<void> preloadVideos(List<VideoModel> videos) async {
    for (final video in videos) {
      if (_controllers.length >= _maxCachedControllers) {
        break; // 上限に達した場合は停止
      }
      await preloadVideo(video);
    }
  }

  /// VideoPlayerControllerを作成・初期化
  Future<VideoPlayerController?> _createController(VideoModel video) async {
    try {
      // メモリ管理: 上限に達した場合は古いものを削除
      if (_controllers.length >= _maxCachedControllers) {
        _evictOldestController();
      }

      // URL検証
      if (video.videoUrl.isEmpty) {
        throw Exception('Video URL is empty');
      }

      final Uri videoUri = Uri.parse(video.videoUrl);
      
      // VideoPlayerController作成
      final controller = VideoPlayerController.networkUrl(
        videoUri,
        httpHeaders: {
          'User-Agent': 'ZealApp/1.0',
          'Accept': '*/*',
          'Cache-Control': 'max-age=3600', // 1時間キャッシュ
        },
        formatHint: VideoFormat.other, // 動画形式を自動判定
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // 初期化実行
      _initializationStatus[video.id] = false;
      await controller.initialize();
      
      // キャッシュに保存
      _controllers[video.id] = controller;
      _initializationStatus[video.id] = true;
      _updateLRU(video.id);

      debugPrint('VideoPlayerManager: ✅ Created and initialized controller for ${video.id}');
      return controller;

    } catch (e) {
      debugPrint('VideoPlayerManager: Error creating controller for ${video.id}: $e');
      return null;
    }
  }

  /// LRU管理の更新
  void _updateLRU(String videoId) {
    _lruList.remove(videoId);
    _lruList.add(videoId);
  }

  /// 最も古いControllerを削除
  void _evictOldestController() {
    if (_lruList.isEmpty) return;

    final oldestId = _lruList.removeAt(0);
    final controller = _controllers.remove(oldestId);
    _initializationStatus.remove(oldestId);
    
    controller?.dispose();
    debugPrint('VideoPlayerManager: Evicted controller for $oldestId');
  }

  /// 指定した動画のControllerを削除
  void removeController(String videoId) {
    final controller = _controllers.remove(videoId);
    _initializationStatus.remove(videoId);
    _lruList.remove(videoId);
    
    // 停止してから破棄
    if (controller != null) {
      controller.pause();
      controller.dispose();
    }
    debugPrint('VideoPlayerManager: Removed controller for $videoId');
  }

  /// 指定した動画の再生を停止
  void pauseController(String videoId) {
    final controller = _controllers[videoId];
    if (controller != null && controller.value.isPlaying) {
      controller.pause();
      debugPrint('VideoPlayerManager: ⏸️ Paused controller for $videoId');
    }
  }

  /// 指定した動画の再生を開始
  void playController(String videoId) {
    final controller = _controllers[videoId];
    if (controller != null && !controller.value.isPlaying) {
      controller.play();
      debugPrint('VideoPlayerManager: ▶️ Played controller for $videoId');
    }
  }

  /// 初期化済みかどうかをチェック
  bool isInitialized(String videoId) {
    return _initializationStatus[videoId] == true;
  }

  /// すべてのControllerを停止
  void pauseAll() {
    for (final entry in _controllers.entries) {
      final controller = entry.value;
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
    debugPrint('VideoPlayerManager: ⏸️ Paused all controllers');
  }

  /// すべてのControllerをクリア
  void clearAll() {
    for (final controller in _controllers.values) {
      controller.pause(); // 停止してから破棄
      controller.dispose();
    }
    _controllers.clear();
    _initializationStatus.clear();
    _lruList.clear();
    
    debugPrint('VideoPlayerManager: Cleared all controllers');
  }

  /// キャッシュ情報を取得（デバッグ用）
  Map<String, dynamic> getCacheInfo() {
    return {
      'cachedControllers': _controllers.length,
      'maxControllers': _maxCachedControllers,
      'cachedVideoIds': _controllers.keys.toList(),
      'lruOrder': _lruList,
      'initializationStatus': _initializationStatus,
    };
  }
}