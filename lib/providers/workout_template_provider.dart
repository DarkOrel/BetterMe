import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/repositories/workout_repository.dart';
import '../core/models/workout_template.dart';

/// Workout repository provider
final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

/// All workout templates provider
final workoutTemplatesProvider = FutureProvider<List<WorkoutTemplate>>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return await repo.getAll();
});

/// Workout template by ID provider
final workoutTemplateByIdProvider = FutureProvider.family<WorkoutTemplate?, String>((ref, id) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return await repo.getById(id);
});

