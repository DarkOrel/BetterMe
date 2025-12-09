import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/workout_template_provider.dart';
import '../../../../providers/exercise_provider.dart';
import '../../../../core/models/exercise.dart';

/// Workout Player screen - guides user through workout exercises
class StartWorkoutScreen extends ConsumerStatefulWidget {
  final String workoutId;

  const StartWorkoutScreen({
    super.key,
    required this.workoutId,
  });

  @override
  ConsumerState<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends ConsumerState<StartWorkoutScreen> {
  int _currentExerciseIndex = 0;

  @override
  Widget build(BuildContext context) {
    final workoutAsync = ref.watch(workoutTemplateByIdProvider(widget.workoutId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
        actions: [
          TextButton(
            onPressed: () async {
              if (!mounted) return;
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('End Workout'),
                  content: const Text('Are you sure you want to end this workout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('End'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                context.pop();
              }
            },
            child: const Text('End'),
          ),
        ],
      ),
      body: workoutAsync.when(
        data: (workout) {
          if (workout == null) {
            return const Center(child: Text('Workout not found'));
          }

          if (workout.exercises.isEmpty) {
            return const Center(child: Text('This workout has no exercises'));
          }

          if (_currentExerciseIndex >= workout.exercises.length) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Workout Complete!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          }

          final workoutExercise = workout.exercises[_currentExerciseIndex];
          return FutureBuilder<Exercise?>(
            future: ref.read(exerciseByIdProvider(workoutExercise.exerciseId).future),
            builder: (context, snapshot) {
              final exercise = snapshot.data;

              return Column(
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (_currentExerciseIndex + 1) / workout.exercises.length,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Exercise ${_currentExerciseIndex + 1} of ${workout.exercises.length}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  // Exercise details
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (exercise != null) ...[
                              Icon(
                                Icons.fitness_center,
                                size: 80,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                exercise.primaryMuscleGroup.displayName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                              const SizedBox(height: 32),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${workoutExercise.targetSets} Sets',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${workoutExercise.targetReps} Reps',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      if (workoutExercise.targetRestSeconds != null) ...[
                                        const SizedBox(height: 16),
                                        Text(
                                          'Rest: ${workoutExercise.targetRestSeconds}s',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              if (exercise.description != null) ...[
                                const SizedBox(height: 24),
                                Text(
                                  exercise.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ] else
                              const CircularProgressIndicator(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_currentExerciseIndex > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _currentExerciseIndex--;
                                });
                              },
                              child: const Text('Previous'),
                            ),
                          ),
                        if (_currentExerciseIndex > 0) const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentExerciseIndex < workout.exercises.length - 1) {
                                setState(() {
                                  _currentExerciseIndex++;
                                });
                              } else {
                                // Workout complete
                                setState(() {
                                  _currentExerciseIndex = workout.exercises.length;
                                });
                              }
                            },
                            child: Text(
                              _currentExerciseIndex < workout.exercises.length - 1
                                  ? 'Next Exercise'
                                  : 'Complete Workout',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

