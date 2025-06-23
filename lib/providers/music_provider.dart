import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/music_model.dart';
import '../services/music_service.dart';

final musicServiceProvider = Provider((ref) => MusicService());

final musicProvider = FutureProvider<List<MusicModel>>((ref) async {
  final musicService = ref.watch(musicServiceProvider);
  return musicService.getMusic();
});

final currentMusicProvider = StateProvider<MusicModel?>((ref) => null);

final musicPlayerProvider = StateNotifierProvider<MusicPlayerNotifier, MusicPlayerState>(
  (ref) => MusicPlayerNotifier(ref),
);

class MusicPlayerState {
  final bool isPlaying;
  final bool isLoading;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isShuffleEnabled;
  final bool isRepeatEnabled;

  const MusicPlayerState({
    this.isPlaying = false,
    this.isLoading = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isShuffleEnabled = false,
    this.isRepeatEnabled = false,
  });

  MusicPlayerState copyWith({
    bool? isPlaying,
    bool? isLoading,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isShuffleEnabled,
    bool? isRepeatEnabled,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isRepeatEnabled: isRepeatEnabled ?? this.isRepeatEnabled,
    );
  }
}

class MusicPlayerNotifier extends StateNotifier<MusicPlayerState> {
  final Ref ref;
  final AudioPlayer _audioPlayer = AudioPlayer();

  MusicPlayerNotifier(this.ref) : super(const MusicPlayerState()) {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      state = state.copyWith(
        isPlaying: playerState.playing,
        isLoading: playerState.processingState == ProcessingState.loading ||
                  playerState.processingState == ProcessingState.buffering,
      );
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        state = state.copyWith(duration: duration);
      }
    });
  }

  Future<void> playMusic(MusicModel music) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Set current music
      ref.read(currentMusicProvider.notifier).state = music;
      
      // Load and play the audio
      await _audioPlayer.setUrl(music.audioUrl);
      await _audioPlayer.play();
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
      debugPrint('Error playing music: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    ref.read(currentMusicProvider.notifier).state = null;
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  void setVolume(double volume) {
    _audioPlayer.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  void toggleShuffle() {
    final newShuffleState = !state.isShuffleEnabled;
    _audioPlayer.setShuffleModeEnabled(newShuffleState);
    state = state.copyWith(isShuffleEnabled: newShuffleState);
  }

  void toggleRepeat() {
    final newRepeatState = !state.isRepeatEnabled;
    _audioPlayer.setLoopMode(newRepeatState ? LoopMode.one : LoopMode.off);
    state = state.copyWith(isRepeatEnabled: newRepeatState);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}