import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/video_provider.dart';
import '../providers/music_provider.dart';
import '../widgets/video_player_widget.dart';
import '../services/video_service.dart';
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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

  void _showDebugInfo() {
    final cacheInfo = VideoService().getCacheInfo();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Video Debug Info',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Has Cached Videos: ${cacheInfo['hasCachedVideos']}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Cached Video Count: ${cacheInfo['cachedVideoCount']}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Last Cache Update: ${cacheInfo['lastCacheUpdate'] ?? 'Never'}',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Cache Age (minutes): ${cacheInfo['cacheAge'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
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
                      const Text(
                        'No videos available',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshVideos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                        ),
                        child: const Text(
                          'Refresh',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return VideoPlayerWidget(
                    video: video,
                    isActive: index == _currentIndex,
                  );
                },
              );
            },
          ),
        ),
        // Debug button in top-right corner
        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFF6366F1).withOpacity(0.8),
            onPressed: _showDebugInfo,
            child: const Icon(
              Icons.bug_report,
              color: Colors.white,
              size: 16,
            ),
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