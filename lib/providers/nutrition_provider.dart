import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../core/config/app_config.dart';
import 'auth_provider.dart';
import 'user_provider.dart';
import 'local_storage_provider.dart';

/// Today's meals provider (uses local storage in local-only mode)
final todaysMealsProvider = FutureProvider<List<MealModel>>((ref) async {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  if (!AppConfig.kUseFirebaseBackend) {
    // Use local storage
    final localStorage = ref.watch(localStorageServiceProvider);
    return await localStorage.getMeals(todayStart);
  } else {
    // Use Firestore
    final firestore = ref.watch(firestoreServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return [];
    }

    return await firestore.getMeals(null, todayStart);
  }
});

/// Nutrition stats provider (calories, protein, etc.)
final nutritionStatsProvider = Provider<Map<String, double>>((ref) {
  final mealsAsync = ref.watch(todaysMealsProvider);
  
  return mealsAsync.when(
    data: (meals) {
      return {
        'calories': meals.fold(0.0, (sum, meal) => sum + meal.calories),
        'protein': meals.fold(0.0, (sum, meal) => sum + meal.protein),
        'carbs': meals.fold(0.0, (sum, meal) => sum + meal.carbs),
        'fat': meals.fold(0.0, (sum, meal) => sum + meal.fat),
      };
    },
    loading: () => {'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0},
    error: (_, __) => {'calories': 0.0, 'protein': 0.0, 'carbs': 0.0, 'fat': 0.0},
  );
});

/// Nutrition state provider for saving meals
final nutritionStateProvider = StateNotifierProvider<NutritionNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  
  return NutritionNotifier(firestore, localStorage);
});

/// Nutrition notifier for state management
class NutritionNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;

  NutritionNotifier(this._firestore, this._localStorage)
      : super(const AsyncValue.data(null));

  /// Save meal
  /// Handles errors gracefully - does not crash UI
  Future<void> saveMeal(MealModel meal) async {
    try {
      state = const AsyncValue.loading();
      
      if (!AppConfig.kUseFirebaseBackend) {
        // Use local storage
        await _localStorage.saveMeal(meal);
      } else {
        // Use Firestore (will log errors but not throw)
        await _firestore.saveMeal(meal);
      }
      
      state = const AsyncValue.data(null);
    } catch (e) {
      debugPrint('Error in saveMeal (non-fatal): $e');
      // Still set state to data to allow UI to continue
      state = const AsyncValue.data(null);
    }
  }

  /// Get nutrition recommendations
  Future<Map<String, dynamic>> getRecommendations({
    required String userId,
    required List<MealModel> mealsToday,
    required double targetCalories,
    required double targetProtein,
  }) async {
    // This would need user profile, but for now return empty
    // In real implementation, fetch user profile first
    return {};
  }
}




