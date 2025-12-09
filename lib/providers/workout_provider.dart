import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/ai_service.dart';
import '../services/ppl_generator_service.dart';
import '../core/config/app_config.dart';
import 'auth_provider.dart';
import 'user_provider.dart';
import 'local_storage_provider.dart';

/// AI service provider
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

/// PPL generator service provider
final pplGeneratorServiceProvider = Provider<PPLGeneratorService>((ref) {
  return PPLGeneratorService();
});

/// Today's workout provider (uses local storage in local-only mode)
final todaysWorkoutProvider = FutureProvider<WorkoutModel?>((ref) async {
  final today = DateTime.now();
  final todayStart = DateTime(today.year, today.month, today.day);

  if (!AppConfig.kUseFirebaseBackend) {
    // Use local storage
    final localStorage = ref.watch(localStorageServiceProvider);
    return await localStorage.getWorkout(todayStart);
  } else {
    // Use Firestore
    final firestore = ref.watch(firestoreServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return null;
    }

    return await firestore.getWorkout(null, todayStart);
  }
});

/// Workout history provider
final workoutHistoryProvider = StreamProvider<List<WorkoutModel>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return Stream.value([]);
  }

  return firestore.streamWorkoutHistory(null);
});

/// Workout state provider for generating and saving workouts
final workoutStateProvider = StateNotifierProvider<WorkoutNotifier, AsyncValue<WorkoutModel?>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final aiService = ref.watch(aiServiceProvider);
  final pplGenerator = ref.watch(pplGeneratorServiceProvider);
  final userProfile = ref.watch(userProfileProvider);
  
  return WorkoutNotifier(
    firestore,
    localStorage,
    aiService,
    pplGenerator,
    userProfile.value,
  );
});

/// Workout notifier for state management
class WorkoutNotifier extends StateNotifier<AsyncValue<WorkoutModel?>> {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;
  final AIService _aiService;
  final PPLGeneratorService _pplGenerator;
  final UserModel? _user;

  WorkoutNotifier(
    this._firestore,
    this._localStorage,
    this._aiService,
    this._pplGenerator,
    this._user,
  ) : super(const AsyncValue.data(null));

  /// Generate workout using AI or PPL generator
  Future<void> generateWorkout(String workoutType) async {
    if (_user == null) {
      state = const AsyncValue.error('User not found', StackTrace.empty);
      return;
    }

    try {
      state = const AsyncValue.loading();
      
      WorkoutModel workout;
      if (AppConfig.kUseFirebaseBackend) {
        // Use AI service (stubbed)
        workout = await _aiService.generateWorkout(
          user: _user!,
          workoutType: workoutType,
          date: DateTime.now(),
        );
      } else {
        // Use local PPL generator
        final today = DateTime.now();
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final program = _pplGenerator.generateWeeklyProgram(
          user: _user!,
          weekStart: weekStart,
        );
        
        // Find today's workout from program
        final todayWorkout = program.workoutDays.firstWhere(
          (day) => _formatDate(day.date) == _formatDate(today),
        );
        
        // Convert WorkoutDay to WorkoutModel
        workout = WorkoutModel(
          id: 'workout_${today.millisecondsSinceEpoch}',
          userId: _user!.uid,
          workoutType: todayWorkout.workoutType,
          date: today,
          exercises: todayWorkout.exercises.map((we) {
            return ExerciseModel(
              id: we.exerciseId,
              name: we.exerciseName,
              primaryMuscle: we.primaryMuscle,
              secondaryMuscles: we.secondaryMuscles,
              sets: we.sets.length,
              reps: we.sets.isNotEmpty ? we.sets.first.reps : 8,
              weight: null,
              rpe: null,
            );
          }).toList(),
          completed: false,
          createdAt: DateTime.now(),
        );
      }
      
      state = AsyncValue.data(workout);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  /// Save workout
  /// Handles errors gracefully - does not crash UI
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      state = const AsyncValue.loading();
      
      if (!AppConfig.kUseFirebaseBackend) {
        // Use local storage
        await _localStorage.saveWorkout(workout);
      } else {
        // Use Firestore (will log errors but not throw)
        await _firestore.saveWorkout(workout);
      }
      
      state = AsyncValue.data(workout);
    } catch (e) {
      debugPrint('Error in saveWorkout (non-fatal): $e');
      // Still set state to data to allow UI to continue
      state = AsyncValue.data(workout);
    }
  }

  /// Update workout
  /// Handles errors gracefully - does not crash UI
  Future<void> updateWorkout(WorkoutModel workout) async {
    try {
      state = const AsyncValue.loading();
      
      if (!AppConfig.kUseFirebaseBackend) {
        // Use local storage
        await _localStorage.saveWorkout(workout);
      } else {
        // Use Firestore (will log errors but not throw)
        await _firestore.saveWorkout(workout);
      }
      
      state = AsyncValue.data(workout);
    } catch (e) {
      debugPrint('Error in updateWorkout (non-fatal): $e');
      // Still set state to data to allow UI to continue
      state = AsyncValue.data(workout);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

