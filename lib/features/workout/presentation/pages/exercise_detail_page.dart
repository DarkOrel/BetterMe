import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/exercise_model.dart';
import '../../../../providers/workout_provider.dart';

/// Exercise detail page for logging sets, reps, and weight
class ExerciseDetailPage extends ConsumerStatefulWidget {
  final String exerciseId;

  const ExerciseDetailPage({
    super.key,
    required this.exerciseId,
  });

  @override
  ConsumerState<ExerciseDetailPage> createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends ConsumerState<ExerciseDetailPage> {
  ExerciseModel? _exercise;
  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _repsControllers = [];
  final List<TextEditingController> _rpeControllers = [];

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  void _loadExercise() {
    // Get exercise from current workout
    final workoutState = ref.read(workoutStateProvider);
    workoutState.whenData((workout) {
      if (workout != null) {
        final exercise = workout.exercises.firstWhere(
          (e) => e.id == widget.exerciseId,
          orElse: () => workout.exercises.first,
        );
        
        setState(() {
          _exercise = exercise;
          // Initialize controllers for each set
          for (var i = 0; i < exercise.sets; i++) {
            _weightControllers.add(TextEditingController(
              text: exercise.weight?.toString() ?? '',
            ));
            _repsControllers.add(TextEditingController(
              text: exercise.reps.toString(),
            ));
            _rpeControllers.add(TextEditingController(
              text: exercise.rpe?.toString() ?? '',
            ));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    for (var controller in _rpeControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (_exercise == null) return;

    // Update exercise with logged data
    final updatedExercise = _exercise!.copyWith(
      weight: _weightControllers.isNotEmpty
          ? double.tryParse(_weightControllers.first.text)
          : null,
      reps: _repsControllers.isNotEmpty
          ? int.tryParse(_repsControllers.first.text) ?? _exercise!.reps
          : _exercise!.reps,
      rpe: _rpeControllers.isNotEmpty
          ? int.tryParse(_rpeControllers.first.text)
          : null,
    );

    // Update workout
    final workoutState = ref.read(workoutStateProvider);
    workoutState.whenData((workout) async {
      if (workout != null) {
        final updatedExercises = workout.exercises.map((e) {
          return e.id == widget.exerciseId ? updatedExercise : e;
        }).toList();

        final updatedWorkout = workout.copyWith(exercises: updatedExercises);
        final notifier = ref.read(workoutStateProvider.notifier);
        await notifier.updateWorkout(updatedWorkout);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise updated')),
          );
          Navigator.pop(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exercise == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Exercise Details'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _exercise!.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Primary: ${_exercise!.primaryMuscle}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_exercise!.secondaryMuscles.isNotEmpty)
                      Text(
                        'Secondary: ${_exercise!.secondaryMuscles.join(", ")}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if (_exercise!.tips != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Tips:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(_exercise!.tips!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sets List
            Text(
              'Sets',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...List.generate(_exercise!.sets, (index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _weightControllers[index],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Weight (kg)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _repsControllers[index],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Reps',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _rpeControllers[index],
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'RPE (1-10)',
                                border: OutlineInputBorder(),
                                hintText: 'Optional',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveExercise,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Exercise'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
