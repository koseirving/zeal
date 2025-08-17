import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../models/solfeggio_music_model.dart';

final solfeggioModeProvider = StateProvider<String>((ref) => 'Focus');

final solfeggioPlayerProvider =
    StateNotifierProvider<SolfeggioPlayerNotifier, SolfeggioPlayerState>(
      (ref) => SolfeggioPlayerNotifier(ref),
    );

class SolfeggioPlayerState {
  final bool isPlaying;
  final String? currentFrequency;
  final Duration position;
  final Duration totalDuration;
  final bool isBreakSession;
  final int pomodoroCount;
  final String mode;
  final DateTime? sessionStartTime;
  final Duration sessionElapsed;

  static const Duration workDuration = Duration(minutes: 25);
  static const Duration breakDuration = Duration(minutes: 5);

  const SolfeggioPlayerState({
    this.isPlaying = false,
    this.currentFrequency,
    this.position = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isBreakSession = false,
    this.pomodoroCount = 0,
    this.mode = 'Focus',
    this.sessionStartTime,
    this.sessionElapsed = Duration.zero,
  });

  Duration get sessionDuration => isBreakSession ? breakDuration : workDuration;
  
  Duration get remainingTime {
    final remaining = sessionDuration - sessionElapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get progress {
    if (sessionDuration.inSeconds == 0) return 0;
    return sessionElapsed.inSeconds / sessionDuration.inSeconds;
  }

  SolfeggioPlayerState copyWith({
    bool? isPlaying,
    String? currentFrequency,
    Duration? position,
    Duration? totalDuration,
    bool? isBreakSession,
    int? pomodoroCount,
    String? mode,
    DateTime? sessionStartTime,
    Duration? sessionElapsed,
  }) {
    return SolfeggioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentFrequency: currentFrequency ?? this.currentFrequency,
      position: position ?? this.position,
      totalDuration: totalDuration ?? this.totalDuration,
      isBreakSession: isBreakSession ?? this.isBreakSession,
      pomodoroCount: pomodoroCount ?? this.pomodoroCount,
      mode: mode ?? this.mode,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      sessionElapsed: sessionElapsed ?? this.sessionElapsed,
    );
  }
}

class SolfeggioPlayerNotifier extends StateNotifier<SolfeggioPlayerState> {
  final Ref ref;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();
  ConcatenatingAudioSource? _currentPlaylist;
  Timer? _sessionTimer;

  SolfeggioPlayerNotifier(this.ref) : super(const SolfeggioPlayerState()) {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        // For work sessions, just restart the audio without switching sessions
        // The session timer will handle the actual session switching
        if (!state.isBreakSession) {
          _restartCurrentAudio();
        } else {
          _switchSession();
        }
      }
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((duration) {
      // We don't update totalDuration from audio player
      // as we use fixed session durations
    });

