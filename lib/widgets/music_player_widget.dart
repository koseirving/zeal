import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/music_model.dart';
import '../providers/music_provider.dart';

class MusicPlayerWidget extends ConsumerWidget {
  final MusicModel music;

  const MusicPlayerWidget({
    super.key,
    required this.music,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(musicPlayerProvider);

    return Container(
      height: 80,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Album Art
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: music.imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(music.imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: music.imageUrl.isEmpty
                  ? const Color(0xFF6366F1)
                  : null,
            ),
            child: music.imageUrl.isEmpty
                ? const Icon(
                    Icons.music_note,
                    color: Colors.white,
                    size: 20,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Music Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  music.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  music.artist,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  playerState.isRepeatEnabled
                      ? Icons.repeat_one
                      : Icons.repeat,
                  color: playerState.isRepeatEnabled
                      ? const Color(0xFF6366F1)
                      : Colors.white54,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(musicPlayerProvider.notifier).toggleRepeat();
                },
              ),
              
              IconButton(
                icon: playerState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : Icon(
                        playerState.isPlaying
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: const Color(0xFF6366F1),
                        size: 32,
                      ),
                onPressed: playerState.isLoading
                    ? null
                    : () {
                        if (playerState.isPlaying) {
                          ref.read(musicPlayerProvider.notifier).pause();
                        } else {
                          ref.read(musicPlayerProvider.notifier).play();
                        }
                      },
              ),
              
              IconButton(
                icon: const Icon(
                  Icons.stop,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: () {
                  ref.read(musicPlayerProvider.notifier).stop();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FullScreenMusicPlayer extends ConsumerStatefulWidget {
  final MusicModel music;

  const FullScreenMusicPlayer({
    super.key,
    required this.music,
  });

  @override
  ConsumerState<FullScreenMusicPlayer> createState() => _FullScreenMusicPlayerState();
}

class _FullScreenMusicPlayerState extends ConsumerState<FullScreenMusicPlayer>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(musicPlayerProvider);

    // Control rotation animation based on playing state
    if (playerState.isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),

              // Rotating Album Art
              Center(
                child: RotationTransition(
                  turns: _rotationController,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                      image: widget.music.imageUrl.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(widget.music.imageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: widget.music.imageUrl.isEmpty
                          ? const Color(0xFF6366F1)
                          : null,
                    ),
                    child: widget.music.imageUrl.isEmpty
                        ? const Icon(
                            Icons.music_note,
                            color: Colors.white,
                            size: 80,
                          )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Music Info
              Text(
                widget.music.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.music.artist,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Progress Bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF6366F1),
                      inactiveTrackColor: Colors.white30,
                      thumbColor: const Color(0xFF6366F1),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: playerState.duration.inMilliseconds > 0
                          ? playerState.position.inMilliseconds /
                              playerState.duration.inMilliseconds
                          : 0.0,
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds: (value * playerState.duration.inMilliseconds).round(),
                        );
                        ref.read(musicPlayerProvider.notifier).seek(position);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(playerState.position),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _formatDuration(playerState.duration),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      playerState.isShuffleEnabled
                          ? Icons.shuffle
                          : Icons.shuffle,
                      color: playerState.isShuffleEnabled
                          ? const Color(0xFF6366F1)
                          : Colors.white54,
                      size: 28,
                    ),
                    onPressed: () {
                      ref.read(musicPlayerProvider.notifier).toggleShuffle();
                    },
                  ),
                  
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white54,
                      size: 36,
                    ),
                    onPressed: () {
                      // TODO: Implement previous track
                    },
                  ),
                  
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF6366F1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: playerState.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              playerState.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                      onPressed: playerState.isLoading
                          ? null
                          : () {
                              if (playerState.isPlaying) {
                                ref.read(musicPlayerProvider.notifier).pause();
                              } else {
                                ref.read(musicPlayerProvider.notifier).play();
                              }
                            },
                    ),
                  ),
                  
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white54,
                      size: 36,
                    ),
                    onPressed: () {
                      // TODO: Implement next track
                    },
                  ),
                  
                  IconButton(
                    icon: Icon(
                      playerState.isRepeatEnabled
                          ? Icons.repeat_one
                          : Icons.repeat,
                      color: playerState.isRepeatEnabled
                          ? const Color(0xFF6366F1)
                          : Colors.white54,
                      size: 28,
                    ),
                    onPressed: () {
                      ref.read(musicPlayerProvider.notifier).toggleRepeat();
                    },
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}