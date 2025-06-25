import 'package:cloud_firestore/cloud_firestore.dart';

class AffirmationModel {
  final String id;
  final String text;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? createdBy;
  final List<String> tags;
  final int viewCount;

  const AffirmationModel({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.createdBy,
    this.tags = const [],
    this.viewCount = 0,
  });

  // Create from Firestore document
  factory AffirmationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AffirmationModel(
      id: doc.id,
      text: data['text'] ?? '',
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      createdBy: data['createdBy'],
      tags: List<String>.from(data['tags'] ?? []),
      viewCount: data['viewCount'] ?? 0,
    );
  }

  // Create from Map (for local storage)
  factory AffirmationModel.fromMap(Map<String, dynamic> map) {
    return AffirmationModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      category: map['category'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
      isActive: map['isActive'] ?? true,
      createdBy: map['createdBy'],
      tags: List<String>.from(map['tags'] ?? []),
      viewCount: map['viewCount'] ?? 0,
    );
  }

  // Convert to Firestore document (without ID)
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': isActive,
      'createdBy': createdBy,
      'tags': tags,
      'viewCount': viewCount,
    };
  }

  // Convert to Map (for local storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isActive': isActive,
      'createdBy': createdBy,
      'tags': tags,
      'viewCount': viewCount,
    };
  }

  // Create a copy with updated fields
  AffirmationModel copyWith({
    String? id,
    String? text,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? createdBy,
    List<String>? tags,
    int? viewCount,
  }) {
    return AffirmationModel(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  @override
  String toString() {
    return 'AffirmationModel(id: $id, text: ${text.substring(0, text.length > 50 ? 50 : text.length)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is AffirmationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}