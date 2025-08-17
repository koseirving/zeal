import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';
import '../services/video_player_manager.dart';

class VideoPlayerWidget extends StatefulWidget {
  final VideoModel video;
  final bool isActive;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isBuffering = false;
  
  final VideoPlayerManager _playerManager = VideoPlayerManager();

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 動画が変わった場合は完全に再読み込み
    if (widget.video.id != oldWidget.video.id) {
      _loadVideo();
    }
    // アクティブ状態のみが変わった場合は再生/停止制御のみ
    else if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _activateVideo();
      } else {
        _deactivateVideo();
      }
    }
  }

  Future<void> _loadVideo() async {
    try {
      setState(() {
        _hasError = false;
        _errorMessage = null;
        _isLoading = true;
      });

      // マネージャーから VideoPlayerController を取得
      final controller = await _playerManager.getController(widget.video);
      
      if (controller == null) {
        throw Exception('Failed to get video controller');
      }

      // 既存のChewieControllerを破棄（動画が変わる場合のみ）
      _chewieController?.dispose();
      _chewieController = null;

      // 新しいControllerを設定
      _videoPlayerController = controller;
      _videoPlayerController!.addListener(_videoPlayerListener);

      // ChewieControllerを作成
      if (mounted) {
        _createChewieController();
        setState(() {
          _isLoading = false;
        });
      }

    } catch (e) {
      debugPrint('VideoPlayerWidget: Error loading video ${widget.video.id}: $e');
      
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // アクティブ化：既存のChewieControllerで再生開始
  void _activateVideo() {
    if (_chewieController != null && _videoPlayerController != null) {
      // ChewieControllerで再生開始
      _chewieController!.play();
      
      // VideoPlayerControllerでも再生開始（確実性のため）
      _videoPlayerController!.play();
      
      // ビュー数カウント
      VideoService().incrementViews(widget.video.id);
      
      debugPrint('VideoPlayerWidget: ▶️ Activated video ${widget.video.id}');
    } else {
      // ChewieControllerが未作成の場合は新規作成
      debugPrint('VideoPlayerWidget: No controller found, loading video ${widget.video.id}');
      _loadVideo();
    }
  }

  // 非アクティブ化：確実に停止
  void _deactivateVideo() {
    // ChewieControllerで停止
    if (_chewieController != null) {
      _chewieController!.pause();
    }
    
    // VideoPlayerControllerでも停止（確実性のため）
    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
    }
    
    debugPrint('VideoPlayerWidget: ⏸️ Deactivated video ${widget.video.id}');
  }

  void _videoPlayerListener() {
    if (_videoPlayerController == null || !mounted) return;

    final value = _videoPlayerController!.value;
    
    // バッファリング状態の監視
    final isBuffering = value.isBuffering;
    if (_isBuffering != isBuffering && mounted) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }

    // エラー状態の監視
    if (value.hasError && mounted && !_hasError) {
      final error = value.errorDescription;
      debugPrint('VideoPlayerWidget: Player error detected: $error');
      
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load video';
      });
    }
  }


  void _createChewieController() {
    if (_videoPlayerController == null || !mounted || _chewieController != null) return;

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      aspectRatio: 9 / 16,
      autoPlay: widget.isActive, // アクティブな場合のみ自動再生
      looping: true,
      showControls: true,
      showControlsOnInitialize: false,
      controlsSafeAreaMinimum: const EdgeInsets.all(12),
      allowMuting: true,
      allowPlaybackSpeedChanging: false,
      allowFullScreen: false,
      startAt: Duration.zero,
      autoInitialize: false, // 手動初期化済み
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
            strokeWidth: 2,
          ),
        ),
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF6366F1),
        handleColor: const Color(0xFF6366F1),
        backgroundColor: Colors.white30,
        bufferedColor: Colors.white60,
      ),
    );

    // アクティブな動画のみビュー数をカウント
    if (widget.isActive) {
      VideoService().incrementViews(widget.video.id);
    }
  }

  void _disposeVideo() {
    // 確実に停止してから破棄
    if (_chewieController != null) {
      _chewieController!.pause();
      _chewieController!.dispose();
      _chewieController = null;
    }
    
    if (_videoPlayerController != null) {
      _videoPlayerController!.pause();
      _videoPlayerController!.removeListener(_videoPlayerListener);
      _videoPlayerController = null;
    }
    
    // ウィジェット破棄時はsetState()を呼び出さない
    _isBuffering = false;
    
    debugPrint('VideoPlayerWidget: 🗑️ Disposed video ${widget.video.id}');
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Video Player - ChewieControllerが存在し、エラーがない場合のみ表示
        if (_chewieController != null && !_hasError)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoPlayerController!.value.size.width,
                height: _videoPlayerController!.value.size.height,
                child: Chewie(controller: _chewieController!),
              ),
            ),
          ),

        // ローディング中
        if (_isLoading && !_hasError)
          Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2,
              ),
            ),
          ),

        // 再生中のバッファリングインジケーター
        if (_isBuffering && _chewieController != null && !_hasError)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2,
              ),
            ),
          )
        else if (_hasError)
          Container(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load video',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _loadVideo(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Retry',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )

      ],
    );
  }

}