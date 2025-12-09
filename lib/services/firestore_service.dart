import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/meal_model.dart';
import '../models/muscle_load_model.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

/// Firestore service for database operations
class FirestoreService {
  FirebaseFirestore? _firestore;

  FirestoreService() {
    if (AppConfig.kUseFirebaseBackend) {
      _firestore = FirebaseFirestore.instance;
    }
  }

  /// Get current user ID from Firebase Auth
  /// Returns the authenticated user's UID, or null if not authenticated
  String? _getCurrentUserId() {
    if (!AppConfig.kUseFirebaseBackend) {
      return null;
    }
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // ========== User Operations ==========

  /// Save user profile to Firestore
  /// Returns void - logs errors but does not throw to prevent UI crashes
  Future<void> saveUser(UserModel user) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('saveUser() skipped (local-only mode)');
      return;
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      debugPrint('saveUser() skipped: No authenticated user');
      return;
    }

    try {
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(user.toJson(forFirestore: true));
    } catch (e) {
      debugPrint('Error in saveUser (non-fatal): $e');
      // Do not throw - allow app to continue
    }
  }

  /// Get user profile from Firestore
  /// Returns null on error - logs but does not throw
  Future<UserModel?> getUser(String uid) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('getUser() skipped (local-only mode)');
      return null;
    }

    try {
      final doc = await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error in getUser (non-fatal): $e');
      return null; // Return null instead of throwing
    }
  }

  /// Update user profile
  /// Returns void - logs errors but does not throw to prevent UI crashes
  Future<void> updateUser(UserModel user) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('updateUser() skipped (local-only mode)');
      return;
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      debugPrint('updateUser() skipped: No authenticated user');
      return;
    }

    try {
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(user.copyWith(updatedAt: DateTime.now()).toJson(forFirestore: true));
    } catch (e) {
      debugPrint('Error in updateUser (non-fatal): $e');
      // Do not throw - allow app to continue
    }
  }

  /// Stream user profile changes
  Stream<UserModel?> streamUser(String uid) {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('streamUser() skipped (local-only mode)');
      return Stream.value(null);
    }

    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // ========== Workout Operations ==========

  /// Save workout to Firestore
  /// Uses current authenticated user's UID to ensure permission consistency
  /// Returns void - logs errors but does not throw to prevent UI crashes
  Future<void> saveWorkout(WorkoutModel workout) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('saveWorkout() skipped (local-only mode)');
      return;
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      debugPrint('saveWorkout() skipped: No authenticated user');
      return;
    }

    try {
      final dateString = _formatDate(workout.date);
      // Use authenticated user's UID, not the workout.userId which might be stale
      final workoutWithCorrectUserId = workout.copyWith(userId: userId);
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.workoutHistoryCollection)
          .doc(dateString)
          .set(workoutWithCorrectUserId.toJson(forFirestore: true));
    } catch (e) {
      debugPrint('Error in saveWorkout (non-fatal): $e');
      // Do not throw - allow app to continue
    }
  }

  /// Get workout for a specific date
  /// Uses current authenticated user's UID
  /// Returns null on error - logs but does not throw
  Future<WorkoutModel?> getWorkout(String? userId, DateTime date) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('getWorkout() skipped (local-only mode)');
      return null;
    }

    try {
      final currentUserId = userId ?? _getCurrentUserId();
      if (currentUserId == null) {
        return null;
      }

      final dateString = _formatDate(date);
      final doc = await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.workoutHistoryCollection)
          .doc(dateString)
          .get();

      if (doc.exists) {
        return WorkoutModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error in getWorkout (non-fatal): $e');
      return null; // Return null instead of throwing
    }
  }

  /// Get workout history stream
  /// Uses current authenticated user's UID
  Stream<List<WorkoutModel>> streamWorkoutHistory(String? userId) {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('streamWorkoutHistory() skipped (local-only mode)');
      return Stream.value([]);
    }

    final currentUserId = userId ?? _getCurrentUserId();
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .collection(AppConstants.workoutHistoryCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => WorkoutModel.fromJson(doc.data()))
          .toList();
    });
  }

  // ========== Nutrition Operations ==========

  /// Save meal to Firestore
  /// Uses current authenticated user's UID to ensure permission consistency
  /// Returns void - logs errors but does not throw to prevent UI crashes
  Future<void> saveMeal(MealModel meal) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('saveMeal() skipped (local-only mode)');
      return;
    }

    final userId = _getCurrentUserId();
    if (userId == null) {
      debugPrint('saveMeal() skipped: No authenticated user');
      return;
    }

    try {
      final dateString = _formatDate(meal.date);
      // Use authenticated user's UID, not the meal.userId which might be stale
      final mealWithCorrectUserId = meal.copyWith(userId: userId);
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection(AppConstants.nutritionCollection)
          .doc(dateString)
          .collection('meals')
          .doc(mealWithCorrectUserId.id)
          .set(mealWithCorrectUserId.toJson(forFirestore: true));
    } catch (e) {
      debugPrint('Error in saveMeal (non-fatal): $e');
      // Do not throw - allow app to continue
    }
  }

  /// Get meals for a specific date
  /// Uses current authenticated user's UID
  /// Returns empty list on error - logs but does not throw
  Future<List<MealModel>> getMeals(String? userId, DateTime date) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('getMeals() skipped (local-only mode)');
      return [];
    }

    try {
      final currentUserId = userId ?? _getCurrentUserId();
      if (currentUserId == null) {
        return [];
      }

      final dateString = _formatDate(date);
      final snapshot = await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.nutritionCollection)
          .doc(dateString)
          .collection('meals')
          .get();

      return snapshot.docs
          .map((doc) => MealModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error in getMeals (non-fatal): $e');
      return []; // Return empty list instead of throwing
    }
  }

  /// Stream meals for a specific date
  /// Uses current authenticated user's UID
  Stream<List<MealModel>> streamMeals(String? userId, DateTime date) {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('streamMeals() skipped (local-only mode)');
      return Stream.value([]);
    }

    final currentUserId = userId ?? _getCurrentUserId();
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final dateString = _formatDate(date);
    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .collection(AppConstants.nutritionCollection)
        .doc(dateString)
        .collection('meals')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MealModel.fromJson(doc.data()))
          .toList();
    });
  }

  // ========== Muscle Load Operations ==========

  /// Save muscle load data
  /// Uses current authenticated user's UID to ensure permission consistency
  /// Returns void - logs errors but does not throw to prevent UI crashes
  Future<void> saveMuscleLoad(
    String? userId,
    MuscleLoadModel muscleLoad,
  ) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('saveMuscleLoad() skipped (local-only mode)');
      return;
    }

    final currentUserId = userId ?? _getCurrentUserId();
    if (currentUserId == null) {
      debugPrint('saveMuscleLoad() skipped: No authenticated user');
      return;
    }

    try {
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.muscleLoadCollection)
          .doc(muscleLoad.muscleGroup)
          .set(muscleLoad.toJson());
    } catch (e) {
      debugPrint('Error in saveMuscleLoad (non-fatal): $e');
      // Do not throw - allow app to continue
    }
  }

  /// Get muscle load data
  /// Uses current authenticated user's UID
  /// Returns empty map on error - logs but does not throw
  Future<Map<String, MuscleLoadModel>> getMuscleLoads(String? userId) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('getMuscleLoads() skipped (local-only mode)');
      return {};
    }

    try {
      final currentUserId = userId ?? _getCurrentUserId();
      if (currentUserId == null) {
        return {};
      }

      final snapshot = await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.muscleLoadCollection)
          .get();

      final Map<String, MuscleLoadModel> loads = {};
      for (var doc in snapshot.docs) {
        final load = MuscleLoadModel.fromJson(doc.data());
        loads[load.muscleGroup] = load;
      }
      return loads;
    } catch (e) {
      debugPrint('Error in getMuscleLoads (non-fatal): $e');
      return {}; // Return empty map instead of throwing
    }
  }

  /// Stream muscle load data
  /// Uses current authenticated user's UID
  Stream<Map<String, MuscleLoadModel>> streamMuscleLoads(String? userId) {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('streamMuscleLoads() skipped (local-only mode)');
      return Stream.value({});
    }

    final currentUserId = userId ?? _getCurrentUserId();
    if (currentUserId == null) {
      return Stream.value({});
    }

    return _firestore!
        .collection(AppConstants.usersCollection)
        .doc(currentUserId)
        .collection(AppConstants.muscleLoadCollection)
        .snapshots()
        .map((snapshot) {
      final Map<String, MuscleLoadModel> loads = {};
      for (var doc in snapshot.docs) {
        final load = MuscleLoadModel.fromJson(doc.data());
        loads[load.muscleGroup] = load;
      }
      return loads;
    });
  }

  // ========== Helper Methods ==========

  /// Format date to string (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
