import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/affirmation_model.dart';
import '../services/affirmation_service.dart';

final affirmationServiceProvider = Provider((ref) => AffirmationService());

final affirmationsProvider = FutureProvider<List<AffirmationModel>>((ref) async {
  final affirmationService = ref.watch(affirmationServiceProvider);
  return affirmationService.getAffirmations();
});

final notificationsEnabledProvider = StateProvider<bool>((ref) => false);

final favoriteAffirmationsProvider = StateNotifierProvider<FavoriteAffirmationsNotifier, List<String>>(
  (ref) => FavoriteAffirmationsNotifier(),
);

class FavoriteAffirmationsNotifier extends StateNotifier<List<String>> {
  FavoriteAffirmationsNotifier() : super([]);

  void addFavorite(String affirmationId) {
    if (!state.contains(affirmationId)) {
      state = [...state, affirmationId];
    }
  }

  void removeFavorite(String affirmationId) {
    state = state.where((id) => id != affirmationId).toList();
  }

  bool isFavorite(String affirmationId) {
    return state.contains(affirmationId);
  }
}

final dailyAffirmationProvider = FutureProvider<AffirmationModel?>((ref) async {
  final affirmationService = ref.watch(affirmationServiceProvider);
  return affirmationService.getDailyAffirmation();
});

final affirmationsByCategoryProvider = FutureProvider.family<List<AffirmationModel>, String>(
  (ref, category) async {
    final affirmationService = ref.watch(affirmationServiceProvider);
    return affirmationService.getAffirmationsByCategory(category);
  },
);