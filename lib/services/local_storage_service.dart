import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/meal_model.dart';
import '../models/weekly_program_model.dart';

/// Local storage service for storing data without Firebase
class LocalStorageService {
  static const String _userKey = 'user_profile';
  static const String _workoutsKey = 'workouts';
  static const String _mealsKey = 'meals';
  static const String _weeklyProgramKey = 'weekly_program';

  /// Save user profile
  Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson(forFirestore: false)));
      debugPrint('User saved to local storage');
    } catch (e) {
      debugPrint('Error saving user: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson == null) return null;

      final json = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Save workout
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getString(_workoutsKey);
      final List<Map<String, dynamic>> workouts = workoutsJson != null
          ? (jsonDecode(workoutsJson) as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : [];

      // Remove existing workout for same date
      workouts.removeWhere((w) => w['id'] == workout.id);

      // Add new workout
      workouts.add(workout.toJson(forFirestore: false));

      await prefs.setString(_workoutsKey, jsonEncode(workouts));
      debugPrint('Workout saved to local storage');
    } catch (e) {
      debugPrint('Error saving workout: $e');
      rethrow;
    }
  }

  /// Get workout for a specific date
  Future<WorkoutModel?> getWorkout(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getString(_workoutsKey);
      if (workoutsJson == null) return null;

      final workouts = (jsonDecode(workoutsJson) as List<dynamic>)
          .map((e) => WorkoutModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final dateString = _formatDate(date);
      try {
        return workouts.firstWhere(
          (w) => _formatDate(w.date) == dateString,
        );
      } catch (e) {
        return null;
      }
    } catch (e) {
      debugPrint('Error getting workout: $e');
      return null;
    }
  }

  /// Get all workouts
  Future<List<WorkoutModel>> getAllWorkouts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workoutsJson = prefs.getString(_workoutsKey);
      if (workoutsJson == null) return [];

      return (jsonDecode(workoutsJson) as List<dynamic>)
          .map((e) => WorkoutModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting workouts: $e');
      return [];
    }
  }

  /// Save meal
  Future<void> saveMeal(MealModel meal) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      final List<Map<String, dynamic>> meals = mealsJson != null
          ? (jsonDecode(mealsJson) as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : [];

      meals.add(meal.toJson());
      await prefs.setString(_mealsKey, jsonEncode(meals));
      debugPrint('Meal saved to local storage');
    } catch (e) {
      debugPrint('Error saving meal: $e');
      rethrow;
    }
  }

  /// Get meals for a specific date
  Future<List<MealModel>> getMeals(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      if (mealsJson == null) return [];

      final meals = (jsonDecode(mealsJson) as List<dynamic>)
          .map((e) => MealModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final dateString = _formatDate(date);
      return meals.where((m) => _formatDate(m.date) == dateString).toList();
    } catch (e) {
      debugPrint('Error getting meals: $e');
      return [];
    }
  }

  /// Save weekly program
  Future<void> saveWeeklyProgram(WeeklyProgram program) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weeklyProgramKey, jsonEncode(program.toJson()));
      debugPrint('Weekly program saved to local storage');
    } catch (e) {
      debugPrint('Error saving weekly program: $e');
      rethrow;
    }
  }

  /// Get weekly program
  Future<WeeklyProgram?> getWeeklyProgram() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final programJson = prefs.getString(_weeklyProgramKey);
      if (programJson == null) return null;

      return WeeklyProgram.fromJson(
          jsonDecode(programJson) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting weekly program: $e');
      return null;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

