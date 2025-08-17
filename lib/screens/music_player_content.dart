import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/solfeggio_provider.dart';
import '../models/solfeggio_music_model.dart';

class MusicPlayerContent extends ConsumerStatefulWidget {
  const MusicPlayerContent({super.key});

  @override
  ConsumerState<MusicPlayerContent> createState() => _MusicPlayerContentState();
}

class _MusicPlayerContentState extends ConsumerState<MusicPlayerContent>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _modes = ['Focus', 'Calm', 'Creativity'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _modes.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;

    final selectedMode = _modes[_tabController.index];
    ref.read(solfeggioModeProvider.notifier).state = selectedMode;
    ref.read(solfeggioPlayerProvider.notifier).startMode(selectedMode);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(solfeggioPlayerProvider);
    final currentMode = ref.watch(solfeggioModeProvider);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Mode Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(currentMode),
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: _getGradientColors(
                        currentMode,
                      )[0].withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                labelStyle: GoogleFonts.crimsonText(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                unselectedLabelStyle: GoogleFonts.crimsonText(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                tabs:
                    _modes
                        .map(
                          (mode) => SizedBox(
                            width: double.infinity,
                            child: Tab(text: mode),
                          ),
                        )
                        .toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Information Display Row
            if (playerState.currentFrequency != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pomodoro Info
                    GestureDetector(
                      onTap: () => _showPomodoroInfo(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              playerState.isBreakSession ? 'BREAK' : 'WORK',
                              style: GoogleFonts.crimsonText(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Frequency Info
                    GestureDetector(
                      onTap:
                          () => _showFrequencyInfo(
                            context,
                            playerState.currentFrequency!,
                          ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              playerState.currentFrequency!.toUpperCase(),
                              style: GoogleFonts.crimsonText(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Current Track Display
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (playerState.currentFrequency != null) ...[
                      // Timer Display (Center Focus)
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(
                          begin: 0.95,
                          end: playerState.isPlaying ? 1.0 : 0.95,
                        ),
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Circular Progress
                                SizedBox(
                                  width: 280,
                                  height: 280,
                                  child: CircularProgressIndicator(
                                    value: playerState.progress,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.1,
                                    ),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      playerState.isBreakSession
                                          ? Colors.green.withValues(alpha: 0.8)
                                          : _getGradientColors(
                                            currentMode,
                                          )[0].withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                                // Time Display
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatTimerDuration(
                                        playerState.remainingTime,
                                      ),
                                      style: GoogleFonts.crimsonText(
                                        fontSize: 72,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            playerState.isBreakSession
                                                ? Colors.green.withValues(
                                                  alpha: 0.2,
                                                )
                                                : _getGradientColors(
                                                  currentMode,
                                                )[0].withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color:
                                              playerState.isBreakSession
                                                  ? Colors.green.withValues(
                                                    alpha: 0.3,
                                                  )
                                                  : _getGradientColors(
                                                    currentMode,
                                                  )[0].withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        playerState.isBreakSession
                                            ? 'Break Time'
                                            : 'Work Session',
                                        style: GoogleFonts.crimsonText(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              playerState.isBreakSession
                                                  ? Colors.green
                                                  : _getGradientColors(
                                                    currentMode,
                                                  )[0],
                                        ),
                                      ),
                                    ),
                                    if (playerState.pomodoroCount > 0) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '${playerState.pomodoroCount} sessions completed',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Playback Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Skip button
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(solfeggioPlayerProvider.notifier)
                                    .skipToNext();
                              },
                              icon: const Icon(Icons.skip_next_rounded),
                              iconSize: 32,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Play/Pause button
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _getGradientColors(currentMode),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getGradientColors(
                                    currentMode,
                                  )[0].withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                if (playerState.isPlaying) {
                                  ref
                                      .read(solfeggioPlayerProvider.notifier)
                                      .pause();
                                } else {
                                  ref
                                      .read(solfeggioPlayerProvider.notifier)
                                      .play();
                                }
                              },
                              icon: Icon(
                                playerState.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                              ),
                              iconSize: 56,
                              color: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Stop button
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(solfeggioPlayerProvider.notifier)
                                    .stop();
                              },
                              icon: const Icon(Icons.stop_rounded),
                              iconSize: 32,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // No track playing - Welcome state
                      Column(
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getGradientColors(
                                    currentMode,
                                  )[0].withValues(alpha: 0.2),
                                  _getGradientColors(
                                    currentMode,
                                  )[1].withValues(alpha: 0.1),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.headphones_rounded,
                              size: 80,
                              color: _getGradientColors(
                                currentMode,
                              )[0].withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Ready to Focus?',
                            style: GoogleFonts.crimsonText(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Start a $currentMode session with Solfeggio frequencies',
                            style: GoogleFonts.crimsonText(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _getGradientColors(currentMode),
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: _getGradientColors(
                                    currentMode,
                                  )[0].withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(solfeggioPlayerProvider.notifier)
                                    .startMode(currentMode);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Start Session',
                                style: GoogleFonts.crimsonText(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(String mode) {
    switch (mode) {
      case 'Focus':
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case 'Calm':
        return [const Color(0xFF10B981), const Color(0xFF6EE7B7)];
      case 'Creativity':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  String _formatTimerDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showFrequencyInfo(BuildContext context, String frequency) {
    final musicData = SolfeggioMusic.allTracks[frequency];
    if (musicData == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder:
          (context) => FrequencyInfoModal(
            musicData: musicData,
            frequency: frequency,
            currentMode: ref.watch(solfeggioModeProvider),
          ),
    );
  }

  void _showPomodoroInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder:
          (context) => PomodoroInfoModal(
            currentMode: ref.watch(solfeggioModeProvider),
            isBreakSession: ref.watch(solfeggioPlayerProvider).isBreakSession,
            pomodoroCount: ref.watch(solfeggioPlayerProvider).pomodoroCount,
          ),
    );
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.crimsonText(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white70)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getFrequencyBenefits(String frequency, bool isJapanese) {
    if (isJapanese) {
      switch (frequency) {
        case '174hz':
          return [
            '自然な麻酔効果を提供',
            '身体的・感情的な痛みを軽減',
            '臓器が自然な周波数を見つけるのを助ける',
            '安心感と地に足をつけた感覚を作り出す',
          ];
        case '285hz':
          return [
            '組織と臓器の治癒を加速',
            '免疫システムを強化',
            'エネルギーフィールドを回復',
            '周囲のエネルギーフィールドに影響を与える',
          ];
        case '396hz':
          return ['恐れと罪悪感から解放', 'ネガティブな思考の解放を助ける', '目標達成を促進', 'ルートチャクラを安定させる'];
        case '417hz':
          return [
            '変化と変容を促進',
            'トラウマ体験をクリアにする',
            'ポジティブなエネルギーをもたらす',
            '困難な状況を解消するのを助ける',
          ];
        case '528hz':
          return [
            '「愛の周波数」として知られる',
            'DNAの修復と変容',
            '生命エネルギーと活力を増加',
            '深い平和と喜びをもたらす',
          ];
        case '639hz':
          return ['コミュニケーションと理解を高める', '人間関係を調和させる', '感情のバランスを整える', '寛容と愛を促進'];
        case '741hz':
          return ['直感を覚醒させる', '自己表現を促進', '細胞から毒素を浄化', 'より健康的なライフスタイルへ導く'];
        case '852hz':
          return [
            '精神的秩序への回帰',
            '内なる強さを目覚めさせる',
            '細胞エネルギーを高める',
            'スピリットとの直接的なつながりを可能にする',
          ];
        default:
          return ['全体的な幸福を促進'];
      }
    }

    switch (frequency) {
      case '174hz':
        return [
          'Provides a natural anesthetic effect',
          'Reduces physical and emotional pain',
          'Helps organs find their natural frequency',
          'Creates a sense of security and grounding',
        ];
      case '285hz':
        return [
          'Accelerates healing of tissues and organs',
          'Enhances the immune system',
          'Restores energy fields',
          'Influences the energy field around you',
        ];
      case '396hz':
        return [
          'Liberates from fear and guilt',
          'Helps release negative thoughts',
          'Facilitates achieving goals',
          'Grounds and stabilizes root chakra',
        ];
      case '417hz':
        return [
          'Facilitates change and transformation',
          'Clears traumatic experiences',
          'Brings positive energy',
          'Helps undo challenging situations',
        ];
      case '528hz':
        return [
          'Known as the "Love Frequency"',
          'DNA repair and transformation',
          'Increases life energy and vitality',
          'Brings profound peace and joy',
        ];
      case '639hz':
        return [
          'Enhances communication and understanding',
          'Harmonizes relationships',
          'Balances emotions',
          'Promotes tolerance and love',
        ];
      case '741hz':
        return [
          'Awakens intuition',
          'Promotes self-expression',
          'Cleanses cells from toxins',
          'Leads to a healthier lifestyle',
        ];
      case '852hz':
        return [
          'Returns to spiritual order',
          'Awakens inner strength',
          'Raises cell energy',
          'Enables direct connection with Spirit',
        ];
      default:
        return ['Promotes overall well-being'];
    }
  }
}

class FrequencyInfoModal extends StatefulWidget {
  final SolfeggioMusic musicData;
  final String frequency;
  final String currentMode;

  const FrequencyInfoModal({
    super.key,
    required this.musicData,
    required this.frequency,
    required this.currentMode,
  });

  @override
  State<FrequencyInfoModal> createState() => _FrequencyInfoModalState();
}

class _FrequencyInfoModalState extends State<FrequencyInfoModal> {
  bool _isJapanese = false;

  List<Color> _getGradientColors(String mode) {
    switch (mode) {
      case 'Focus':
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case 'Calm':
        return [const Color(0xFF10B981), const Color(0xFF6EE7B7)];
      case 'Creativity':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  List<String> _getFrequencyBenefits(String frequency, bool isJapanese) {
    if (isJapanese) {
      switch (frequency) {
        case '174hz':
          return [
            '自然な麻酔効果を提供',
            '身体的・感情的な痛みを軽減',
            '臓器が自然な周波数を見つけるのを助ける',
            '安心感と地に足をつけた感覚を作り出す',
          ];
        case '285hz':
          return [
            '組織と臓器の治癒を加速',
            '免疫システムを強化',
            'エネルギーフィールドを回復',
            '周囲のエネルギーフィールドに影響を与える',
          ];
        case '396hz':
          return ['恐れと罪悪感から解放', 'ネガティブな思考の解放を助ける', '目標達成を促進', 'ルートチャクラを安定させる'];
        case '417hz':
          return [
            '変化と変容を促進',
            'トラウマ体験をクリアにする',
            'ポジティブなエネルギーをもたらす',
            '困難な状況を解消するのを助ける',
          ];
        case '528hz':
          return [
            '「愛の周波数」として知られる',
            'DNAの修復と変容',
            '生命エネルギーと活力を増加',
            '深い平和と喜びをもたらす',
          ];
        case '639hz':
          return ['コミュニケーションと理解を高める', '人間関係を調和させる', '感情のバランスを整える', '寛容と愛を促進'];
        case '741hz':
          return ['直感を覚醒させる', '自己表現を促進', '細胞から毒素を浄化', 'より健康的なライフスタイルへ導く'];
        case '852hz':
          return [
            '精神的秩序への回帰',
            '内なる強さを目覚めさせる',
            '細胞エネルギーを高める',
            'スピリットとの直接的なつながりを可能にする',
          ];
        default:
          return ['全体的な幸福を促進'];
      }
    }

    switch (frequency) {
      case '174hz':
        return [
          'Provides a natural anesthetic effect',
          'Reduces physical and emotional pain',
          'Helps organs find their natural frequency',
          'Creates a sense of security and grounding',
        ];
      case '285hz':
        return [
          'Accelerates healing of tissues and organs',
          'Enhances the immune system',
          'Restores energy fields',
          'Influences the energy field around you',
        ];
      case '396hz':
        return [
          'Liberates from fear and guilt',
          'Helps release negative thoughts',
          'Facilitates achieving goals',
          'Grounds and stabilizes root chakra',
        ];
      case '417hz':
        return [
          'Facilitates change and transformation',
          'Clears traumatic experiences',
          'Brings positive energy',
          'Helps undo challenging situations',
        ];
      case '528hz':
        return [
          'Known as the "Love Frequency"',
          'DNA repair and transformation',
          'Increases life energy and vitality',
          'Brings profound peace and joy',
        ];
      case '639hz':
        return [
          'Enhances communication and understanding',
          'Harmonizes relationships',
          'Balances emotions',
          'Promotes tolerance and love',
        ];
      case '741hz':
        return [
          'Awakens intuition',
          'Promotes self-expression',
          'Cleanses cells from toxins',
          'Leads to a healthier lifestyle',
        ];
      case '852hz':
        return [
          'Returns to spiritual order',
          'Awakens inner strength',
          'Raises cell energy',
          'Enables direct connection with Spirit',
        ];
      default:
        return ['Promotes overall well-being'];
    }
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.crimsonText(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white70)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Frequency Title
                Expanded(
                  child: Text(
                    _isJapanese
                        ? widget.musicData.titleJa
                        : widget.musicData.title,
                    style: GoogleFonts.crimsonText(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Language Toggle Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isJapanese = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                !_isJapanese
                                    ? _getGradientColors(widget.currentMode)[0]
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'EN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  !_isJapanese
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isJapanese = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isJapanese
                                    ? _getGradientColors(widget.currentMode)[0]
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'JP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isJapanese
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              _isJapanese
                  ? widget.musicData.descriptionJa
                  : widget.musicData.description,
              style: GoogleFonts.crimsonText(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Frequency Wave Visual
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getGradientColors(
                      widget.currentMode,
                    )[0].withValues(alpha: 0.2),
                    _getGradientColors(
                      widget.currentMode,
                    )[1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.graphic_eq_rounded,
                  size: 48,
                  color: _getGradientColors(widget.currentMode)[0],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Benefits
            _buildInfoSection(
              _isJapanese ? '効果' : 'Benefits',
              _getFrequencyBenefits(widget.frequency, _isJapanese),
            ),
            const SizedBox(height: 32),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getGradientColors(widget.currentMode)[0],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isJapanese ? '閉じる' : 'Close',
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class PomodoroInfoModal extends StatefulWidget {
  final String currentMode;
  final bool isBreakSession;
  final int pomodoroCount;

  const PomodoroInfoModal({
    super.key,
    required this.currentMode,
    required this.isBreakSession,
    required this.pomodoroCount,
  });

  @override
  State<PomodoroInfoModal> createState() => _PomodoroInfoModalState();
}

class _PomodoroInfoModalState extends State<PomodoroInfoModal> {
  bool _isJapanese = false;

  List<Color> _getGradientColors(String mode) {
    switch (mode) {
      case 'Focus':
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case 'Calm':
        return [const Color(0xFF10B981), const Color(0xFF6EE7B7)];
      case 'Creativity':
        return [const Color(0xFFF59E0B), const Color(0xFFFBBF24)];
      default:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    }
  }

  Widget _buildInfoSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.crimsonText(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.white70)),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<String> _getPomodoroDescription(bool isJapanese) {
    if (isJapanese) {
      return [
        'ポモドーロテクニックは25分間の集中作業と5分間の休憩を繰り返すタイムマネジメント手法です',
        '集中力を維持し、燃え尽きを防ぐために開発されました',
        'Zealアプリでは、各セッションに最適なソルフェジオ周波数が自動選択されます',
      ];
    }
    return [
      'The Pomodoro Technique is a time management method using 25-minute focused work sessions followed by 5-minute breaks',
      'Developed to maintain concentration and prevent burnout',
      'Zeal app automatically selects optimal Solfeggio frequencies for each session',
    ];
  }

  List<String> _getPomodoroSteps(bool isJapanese) {
    if (isJapanese) {
      return [
        '25分間の作業セッションを開始する',
        '作業に完全に集中し、他のことは一切しない',
        'セッション中は適切な周波数の音楽が流れます',
        '5分間の休憩を取る',
        '4セッション後は15-30分の長い休憩を取る',
      ];
    }
    return [
      'Start a 25-minute focused work session',
      'Work with complete focus, avoiding all distractions',
      'Appropriate frequency music plays during the session',
      'Take a 5-minute break',
      'After 4 sessions, take a longer 15-30 minute break',
    ];
  }

  List<String> _getPomodoroModeInfo(String mode, bool isJapanese) {
    if (isJapanese) {
      switch (mode) {
        case 'Focus':
          return [
            '作業時: 528Hz (愛の周波数) または 741Hz (直感覚醒)',
            '休憩時: 417Hz (変容促進) または 174Hz (痛み軽減)',
            '集中力と生産性を最大化するための組み合わせ',
          ];
        case 'Calm':
          return [
            '作業時: 396Hz (恐れの解放) または 639Hz (調和促進)',
            '休憩時: 174Hz (痛み軽減) または 285Hz (治癒促進)',
            'リラックスしながら効率的に作業するための組み合わせ',
          ];
        case 'Creativity':
          return [
            '作業時: 852Hz (精神的秩序) または 639Hz (調和促進)',
            '休憩時: 528Hz (愛の周波数) または 417Hz (変容促進)',
            '創造性とインスピレーションを高めるための組み合わせ',
          ];
        default:
          return ['モード情報が利用できません'];
      }
    }

    switch (mode) {
      case 'Focus':
        return [
          'Work: 528Hz (Love Frequency) or 741Hz (Intuition Awakening)',
          'Break: 417Hz (Transformation) or 174Hz (Pain Relief)',
          'Combination designed to maximize concentration and productivity',
        ];
      case 'Calm':
        return [
          'Work: 396Hz (Fear Liberation) or 639Hz (Harmony)',
          'Break: 174Hz (Pain Relief) or 285Hz (Healing)',
          'Combination for relaxed yet efficient work',
        ];
      case 'Creativity':
        return [
          'Work: 852Hz (Spiritual Order) or 639Hz (Harmony)',
          'Break: 528Hz (Love Frequency) or 417Hz (Transformation)',
          'Combination to enhance creativity and inspiration',
        ];
      default:
        return ['Mode information not available'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Language Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Expanded(
                  child: Text(
                    _isJapanese ? 'ポモドーロテクニック' : 'Pomodoro Technique',
                    style: GoogleFonts.crimsonText(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Language Toggle Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isJapanese = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                !_isJapanese
                                    ? _getGradientColors(widget.currentMode)[0]
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'EN',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  !_isJapanese
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isJapanese = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _isJapanese
                                    ? _getGradientColors(widget.currentMode)[0]
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'JP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  _isJapanese
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Current Session Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.isBreakSession
                        ? Colors.green.withValues(alpha: 0.2)
                        : _getGradientColors(
                          widget.currentMode,
                        )[0].withValues(alpha: 0.2),
                    widget.isBreakSession
                        ? Colors.green.withValues(alpha: 0.1)
                        : _getGradientColors(
                          widget.currentMode,
                        )[1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      widget.isBreakSession
                          ? Colors.green.withValues(alpha: 0.3)
                          : _getGradientColors(
                            widget.currentMode,
                          )[0].withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isBreakSession
                        ? Icons.coffee_outlined
                        : Icons.work_outline,
                    color:
                        widget.isBreakSession
                            ? Colors.green
                            : _getGradientColors(widget.currentMode)[0],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isBreakSession
                              ? (_isJapanese ? '休憩時間' : 'Break Time')
                              : (_isJapanese ? '作業セッション' : 'Work Session'),
                          style: GoogleFonts.crimsonText(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.pomodoroCount > 0)
                          Text(
                            _isJapanese
                                ? '完了セッション: ${widget.pomodoroCount}'
                                : 'Completed sessions: ${widget.pomodoroCount}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              _getPomodoroDescription(_isJapanese).join('\n\n'),
              style: GoogleFonts.crimsonText(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Timer Visual
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getGradientColors(
                      widget.currentMode,
                    )[0].withValues(alpha: 0.2),
                    _getGradientColors(
                      widget.currentMode,
                    )[1].withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.timer_outlined,
                  size: 48,
                  color: _getGradientColors(widget.currentMode)[0],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // How it works
            _buildInfoSection(
              _isJapanese ? '使い方' : 'How it works',
              _getPomodoroSteps(_isJapanese),
            ),
            const SizedBox(height: 24),

            // Current Mode Info
            _buildInfoSection(
              _isJapanese
                  ? '${widget.currentMode}モードの周波数'
                  : '${widget.currentMode} Mode Frequencies',
              _getPomodoroModeInfo(widget.currentMode, _isJapanese),
            ),
            const SizedBox(height: 32),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getGradientColors(widget.currentMode)[0],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isJapanese ? '閉じる' : 'Close',
                  style: GoogleFonts.crimsonText(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
