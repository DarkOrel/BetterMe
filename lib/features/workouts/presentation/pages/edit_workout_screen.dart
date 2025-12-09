import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/workout_template.dart';
import '../../../../core/models/workout_exercise.dart';
import '../../../../core/models/exercise.dart';
import '../../../../providers/workout_template_provider.dart';
import '../../../../providers/exercise_provider.dart';

/// Edit/Create workout template screen
class EditWorkoutScreen extends ConsumerStatefulWidget {
  final String? workoutId;

  const EditWorkoutScreen({
    super.key,
    this.workoutId,
  });

  @override
  ConsumerState<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends ConsumerState<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final List<WorkoutExercise> _exercises = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.workoutId != null) {
      _loadWorkout();
    }
  }

  Future<void> _loadWorkout() async {
    if (widget.workoutId == null) return;

    final workoutAsync = ref.read(workoutTemplateByIdProvider(widget.workoutId!));
    workoutAsync.whenData((workout) {
      if (workout != null && mounted) {
        setState(() {
          _nameController.text = workout.name;
          _exercises.clear();
          _exercises.addAll(workout.exercises);
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addExercise() async {
    final exercisesAsync = ref.read(exercisesProvider);
    final allExercises = exercisesAsync.value ?? [];

    if (allExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercises available. Please add exercises first.')),
      );
      return;
    }

    if (!mounted) return;
    final selected = await showDialog<Exercise>(
      context: context,
      builder: (context) => _ExercisePickerDialog(exercises: allExercises),
    );

    if (selected != null && mounted) {
      final setsController = TextEditingController(text: '3');
      final repsController = TextEditingController(text: '10');

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add ${selected.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                decoration: const InputDecoration(
                  labelText: 'Sets',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: repsController,
                decoration: const InputDecoration(
                  labelText: 'Reps (e.g., 8-12 or 10)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add'),
            ),
          ],
        ),
      );

      if (confirmed == true && mounted) {
        setState(() {
          _exercises.add(WorkoutExercise(
            exerciseId: selected.id,
            targetSets: int.tryParse(setsController.text) ?? 3,
            targetReps: repsController.text.trim(),
          ));
        });
      }

      setsController.dispose();
      repsController.dispose();
    }
  }

  Future<void> _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one exercise')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      final now = DateTime.now();

      final workout = WorkoutTemplate(
        id: widget.workoutId ?? 'workout_${now.millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        exercises: _exercises,
        createdAt: widget.workoutId != null
            ? (await repo.getById(widget.workoutId!))?.createdAt ?? now
            : now,
        updatedAt: now,
      );

      await repo.addOrUpdate(workout);
      ref.invalidate(workoutTemplatesProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.workoutId == null ? 'Workout created' : 'Workout updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteWorkout() async {
    if (widget.workoutId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.delete(widget.workoutId!);
      ref.invalidate(workoutTemplatesProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.workoutId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Workout' : 'New Workout'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _deleteWorkout,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Workout name
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Workout Name *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a workout name';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Exercises list
                  Expanded(
                    child: _exercises.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No exercises added',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _addExercise,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Exercise'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _exercises.length,
                            itemBuilder: (context, index) {
                              final workoutExercise = _exercises[index];
                              return FutureBuilder<Exercise?>(
                                future: ref.read(exerciseByIdProvider(workoutExercise.exerciseId).future),
                                builder: (context, snapshot) {
                                  final exercise = snapshot.data;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      title: Text(exercise?.name ?? 'Loading...'),
                                      subtitle: Text(
                                        '${workoutExercise.targetSets} sets × ${workoutExercise.targetReps} reps',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _editExercise(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                _exercises.removeAt(index);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),

                  // Add exercise button
                  if (_exercises.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton.icon(
                        onPressed: _addExercise,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Exercise'),
                      ),
                    ),

                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: _saveWorkout,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Save Workout'),
                        ),
                        if (isEditing) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              context.push('/workouts/${widget.workoutId}/start');
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Workout'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _editExercise(int index) async {
    final workoutExercise = _exercises[index];
    final setsController = TextEditingController(text: workoutExercise.targetSets.toString());
    final repsController = TextEditingController(text: workoutExercise.targetReps);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: setsController,
              decoration: const InputDecoration(
                labelText: 'Sets',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: repsController,
              decoration: const InputDecoration(
                labelText: 'Reps (e.g., 8-12 or 10)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _exercises[index] = workoutExercise.copyWith(
          targetSets: int.tryParse(setsController.text) ?? workoutExercise.targetSets,
          targetReps: repsController.text.trim(),
        );
      });
    }

    setsController.dispose();
    repsController.dispose();
  }
}

/// Exercise picker dialog
class _ExercisePickerDialog extends StatelessWidget {
  final List<Exercise> exercises;

  const _ExercisePickerDialog({required this.exercises});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          AppBar(
            title: const Text('Select Exercise'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.primaryMuscleGroup.displayName} • ${exercise.equipment}',
                  ),
                  onTap: () => Navigator.pop(context, exercise),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