    // Listen to playing state
    _audioPlayer.playingStream.listen((playing) {
      state = state.copyWith(isPlaying: playing);
    });
  }

  Future<void> startMode(String mode) async {
    ref.read(solfeggioModeProvider.notifier).state = mode;
    
    _stopSessionTimer();
    
    final now = DateTime.now();
    state = state.copyWith(
      mode: mode,
      isBreakSession: false,
      pomodoroCount: 0,
      position: Duration.zero,
      totalDuration: SolfeggioPlayerState.workDuration,
      sessionStartTime: now,
      sessionElapsed: Duration.zero,
    );

    _startSessionTimer();
    await _loadSession(mode, false);
  }

  Future<void> _loadSession(String mode, bool isBreak) async {
    final tracks = SolfeggioMusic.getTracksForMode(mode);
    if (tracks.isEmpty) return;

    final List<AudioSource> audioSources = [];
    SolfeggioMusic selectedTrack;

    switch (mode) {
      case 'Focus':
        if (!isBreak) {
          // Work session: 528hz or 741hz (5x for 25 minutes)
          final workFreqs = [tracks[0], tracks[1]]; // 528hz, 741hz
          selectedTrack = workFreqs[_random.nextInt(workFreqs.length)];
          // Add the same track 5 times for seamless 25-minute session
          for (int i = 0; i < 5; i++) {
            audioSources.add(AudioSource.asset(selectedTrack.assetPath));
          }
        } else {
          // Break session: 417hz or 174hz (1x for 5 minutes)
          final breakFreqs = [tracks[2], tracks[3]]; // 417hz, 174hz
          selectedTrack = breakFreqs[_random.nextInt(breakFreqs.length)];
          audioSources.add(AudioSource.asset(selectedTrack.assetPath));
        }
        break;

      case 'Calm':
        if (!isBreak) {
          // Work session: 396hz or 639hz (5x for 25 minutes)
          final workFreqs = [tracks[0], tracks[1]]; // 396hz, 639hz
          selectedTrack = workFreqs[_random.nextInt(workFreqs.length)];
          for (int i = 0; i < 5; i++) {
            audioSources.add(AudioSource.asset(selectedTrack.assetPath));
          }
        } else {
          // Break session: 174hz or 285hz (1x for 5 minutes)
          final breakFreqs = [tracks[2], tracks[3]]; // 174hz, 285hz
          selectedTrack = breakFreqs[_random.nextInt(breakFreqs.length)];
          audioSources.add(AudioSource.asset(selectedTrack.assetPath));
        }
        break;

      case 'Creativity':
        if (!isBreak) {
          // Work session: 852hz or 639hz (5x for 25 minutes)
          final workFreqs = [tracks[0], tracks[1]]; // 852hz, 639hz
          selectedTrack = workFreqs[_random.nextInt(workFreqs.length)];
          for (int i = 0; i < 5; i++) {
            audioSources.add(AudioSource.asset(selectedTrack.assetPath));
          }
        } else {
          // Break session: 528hz or 417hz (1x for 5 minutes)
          final breakFreqs = [tracks[2], tracks[3]]; // 528hz, 417hz
          selectedTrack = breakFreqs[_random.nextInt(breakFreqs.length)];
          audioSources.add(AudioSource.asset(selectedTrack.assetPath));
        }
        break;

      default:
        return;
    }

    // Create concatenating audio source for gapless playback
    _currentPlaylist = ConcatenatingAudioSource(children: audioSources);
    
    try {
      await _audioPlayer.setAudioSource(_currentPlaylist!);
      state = state.copyWith(
        currentFrequency: selectedTrack.frequency,
        isBreakSession: isBreak,
        totalDuration: isBreak ? SolfeggioPlayerState.breakDuration : SolfeggioPlayerState.workDuration,
      );
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Future<void> _switchSession() async {
    // Switch between work and break sessions
    final isBreakSession = !state.isBreakSession;
    final mode = state.mode;
    
    _stopSessionTimer();
    
    final now = DateTime.now();
    state = state.copyWith(
      isBreakSession: isBreakSession,
      pomodoroCount: isBreakSession ? state.pomodoroCount : state.pomodoroCount + 1,
      position: Duration.zero,
      totalDuration: isBreakSession ? SolfeggioPlayerState.breakDuration : SolfeggioPlayerState.workDuration,
      sessionStartTime: now,
      sessionElapsed: Duration.zero,
    );
    
    _startSessionTimer();
    await _loadSession(mode, isBreakSession);
  }


  Future<void> play() async {
    if (_currentPlaylist == null) {
      final mode = ref.read(solfeggioModeProvider);
      await startMode(mode);
    } else {
      if (state.sessionStartTime == null) {
        final now = DateTime.now();
        state = state.copyWith(sessionStartTime: now);
        _startSessionTimer();
      }
      await _audioPlayer.play();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _stopSessionTimer();
    _currentPlaylist = null;
    state = const SolfeggioPlayerState();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> skipToNext() async {
    await _audioPlayer.stop();
    await _switchSession();
  }

  Future<void> _restartCurrentAudio() async {
    try {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error restarting audio: $e');
    }
  }

  void _startSessionTimer() {
    _stopSessionTimer();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.sessionStartTime != null && state.isPlaying) {
        final now = DateTime.now();
        final elapsed = now.difference(state.sessionStartTime!);
        state = state.copyWith(sessionElapsed: elapsed);
        
        // Check if session is complete
        if (elapsed >= state.sessionDuration) {
          _switchSession();
        }
      }
    });
  }
  
  void _stopSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  @override
  void dispose() {
    _stopSessionTimer();
    _audioPlayer.dispose();
    super.dispose();
  }
}
