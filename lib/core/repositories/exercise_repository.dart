import 'package:hive_flutter/hive_flutter.dart';
import '../models/exercise.dart';
import '../models/muscle_group.dart';

/// Repository for managing exercises
class ExerciseRepository {
  static const String _boxName = 'exercises';
  late Box _box;

  /// Initialize the repository
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Get all exercises
  Future<List<Exercise>> getAll() async {
    final exercisesJson = _box.values.toList();
    return exercisesJson
        .map((json) => Exercise.fromJson(Map<String, dynamic>.from(json as Map)))
        .toList();
  }

  /// Get exercises by muscle group
  Future<List<Exercise>> getByMuscleGroup(MuscleGroup group) async {
    final all = await getAll();
    return all.where((exercise) {
      return exercise.primaryMuscleGroup == group ||
          exercise.secondaryMuscleGroups.contains(group);
    }).toList();
  }

  /// Get exercise by ID
  Future<Exercise?> getById(String id) async {
    final json = _box.get(id);
    if (json == null) return null;
    return Exercise.fromJson(Map<String, dynamic>.from(json as Map));
  }

  /// Search exercises by name
  Future<List<Exercise>> search(String query) async {
    final all = await getAll();
    final lowerQuery = query.toLowerCase();
    return all
        .where((exercise) => exercise.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Add or update an exercise
  Future<void> addOrUpdate(Exercise exercise) async {
    await _box.put(
      exercise.id,
      exercise.copyWith(updatedAt: DateTime.now()).toJson(),
    );
  }

  /// Delete an exercise (only if not built-in)
  Future<void> delete(String id) async {
    final exercise = await getById(id);
    if (exercise != null && !exercise.isBuiltIn) {
      await _box.delete(id);
    } else if (exercise?.isBuiltIn == true) {
      throw Exception('Cannot delete built-in exercise');
    }
  }

  /// Seed default exercises on first launch
  Future<void> seedDefaultsIfNeeded() async {
    final existing = await getAll();
    if (existing.isNotEmpty) return; // Already seeded

    final defaults = _getDefaultExercises();
    for (final exercise in defaults) {
      await addOrUpdate(exercise);
    }
  }

  /// Get default/built-in exercises
  List<Exercise> _getDefaultExercises() {
    final now = DateTime.now();
    return [
      // Chest
      Exercise(
        id: 'push_up',
        name: 'Push Up',
        primaryMuscleGroup: MuscleGroup.chest,
        secondaryMuscleGroups: [MuscleGroup.triceps, MuscleGroup.shoulders],
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Classic bodyweight chest exercise',
        techniqueNotes: 'Keep your body straight, lower until chest nearly touches floor',
        isBuiltIn: true,
        createdAt: now,
      ),
      Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        primaryMuscleGroup: MuscleGroup.chest,
        secondaryMuscleGroups: [MuscleGroup.triceps, MuscleGroup.shoulders],
        equipment: 'barbell',
        difficulty: ExerciseDifficulty.intermediate,
        description: 'Barbell bench press for chest development',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Back
      Exercise(
        id: 'pull_up',
        name: 'Pull Up',
        primaryMuscleGroup: MuscleGroup.back,
        secondaryMuscleGroups: [MuscleGroup.biceps],
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.intermediate,
        description: 'Bodyweight pulling exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
      Exercise(
        id: 'barbell_row',
        name: 'Barbell Row',
        primaryMuscleGroup: MuscleGroup.back,
        secondaryMuscleGroups: [MuscleGroup.biceps],
        equipment: 'barbell',
        difficulty: ExerciseDifficulty.intermediate,
        description: 'Bent-over row for back thickness',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Shoulders
      Exercise(
        id: 'shoulder_press',
        name: 'Shoulder Press',
        primaryMuscleGroup: MuscleGroup.shoulders,
        secondaryMuscleGroups: [MuscleGroup.triceps],
        equipment: 'dumbbell',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Overhead press for shoulder development',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Biceps
      Exercise(
        id: 'bicep_curl',
        name: 'Bicep Curl',
        primaryMuscleGroup: MuscleGroup.biceps,
        equipment: 'dumbbell',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Isolation exercise for biceps',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Triceps
      Exercise(
        id: 'tricep_dip',
        name: 'Tricep Dip',
        primaryMuscleGroup: MuscleGroup.triceps,
        secondaryMuscleGroups: [MuscleGroup.shoulders],
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Bodyweight tricep exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Abs
      Exercise(
        id: 'plank',
        name: 'Plank',
        primaryMuscleGroup: MuscleGroup.abs,
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Core strengthening exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
      Exercise(
        id: 'crunch',
        name: 'Crunch',
        primaryMuscleGroup: MuscleGroup.abs,
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Abdominal exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Glutes
      Exercise(
        id: 'hip_thrust',
        name: 'Hip Thrust',
        primaryMuscleGroup: MuscleGroup.glutes,
        secondaryMuscleGroups: [MuscleGroup.hamstrings],
        equipment: 'barbell',
        difficulty: ExerciseDifficulty.intermediate,
        description: 'Glute-focused exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Quads
      Exercise(
        id: 'squat',
        name: 'Squat',
        primaryMuscleGroup: MuscleGroup.quads,
        secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.hamstrings],
        equipment: 'barbell',
        difficulty: ExerciseDifficulty.intermediate,
        description: 'King of leg exercises',
        techniqueNotes: 'Keep knees aligned with toes, go below parallel',
        isBuiltIn: true,
        createdAt: now,
      ),
      Exercise(
        id: 'lunge',
        name: 'Lunge',
        primaryMuscleGroup: MuscleGroup.quads,
        secondaryMuscleGroups: [MuscleGroup.glutes],
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Unilateral leg exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Hamstrings
      Exercise(
        id: 'romanian_deadlift',
        name: 'Romanian Deadlift',
        primaryMuscleGroup: MuscleGroup.hamstrings,
        secondaryMuscleGroups: [MuscleGroup.glutes, MuscleGroup.back],
        equipment: 'barbell',
        difficulty: ExerciseDifficulty.intermediate,
        description: 'Hamstring and glute focused deadlift variation',
        isBuiltIn: true,
        createdAt: now,
      ),
      // Calves
      Exercise(
        id: 'calf_raise',
        name: 'Calf Raise',
        primaryMuscleGroup: MuscleGroup.calves,
        equipment: 'bodyweight',
        difficulty: ExerciseDifficulty.beginner,
        description: 'Calf muscle exercise',
        isBuiltIn: true,
        createdAt: now,
      ),
    ];
  }
}

