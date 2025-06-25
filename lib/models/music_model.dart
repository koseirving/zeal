import 'package:cloud_firestore/cloud_firestore.dart';

class MusicModel {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String imageUrl;
  final String category;
  final int duration; // in seconds
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? createdBy;
  final List<String> tags;
  final int playCount;

  const MusicModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
    required this.category,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.createdBy,
    this.tags = const [],
    this.playCount = 0,
  });

  // Create from Firestore document
  factory MusicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MusicModel(
      id: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'],
      tags: List<String>.from(data['tags'] ?? []),
      playCount: data['playCount'] ?? 0,
    );
  }

  // Create from Map (for local storage)
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
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'],
      tags: List<String>.from(map['tags'] ?? []),
      playCount: map['playCount'] ?? 0,
    );
  }

  // Convert to Firestore document (without ID)
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'artist': artist,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'category': category,
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
      'createdBy': createdBy,
      'tags': tags,
      'playCount': playCount,
    };
  }

  // Convert to Map (for local storage)
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
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'createdBy': createdBy,
      'tags': tags,
      'playCount': playCount,
    };
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Create a copy with updated fields
  MusicModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    String? imageUrl,
    String? category,
    int? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    List<String>? tags,
    int? playCount,
  }) {
    return MusicModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      playCount: playCount ?? this.playCount,
    );
  }

  @override
  String toString() {
    return 'MusicModel(id: $id, title: $title, artist: $artist)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is MusicModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}