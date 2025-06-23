class MusicModel {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String imageUrl;
  final String category;
  final int duration; // in seconds
  final DateTime createdAt;

  const MusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
    required this.category,
    required this.duration,
    required this.createdAt,
  });

  factory MusicModel.fromMap(Map<String, dynamic> map) {
    return MusicModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'category': category,
      'duration': duration,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}