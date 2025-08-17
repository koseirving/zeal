import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/video_provider.dart';
import '../widgets/video_player_widget.dart';
import '../services/video_player_manager.dart';
import '../models/video_model.dart';

class VideoTimelineScreen extends ConsumerStatefulWidget {
  const VideoTimelineScreen({super.key});

  @override
  ConsumerState<VideoTimelineScreen> createState() => _VideoTimelineScreenState();
}

class _VideoTimelineScreenState extends ConsumerState<VideoTimelineScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasPreloadedInitial = false;
  bool _hasStartedWatching = false; // 視聴開始フラグ
  
  final VideoPlayerManager _playerManager = VideoPlayerManager();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 1動画目の優先事前ロードを実行
    _prioritizeFirstVideo();
  }

  // 1動画目の最優先事前ロード
  Future<void> _prioritizeFirstVideo() async {
    try {
      // videosProviderからデータを取得
      ref.read(videosProvider.future).then((videos) async {
        if (videos.isNotEmpty && mounted) {
          debugPrint('VideoTimelineScreen: Starting priority preload for first video');
          
          // 1動画目を最優先で事前ロード
          final success = await _playerManager.preloadVideo(videos[0]);
          
          if (success && mounted) {
            debugPrint('VideoTimelineScreen: Priority preload completed for first video');
            
            // 1動画目完了後、残りの動画も事前ロード
            if (videos.length > 1) {
              final remainingVideos = videos.skip(1).take(2).cast<VideoModel>().toList();
              _playerManager.preloadVideos(remainingVideos);
            }
            
            setState(() {
              _hasPreloadedInitial = true;
            });
          }
        }
      }).catchError((error) {
        debugPrint('VideoTimelineScreen: Priority preload error: $error');
      });
    } catch (e) {
      debugPrint('VideoTimelineScreen: Error in priority preload: $e');
    }
  }

  void _triggerAdditionalPreload(List<dynamic> videos, int currentIndex) {
    // バックグラウンドで次の動画を事前ロード
    _preloadNextVideos(videos, currentIndex);
  }
  
  // 積極的事前ロード処理
  Future<void> _preloadNextVideos(List<dynamic> videos, int currentIndex) async {
    // 次の2本を事前ロード（非同期でユーザー操作をブロックしない）
    final List<int> indicesToPreload = [];
    
    // 次の動画を優先
    for (int i = currentIndex + 1; i <= currentIndex + 2 && i < videos.length; i++) {
      indicesToPreload.add(i);
    }
    
    // 前の動画も1本追加
    if (currentIndex > 0) {
      indicesToPreload.add(currentIndex - 1);
    }
    
    // バックグラウンドで事前ロード実行
    for (final index in indicesToPreload) {
      if (index >= 0 && index < videos.length) {
        _playerManager.preloadVideo(videos[index]).catchError((error) {
          debugPrint('VideoTimelineScreen: Preload error for video $index: $error');
          return false;
        });
      }
    }
  }
  
  // 初回ロード時の事前ロード
  Future<void> _initialPreload(List<dynamic> videos) async {
    if (_hasPreloadedInitial || videos.isEmpty) return;
    
    // 最初の3本を事前ロード
    final videosToPreload = videos.take(3).cast<VideoModel>().toList();
    await _playerManager.preloadVideos(videosToPreload);
    
    setState(() {
      _hasPreloadedInitial = true;
    });
    
    debugPrint('VideoTimelineScreen: Initial preload completed for ${videosToPreload.length} videos');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videosProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Motivation Videos',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: videosAsync.when(
        data: (videos) {
          if (videos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_library_outlined,
                    size: 64,
                    color: Colors.white54,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No videos available',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Check back later for inspiring content',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // 優先事前ロードが未完了の場合のみフォールバック実行
          if (!_hasPreloadedInitial) {
            _initialPreload(videos);
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: videos.length,
            scrollDirection: Axis.vertical,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                // 初回スワイプ時に視聴開始フラグを立てる
                if (!_hasStartedWatching) {
                  _hasStartedWatching = true;
                }
              });
              
              // バックグラウンド継続事前ロード: ページ変更時に追加の事前ロードをトリガー
              _triggerAdditionalPreload(videos, index);
            },
            itemBuilder: (context, index) {
              final video = videos[index];
              
              // すべての事前ロードはマネージャーが管理するため、
              // shouldPreloadは不要（VideoPlayerWidgetから削除予定）
              return VideoPlayerWidget(
                video: video,
                isActive: index == _currentIndex,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.white54,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading videos',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(videosProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}