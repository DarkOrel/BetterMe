// TODO: Replace dummy AIService with real Cloud Functions backend when ready.

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/exercise_model.dart';
import '../models/meal_model.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

/// AI service for generating workouts and recommendations
/// Currently uses dummy/mock implementations (no Cloud Functions)
class AIService {
  AIService();

  /// Get current user ID from Firebase Auth
  /// Returns the authenticated user's UID, or a demo fallback if not authenticated
  String _getCurrentUserId() {
    if (AppConfig.kUseFirebaseBackend) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return user.uid;
      }
    }
    // Only fallback for genuine offline/demo mode
    return 'local_demo_user';
  }

  /// Generate PPL workout using dummy implementation
  /// 
  /// Input: user profile
  /// Output: workout with exercises
  Future<WorkoutModel> generateWorkout({
    required UserModel user,
    required String workoutType, // 'Push', 'Pull', 'Legs'
    required DateTime date,
  }) async {
    try {
      // Use Firebase Auth UID if available, otherwise fallback
      final userId = _getCurrentUserId();
      debugPrint('Generating dummy workout: $workoutType for user $userId');

      // Generate exercises based on workout type and user profile
      final exercises = _generateExercisesForType(
        workoutType,
        user.experienceLevel,
        user.goal,
        user.gender,
      );

      return WorkoutModel(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId, // Use Firebase Auth UID, not user.uid which might be stale
        workoutType: workoutType,
        date: date,
        exercises: exercises,
        completed: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error in generateWorkout (returning safe default): $e');
      // Return a safe default workout on error
      final userId = _getCurrentUserId();
      // Generate minimal safe exercises
      final safeExercises = _generateExercisesForType(
        workoutType,
        user.experienceLevel.isNotEmpty ? user.experienceLevel : 'beginner',
        user.goal.isNotEmpty ? user.goal : 'maintain',
        user.gender.isNotEmpty ? user.gender : 'male',
      );
      
      return WorkoutModel(
        id: 'workout_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        workoutType: workoutType.isNotEmpty ? workoutType : 'Push',
        date: date,
        exercises: safeExercises.isNotEmpty ? safeExercises : [],
        completed: false,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Generate exercises for a specific workout type
  List<ExerciseModel> _generateExercisesForType(
    String workoutType,
    String experienceLevel,
    String goal,
    String gender,
  ) {
    final exercises = <ExerciseModel>[];
    final baseTimestamp = DateTime.now().millisecondsSinceEpoch;

    switch (workoutType) {
      case AppConstants.pushWorkout:
        exercises.addAll(_getPushExercises(experienceLevel, goal, baseTimestamp));
        break;
      case AppConstants.pullWorkout:
        exercises.addAll(_getPullExercises(experienceLevel, goal, baseTimestamp));
        break;
      case AppConstants.legsWorkout:
        exercises.addAll(_getLegsExercises(experienceLevel, goal, baseTimestamp));
        break;
      default:
        // Default to push exercises if unknown type
        exercises.addAll(_getPushExercises(experienceLevel, goal, baseTimestamp));
    }

    return exercises;
  }

  /// Get push day exercises
  List<ExerciseModel> _getPushExercises(String experienceLevel, String goal, int baseTimestamp) {
    final exercises = <ExerciseModel>[];
    int exerciseCounter = 1;

    // Base exercises for all levels
    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Bench Press',
      primaryMuscle: 'Chest',
      secondaryMuscles: ['Shoulders', 'Triceps'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'Keep your feet flat on the floor and maintain a slight arch in your back.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Overhead Press',
      primaryMuscle: 'Shoulders',
      secondaryMuscles: ['Triceps'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'Keep your core tight and press straight up, not forward.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Tricep Dips',
      primaryMuscle: 'Triceps',
      secondaryMuscles: ['Shoulders'],
      sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      reps: _getRepsForLevel(experienceLevel, isCompound: false),
    ));
    exerciseCounter++;

    // Add more exercises for intermediate/advanced
    if (experienceLevel != AppConstants.beginner) {
      exercises.add(ExerciseModel(
        id: 'exercise_${baseTimestamp}_$exerciseCounter',
        name: 'Incline Dumbbell Press',
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Shoulders'],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
        reps: _getRepsForLevel(experienceLevel, isCompound: false),
      ));
      exerciseCounter++;

      exercises.add(ExerciseModel(
        id: 'exercise_${baseTimestamp}_$exerciseCounter',
        name: 'Lateral Raises',
        primaryMuscle: 'Shoulders',
        secondaryMuscles: [],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
        reps: _getRepsForLevel(experienceLevel, isCompound: false),
      ));
    }

    return exercises;
  }

  /// Get pull day exercises
  List<ExerciseModel> _getPullExercises(String experienceLevel, String goal, int baseTimestamp) {
    final exercises = <ExerciseModel>[];
    int exerciseCounter = 1;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Deadlift',
      primaryMuscle: 'Back',
      secondaryMuscles: ['Hamstrings', 'Glutes'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'Keep your back straight and drive through your heels.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Pull-ups',
      primaryMuscle: 'Back',
      secondaryMuscles: ['Biceps'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'If you can\'t do pull-ups, use an assisted machine or lat pulldown.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Barbell Rows',
      primaryMuscle: 'Back',
      secondaryMuscles: ['Biceps'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'Pull the bar to your lower chest/upper abdomen.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Bicep Curls',
      primaryMuscle: 'Biceps',
      secondaryMuscles: [],
      sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      reps: _getRepsForLevel(experienceLevel, isCompound: false),
    ));
    exerciseCounter++;

    if (experienceLevel != AppConstants.beginner) {
      exercises.add(ExerciseModel(
        id: 'exercise_${baseTimestamp}_$exerciseCounter',
        name: 'Face Pulls',
        primaryMuscle: 'Rear Delts',
        secondaryMuscles: ['Back'],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
        reps: _getRepsForLevel(experienceLevel, isCompound: false),
      ));
    }

    return exercises;
  }

  /// Get legs day exercises
  List<ExerciseModel> _getLegsExercises(String experienceLevel, String goal, int baseTimestamp) {
    final exercises = <ExerciseModel>[];
    int exerciseCounter = 1;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Squat',
      primaryMuscle: 'Quadriceps',
      secondaryMuscles: ['Glutes', 'Hamstrings'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'Go down until your thighs are parallel to the floor or lower.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Romanian Deadlift',
      primaryMuscle: 'Hamstrings',
      secondaryMuscles: ['Glutes'],
      sets: _getSetsForLevel(experienceLevel),
      reps: _getRepsForLevel(experienceLevel, isCompound: true),
      tips: 'Keep your legs mostly straight and feel the stretch in your hamstrings.',
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Leg Press',
      primaryMuscle: 'Quadriceps',
      secondaryMuscles: ['Glutes'],
      sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      reps: _getRepsForLevel(experienceLevel, isCompound: false),
    ));
    exerciseCounter++;

    exercises.add(ExerciseModel(
      id: 'exercise_${baseTimestamp}_$exerciseCounter',
      name: 'Calf Raises',
      primaryMuscle: 'Calves',
      secondaryMuscles: [],
      sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      reps: _getRepsForLevel(experienceLevel, isCompound: false),
    ));
    exerciseCounter++;

    if (experienceLevel != AppConstants.beginner) {
      exercises.add(ExerciseModel(
        id: 'exercise_${baseTimestamp}_$exerciseCounter',
        name: 'Leg Curls',
        primaryMuscle: 'Hamstrings',
        secondaryMuscles: [],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
        reps: _getRepsForLevel(experienceLevel, isCompound: false),
      ));
    }

    return exercises;
  }

  /// Get number of sets based on experience level
  int _getSetsForLevel(String experienceLevel, {bool isAccessory = false}) {
    if (isAccessory) {
      return experienceLevel == AppConstants.beginner ? 2 : 3;
    }

    switch (experienceLevel) {
      case AppConstants.beginner:
        return 3;
      case AppConstants.intermediate:
        return 4;
      case AppConstants.advanced:
        return 4;
      default:
        return 3;
    }
  }

  /// Get number of reps based on experience level and exercise type
  int _getRepsForLevel(String experienceLevel, {required bool isCompound}) {
    if (isCompound) {
      switch (experienceLevel) {
        case AppConstants.beginner:
          return 8;
        case AppConstants.intermediate:
          return 8;
        case AppConstants.advanced:
          return 6;
        default:
          return 8;
      }
    } else {
      // Accessory exercises
      return 10;
    }
  }

  /// Get nutrition recommendations (dummy implementation)
  /// 
  /// Input: user macros + meals today
  /// Output: suggestions to reach calorie/protein goals
  Future<Map<String, dynamic>> getNutritionRecommendations({
    required UserModel user,
    required List<MealModel> mealsToday,
    required double targetCalories,
    required double targetProtein,
  }) async {
    try {
      debugPrint('Generating dummy nutrition recommendations');

      // Calculate consumed values
      final consumedCalories = mealsToday.fold<double>(
        0.0,
        (sum, meal) => sum + meal.calories,
      );
      final consumedProtein = mealsToday.fold<double>(
        0.0,
        (sum, meal) => sum + meal.protein,
      );

      final remainingCalories = targetCalories - consumedCalories;
      final remainingProtein = targetProtein - consumedProtein;

      final suggestions = <String>[];

      if (remainingCalories > 200) {
        suggestions.add('You have ${remainingCalories.toInt()} calories remaining. Consider adding a healthy snack.');
      }

      if (remainingProtein > 30) {
        suggestions.add('You need ${remainingProtein.toInt()}g more protein. Try adding lean meat, eggs, or protein shake.');
      }

      if (remainingCalories < -200) {
        suggestions.add('You\'re over your calorie target by ${(-remainingCalories).toInt()} calories.');
      }

      return {
        'suggestions': suggestions,
        'remainingCalories': remainingCalories,
        'remainingProtein': remainingProtein,
        'consumedCalories': consumedCalories,
        'consumedProtein': consumedProtein,
      };
    } catch (e) {
      debugPrint('Error in getNutritionRecommendations: $e');
      return {
        'suggestions': [],
        'remainingCalories': targetCalories,
        'remainingProtein': targetProtein,
        'consumedCalories': 0.0,
        'consumedProtein': 0.0,
      };
    }
  }

  /// Get personalized weekly adjustments (dummy implementation)
  /// 
  /// Input: user workout history
  /// Output: overload suggestions (sets, reps, weight)
  Future<Map<String, dynamic>> getWeeklyAdjustments({
    required String userId,
    required List<WorkoutModel> workoutHistory,
  }) async {
    try {
      debugPrint('Generating dummy weekly adjustments');

      final adjustments = <Map<String, dynamic>>[];

      // Simple logic: if user completed workouts, suggest slight increases
      final completedWorkouts = workoutHistory.where((w) => w.completed).length;

      if (completedWorkouts >= 3) {
        adjustments.add({
          'exerciseId': 'bench_press',
          'suggestion': 'Consider increasing weight by 2.5kg or adding 1 set',
          'type': 'progressive_overload',
        });
      }

      return {
        'adjustments': adjustments,
        'message': 'Keep up the great work! Continue progressive overload.',
      };
    } catch (e) {
      debugPrint('Error in getWeeklyAdjustments: $e');
      return {
        'adjustments': [],
        'message': 'Unable to generate adjustments at this time.',
      };
    }
  }

  /// Analyze food image and return food items + calories (dummy implementation)
  /// 
  /// Uses dummy data instead of Google ML Vision API
  Future<List<Map<String, dynamic>>> analyzeFoodImage({
    required String imageUrl,
  }) async {
    try {
      debugPrint('Dummy food image analysis for: $imageUrl');

      // Return dummy food items
      return [
        {
          'foodName': 'Chicken Breast',
          'calories': 231.0,
          'protein': 43.5,
          'carbs': 0.0,
          'fat': 5.0,
          'confidence': 0.85,
        },
        {
          'foodName': 'Brown Rice',
          'calories': 112.0,
          'protein': 2.6,
          'carbs': 23.0,
          'fat': 0.9,
          'confidence': 0.75,
        },
      ];
    } catch (e) {
      debugPrint('Error in analyzeFoodImage: $e');
      return [];
    }
  }
}
