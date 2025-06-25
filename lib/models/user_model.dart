import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoURL;
  final bool isGuest;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;
  
  // User preferences
  final bool notificationsEnabled;
  final String? preferredLanguage;
  final Map<String, dynamic>? preferences;
  
  // User stats
  final int totalVideosWatched;
  final int totalMusicPlayed;
  final int totalAffirmationsViewed;
  final int totalTipAmount;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoURL,
    this.isGuest = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.notificationsEnabled = true,
    this.preferredLanguage = 'en',
    this.preferences,
    this.totalVideosWatched = 0,
    this.totalMusicPlayed = 0,
    this.totalAffirmationsViewed = 0,
    this.totalTipAmount = 0,
  });

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? 'User',
      photoURL: data['photoURL'],
      isGuest: data['isGuest'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      preferences: data['preferences'] as Map<String, dynamic>?,
      totalVideosWatched: data['totalVideosWatched'] ?? 0,
      totalMusicPlayed: data['totalMusicPlayed'] ?? 0,
      totalAffirmationsViewed: data['totalAffirmationsViewed'] ?? 0,
      totalTipAmount: data['totalTipAmount'] ?? 0,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isGuest': isGuest,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'notificationsEnabled': notificationsEnabled,
      'preferredLanguage': preferredLanguage,
      'preferences': preferences,
      'totalVideosWatched': totalVideosWatched,
      'totalMusicPlayed': totalMusicPlayed,
      'totalAffirmationsViewed': totalAffirmationsViewed,
      'totalTipAmount': totalTipAmount,
    };
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    bool? isGuest,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    bool? notificationsEnabled,
    String? preferredLanguage,
    Map<String, dynamic>? preferences,
    int? totalVideosWatched,
    int? totalMusicPlayed,
    int? totalAffirmationsViewed,
    int? totalTipAmount,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferences: preferences ?? this.preferences,
      totalVideosWatched: totalVideosWatched ?? this.totalVideosWatched,
      totalMusicPlayed: totalMusicPlayed ?? this.totalMusicPlayed,
      totalAffirmationsViewed: totalAffirmationsViewed ?? this.totalAffirmationsViewed,
      totalTipAmount: totalTipAmount ?? this.totalTipAmount,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'isGuest': isGuest,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'notificationsEnabled': notificationsEnabled,
      'preferredLanguage': preferredLanguage,
      'preferences': preferences,
      'totalVideosWatched': totalVideosWatched,
      'totalMusicPlayed': totalMusicPlayed,
      'totalAffirmationsViewed': totalAffirmationsViewed,
      'totalTipAmount': totalTipAmount,
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      isGuest: json['isGuest'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      preferredLanguage: json['preferredLanguage'] ?? 'en',
      preferences: json['preferences'],
      totalVideosWatched: json['totalVideosWatched'] ?? 0,
      totalMusicPlayed: json['totalMusicPlayed'] ?? 0,
      totalAffirmationsViewed: json['totalAffirmationsViewed'] ?? 0,
      totalTipAmount: json['totalTipAmount'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName, isGuest: $isGuest)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.photoURL == photoURL &&
        other.isGuest == isGuest;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        photoURL.hashCode ^
        isGuest.hashCode;
  }
}