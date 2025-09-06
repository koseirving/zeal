import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/video_provider.dart';
import '../widgets/video_player_widget.dart';
import '../services/video_service.dart';
import '../services/video_player_manager.dart';
import '../models/video_model.dart';
import 'goal_tracker_content.dart';
import 'music_player_content.dart';

class ContentScreen extends ConsumerStatefulWidget {
  final int? initialTab;
  
  const ContentScreen({super.key, this.initialTab});

  @override
  ConsumerState<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends ConsumerState<ContentScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const _VideoContent(),
    const _MusicContent(),
    const GoalTrackerContent(),
  ];

  @override
  void initState() {
    super.initState();
    // Adjust initial tab index to account for home tab at index 0
    _currentIndex = widget.initialTab != null ? widget.initialTab! + 1 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A1A),
              Color(0xFF0F0F0F),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: _currentIndex == 0 ? Container() : _screens[_currentIndex - 1],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF0A0A0A),
            ],
          ),
          border: Border(
            top: BorderSide(
              color: const Color(0xFFFF6B35).withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) {
              // Navigate to home screen
              context.go('/');
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: _currentIndex == 0 
            ? const Color(0xFF6366F1) 
            : _currentIndex == 1
              ? const Color(0xFFFF6B35) 
              : _currentIndex == 2
                ? const Color(0xFFFFD93D)
                : const Color(0xFF4ECDC4),
          unselectedItemColor: Colors.white54,
          selectedLabelStyle: GoogleFonts.crimsonText(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.crimsonText(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 0
                      ? LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.3),
                            const Color(0xFF6366F1).withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: _currentIndex == 0
                      ? Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  Icons.home,
                  size: 24,
                  shadows: _currentIndex == 0
                      ? [
                          Shadow(
                            color: const Color(0xFF6366F1).withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 1
                      ? LinearGradient(
                          colors: [
                            const Color(0xFFFF6B35).withOpacity(0.3),
                            const Color(0xFFFF6B35).withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: _currentIndex == 1
                      ? Border.all(
                          color: const Color(0xFFFF6B35).withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  Icons.play_circle_fill,
                  size: 24,
                  shadows: _currentIndex == 1
                      ? [
                          Shadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              label: 'Videos',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 2
                      ? LinearGradient(
                          colors: [
                            const Color(0xFFFFD93D).withOpacity(0.3),
                            const Color(0xFFFFD93D).withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: _currentIndex == 2
                      ? Border.all(
                          color: const Color(0xFFFFD93D).withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  Icons.music_note,
                  size: 24,
                  shadows: _currentIndex == 2
                      ? [
                          Shadow(
                            color: const Color(0xFFFFD93D).withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              label: 'Music',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: _currentIndex == 3
                      ? LinearGradient(
                          colors: [
                            const Color(0xFF4ECDC4).withOpacity(0.3),
                            const Color(0xFF4ECDC4).withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  border: _currentIndex == 3
                      ? Border.all(
                          color: const Color(0xFF4ECDC4).withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  Icons.calendar_today,
                  size: 24,
                  shadows: _currentIndex == 3
                      ? [
                          Shadow(
                            color: const Color(0xFF4ECDC4).withOpacity(0.6),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
              ),
              label: 'Tracker',
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoContent extends ConsumerStatefulWidget {
  const _VideoContent();

  @override
  ConsumerState<_VideoContent> createState() => _VideoContentState();
}

class _VideoContentState extends ConsumerState<_VideoContent> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _hasStartedWatching = false; // 視聴開始フラグ
  bool _hasPreloadedInitial = false;
  
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
          debugPrint('ContentScreen: Starting priority preload for first video');
          
          // 1動画目を最優先で事前ロード
          final success = await _playerManager.preloadVideo(videos[0]);
          
          if (success && mounted) {
            debugPrint('ContentScreen: Priority preload completed for first video');
            
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
        debugPrint('ContentScreen: Priority preload error: $error');
      });
    } catch (e) {
      debugPrint('ContentScreen: Error in priority preload: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _refreshVideos() async {
    await VideoService().refreshVideos();
    ref.invalidate(videosProvider);
  }

  // 事前ロード処理
  Future<void> _preloadNextVideos(List<dynamic> videos, int currentIndex) async {
    // 次の2本を事前ロード
    final List<int> indicesToPreload = [];
    
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
          debugPrint('ContentScreen: Preload error for video $index: $error');
          return false;
        });
      }
    }
  }

  // 初回事前ロード
  Future<void> _initialPreload(List<dynamic> videos) async {
    if (_hasPreloadedInitial || videos.isEmpty) return;
    
    final videosToPreload = videos.take(3).cast<VideoModel>().toList();
    await _playerManager.preloadVideos(videosToPreload);
    
    setState(() {
      _hasPreloadedInitial = true;
    });
    
    debugPrint('ContentScreen: Initial preload completed for ${videosToPreload.length} videos');
  }


  @override
  Widget build(BuildContext context) {
    final videosAsync = ref.watch(videosProvider);

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _refreshVideos,
          color: const Color(0xFFFF6B35),
          backgroundColor: const Color(0xFF1A1A1A),
          child: videosAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              ),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading videos: $error',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshVideos,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            data: (videos) {
              if (videos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.video_library_outlined,
                        color: Colors.white38,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'ビデオを読み込み中...',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '認証の確認とデータの取得を行っています',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshVideos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text(
                          'リトライ',
                          style: TextStyle(color: Colors.white),
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
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    // 初回スワイプ時に視聴開始フラグを立てる
                    if (!_hasStartedWatching) {
                      _hasStartedWatching = true;
                    }
                  });
                  
                  // 次の動画を事前ロード
                  _preloadNextVideos(videos, index);
                },
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  
                  // すべての事前ロードはマネージャーが管理
                  return VideoPlayerWidget(
                    video: video,
                    isActive: index == _currentIndex,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MusicContent extends StatelessWidget {
  const _MusicContent();

  @override
  Widget build(BuildContext context) {
    return const MusicPlayerContent();
  }
}