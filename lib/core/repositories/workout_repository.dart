import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout_template.dart';

/// Repository for managing workout templates
class WorkoutRepository {
  static const String _boxName = 'workouts';
  late Box _box;

  /// Initialize the repository
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Get all workout templates
  Future<List<WorkoutTemplate>> getAll() async {
    final workoutsJson = _box.values.toList();
    return workoutsJson
        .map((json) => WorkoutTemplate.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Get workout template by ID
  Future<WorkoutTemplate?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    return WorkoutTemplate.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// Add or update a workout template
  Future<void> addOrUpdate(WorkoutTemplate workout) async {
    await _box.put(
      workout.id,
      workout.copyWith(updatedAt: DateTime.now()).toJson(),
    );
  }

  /// Delete a workout template
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}

