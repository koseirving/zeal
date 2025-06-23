import '../models/music_model.dart';

class MusicService {
  // Mock data for demonstration
  // In a real app, this would fetch from Firebase/API
  Future<List<MusicModel>> getMusic() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockMusic;
  }

  static final List<MusicModel> _mockMusic = [
    MusicModel(
      id: '1',
      title: 'Deep Focus Flow',
      artist: 'Ambient Collective',
      audioUrl: 'https://www.soundjay.com/misc/sounds/magic-chime-02.wav',
      imageUrl: 'https://via.placeholder.com/300x300/6366F1/FFFFFF?text=Deep+Focus',
      category: 'Focus',
      duration: 1800, // 30 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    MusicModel(
      id: '2',
      title: 'Mindful Meditation',
      artist: 'Zen Masters',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      imageUrl: 'https://via.placeholder.com/300x300/8B5CF6/FFFFFF?text=Meditation',
      category: 'Meditation',
      duration: 2400, // 40 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    MusicModel(
      id: '3',
      title: 'Forest Sounds',
      artist: 'Nature Audio',
      audioUrl: 'https://www.soundjay.com/misc/sounds/magic-chime-02.wav',
      imageUrl: 'https://via.placeholder.com/300x300/10B981/FFFFFF?text=Forest',
      category: 'Nature',
      duration: 3600, // 60 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    MusicModel(
      id: '4',
      title: 'Piano Reflections',
      artist: 'Solo Piano',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      imageUrl: 'https://via.placeholder.com/300x300/F59E0B/FFFFFF?text=Piano',
      category: 'Instrumental',
      duration: 2100, // 35 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    MusicModel(
      id: '5',
      title: 'Ocean Waves',
      artist: 'Nature Sounds',
      audioUrl: 'https://www.soundjay.com/misc/sounds/magic-chime-02.wav',
      imageUrl: 'https://via.placeholder.com/300x300/06B6D4/FFFFFF?text=Ocean',
      category: 'Nature',
      duration: 4800, // 80 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    MusicModel(
      id: '6',
      title: 'Concentration Boost',
      artist: 'Focus Lab',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      imageUrl: 'https://via.placeholder.com/300x300/EF4444/FFFFFF?text=Focus',
      category: 'Focus',
      duration: 2700, // 45 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    MusicModel(
      id: '7',
      title: 'Ambient Space',
      artist: 'Cosmic Sounds',
      audioUrl: 'https://www.soundjay.com/misc/sounds/magic-chime-02.wav',
      imageUrl: 'https://via.placeholder.com/300x300/7C3AED/FFFFFF?text=Space',
      category: 'Ambient',
      duration: 3300, // 55 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    MusicModel(
      id: '8',
      title: 'Gentle Rain',
      artist: 'Weather Sounds',
      audioUrl: 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav',
      imageUrl: 'https://via.placeholder.com/300x300/6B7280/FFFFFF?text=Rain',
      category: 'Nature',
      duration: 5400, // 90 minutes
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  Future<MusicModel?> getMusicById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _mockMusic.firstWhere((music) => music.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<MusicModel>> getMusicByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockMusic.where((music) => 
      music.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  Future<List<MusicModel>> searchMusic(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerQuery = query.toLowerCase();
    return _mockMusic.where((music) => 
      music.title.toLowerCase().contains(lowerQuery) ||
      music.artist.toLowerCase().contains(lowerQuery) ||
      music.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}