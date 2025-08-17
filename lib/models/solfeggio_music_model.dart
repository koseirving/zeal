class SolfeggioMusic {
  final String frequency;
  final String assetPath;
  final String title;
  final String description;
  final String titleJa;
  final String descriptionJa;

  const SolfeggioMusic({
    required this.frequency,
    required this.assetPath,
    required this.title,
    required this.description,
    required this.titleJa,
    required this.descriptionJa,
  });

  static const Map<String, SolfeggioMusic> allTracks = {
    '174hz': SolfeggioMusic(
      frequency: '174hz',
      assetPath: 'assets/solfeggio/174hz/174hz_01.mp3',
      title: '174 Hz - Foundation',
      description: 'Pain relief and stability',
      titleJa: '174 Hz - 基礎',
      descriptionJa: '痛みの緩和と安定',
    ),
    '285hz': SolfeggioMusic(
      frequency: '285hz',
      assetPath: 'assets/solfeggio/285hz/285hz_01.mp3',
      title: '285 Hz - Healing',
      description: 'Tissue and organ healing',
      titleJa: '285 Hz - 癒し',
      descriptionJa: '組織と臓器の治癒',
    ),
    '396hz': SolfeggioMusic(
      frequency: '396hz',
      assetPath: 'assets/solfeggio/396hz/396hz_01.mp3',
      title: '396 Hz - Liberation',
      description: 'Release from fear and guilt',
      titleJa: '396 Hz - 解放',
      descriptionJa: '恐れと罪悪感からの解放',
    ),
    '417hz': SolfeggioMusic(
      frequency: '417hz',
      assetPath: 'assets/solfeggio/417hz/417hz_01.mp3',
      title: '417 Hz - Change',
      description: 'Facilitate positive change',
      titleJa: '417 Hz - 変化',
      descriptionJa: 'ポジティブな変化の促進',
    ),
    '528hz': SolfeggioMusic(
      frequency: '528hz',
      assetPath: 'assets/solfeggio/528hz/528hz_01.mp3',
      title: '528 Hz - Love',
      description: 'DNA repair and miracles',
      titleJa: '528 Hz - 愛',
      descriptionJa: 'DNAの修復と奇跡',
    ),
    '639hz': SolfeggioMusic(
      frequency: '639hz',
      assetPath: 'assets/solfeggio/639hz/639hz_01.mp3',
      title: '639 Hz - Connection',
      description: 'Harmonious relationships',
      titleJa: '639 Hz - つながり',
      descriptionJa: '調和のとれた関係',
    ),
    '741hz': SolfeggioMusic(
      frequency: '741hz',
      assetPath: 'assets/solfeggio/741hz/741hz_01.mp3',
      title: '741 Hz - Awakening',
      description: 'Intuition and consciousness',
      titleJa: '741 Hz - 覚醒',
      descriptionJa: '直感と意識',
    ),
    '852hz': SolfeggioMusic(
      frequency: '852hz',
      assetPath: 'assets/solfeggio/852hz/852hz_01.mp3',
      title: '852 Hz - Clarity',
      description: 'Return to spiritual order',
      titleJa: '852 Hz - 明晰さ',
      descriptionJa: '精神的秩序への回帰',
    ),
  };

  static List<SolfeggioMusic> getTracksForMode(String mode) {
    switch (mode) {
      case 'Focus':
        return [
          allTracks['528hz']!,
          allTracks['741hz']!,
          allTracks['417hz']!,
          allTracks['174hz']!,
        ];
      case 'Calm':
        return [
          allTracks['396hz']!,
          allTracks['639hz']!,
          allTracks['174hz']!,
          allTracks['285hz']!,
        ];
      case 'Creativity':
        return [
          allTracks['852hz']!,
          allTracks['639hz']!,
          allTracks['528hz']!,
          allTracks['417hz']!,
        ];
      default:
        return allTracks.values.toList();
    }
  }
}
