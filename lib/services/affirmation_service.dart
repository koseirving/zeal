import 'dart:math';
import '../models/affirmation_model.dart';

class AffirmationService {
  // Mock data for demonstration
  // In a real app, this would fetch from Firebase/API
  Future<List<AffirmationModel>> getAffirmations() async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    return _mockAffirmations;
  }

  static final List<AffirmationModel> _mockAffirmations = [
    AffirmationModel(
      id: '1',
      text: 'I am capable of achieving my dreams and goals.',
      category: 'Success',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AffirmationModel(
      id: '2',
      text: 'I choose to focus on what I can control and let go of what I cannot.',
      category: 'Mindfulness',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AffirmationModel(
      id: '3',
      text: 'Every challenge I face is an opportunity to grow stronger.',
      category: 'Growth',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AffirmationModel(
      id: '4',
      text: 'I am worthy of love, respect, and all the good things life has to offer.',
      category: 'Self-Love',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    AffirmationModel(
      id: '5',
      text: 'I trust in my ability to make the right decisions for my life.',
      category: 'Confidence',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    AffirmationModel(
      id: '6',
      text: 'Today I choose to see the beauty and possibilities around me.',
      category: 'Positivity',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    AffirmationModel(
      id: '7',
      text: 'I am grateful for all the lessons life has taught me.',
      category: 'Gratitude',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    AffirmationModel(
      id: '8',
      text: 'I have the power to create the life I desire.',
      category: 'Empowerment',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    AffirmationModel(
      id: '9',
      text: 'I embrace change as a natural part of my growth journey.',
      category: 'Growth',
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    AffirmationModel(
      id: '10',
      text: 'I am resilient and can overcome any obstacle in my path.',
      category: 'Strength',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    AffirmationModel(
      id: '11',
      text: 'I radiate positive energy and attract positive experiences.',
      category: 'Positivity',
      createdAt: DateTime.now().subtract(const Duration(days: 11)),
    ),
    AffirmationModel(
      id: '12',
      text: 'I am proud of how far I have come and excited for where I am going.',
      category: 'Self-Love',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    AffirmationModel(
      id: '13',
      text: 'I deserve success and I am willing to work for it.',
      category: 'Success',
      createdAt: DateTime.now().subtract(const Duration(days: 13)),
    ),
    AffirmationModel(
      id: '14',
      text: 'I am at peace with my past and excited about my future.',
      category: 'Peace',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    AffirmationModel(
      id: '15',
      text: 'I trust the process of life and know that everything happens for a reason.',
      category: 'Faith',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  Future<AffirmationModel?> getDailyAffirmation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (_mockAffirmations.isEmpty) return null;
    
    // Return a random affirmation as the daily one
    final random = Random();
    return _mockAffirmations[random.nextInt(_mockAffirmations.length)];
  }

  Future<List<AffirmationModel>> getAffirmationsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return _mockAffirmations.where((affirmation) => 
      affirmation.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  Future<AffirmationModel?> getAffirmationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      return _mockAffirmations.firstWhere((affirmation) => affirmation.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final categories = _mockAffirmations
        .map((affirmation) => affirmation.category)
        .toSet()
        .toList();
    
    categories.sort();
    return categories;
  }

  Future<List<AffirmationModel>> searchAffirmations(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final lowerQuery = query.toLowerCase();
    return _mockAffirmations.where((affirmation) => 
      affirmation.text.toLowerCase().contains(lowerQuery) ||
      affirmation.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  Future<List<AffirmationModel>> getRandomAffirmations(int count) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final random = Random();
    final shuffled = List<AffirmationModel>.from(_mockAffirmations)..shuffle(random);
    
    return shuffled.take(count).toList();
  }
}