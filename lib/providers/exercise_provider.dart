import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/repositories/exercise_repository.dart';
import '../core/models/exercise.dart';
import '../core/models/muscle_group.dart';

/// Exercise repository provider
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository();
});

/// All exercises provider
final exercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return await repo.getAll();
});

/// Exercises by muscle group provider
final exercisesByMuscleGroupProvider = FutureProvider.family<List<Exercise>, MuscleGroup>((ref, muscleGroup) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return await repo.getByMuscleGroup(muscleGroup);
});

/// Exercise by ID provider
final exerciseByIdProvider = FutureProvider.family<Exercise?, String>((ref, id) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  return await repo.getById(id);
});

