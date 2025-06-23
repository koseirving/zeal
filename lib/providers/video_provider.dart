import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_model.dart';
import '../services/video_service.dart';

final videoServiceProvider = Provider((ref) => VideoService());

final videosProvider = FutureProvider<List<VideoModel>>((ref) async {
  final videoService = ref.watch(videoServiceProvider);
  return videoService.getVideos();
});

final videoPlayerProvider = StateNotifierProvider.family<VideoPlayerNotifier, VideoPlayerState, String>(
  (ref, videoId) => VideoPlayerNotifier(videoId),
);

class VideoPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;

  const VideoPlayerState({
    this.isPlaying = false,
    this.isLoading = true,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
  });

  VideoPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
  }) {
    return VideoPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
    );
  }
}

class VideoPlayerNotifier extends StateNotifier<VideoPlayerState> {
  final String videoId;

  VideoPlayerNotifier(this.videoId) : super(const VideoPlayerState());

  void play() {
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void updatePosition(Duration position) {
    state = state.copyWith(position: position);
  }

  void setDuration(Duration duration) {
    state = state.copyWith(duration: duration);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume);
  }
}