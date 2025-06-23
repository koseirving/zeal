class AffirmationModel {
  final String id;
  final String text;
  final String category;
  final DateTime createdAt;

  const AffirmationModel({
    required this.id,
    required this.text,
    required this.category,
    required this.createdAt,
  });

  factory AffirmationModel.fromMap(Map<String, dynamic> map) {
    return AffirmationModel(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      category: map['category'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }
}