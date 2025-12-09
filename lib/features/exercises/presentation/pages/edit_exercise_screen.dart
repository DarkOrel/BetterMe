import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/exercise.dart';
import '../../../../core/models/muscle_group.dart';
import '../../../../providers/exercise_provider.dart';

/// Edit/Create exercise screen
class EditExerciseScreen extends ConsumerStatefulWidget {
  final String? exerciseId;
  final MuscleGroup? initialMuscleGroup;

  const EditExerciseScreen({
    super.key,
    this.exerciseId,
    this.initialMuscleGroup,
  });

  @override
  ConsumerState<EditExerciseScreen> createState() => _EditExerciseScreenState();
}

class _EditExerciseScreenState extends ConsumerState<EditExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techniqueNotesController = TextEditingController();
  final _equipmentController = TextEditingController();

  MuscleGroup? _selectedPrimaryMuscle;
  List<MuscleGroup> _selectedSecondaryMuscles = [];
  ExerciseDifficulty _selectedDifficulty = ExerciseDifficulty.beginner;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPrimaryMuscle = widget.initialMuscleGroup;
    if (widget.exerciseId != null) {
      _loadExercise();
    }
  }

  Future<void> _loadExercise() async {
    if (widget.exerciseId == null) return;

    final exerciseAsync = ref.read(exerciseByIdProvider(widget.exerciseId!));
    exerciseAsync.whenData((exercise) {
      if (exercise != null && mounted) {
        setState(() {
          _nameController.text = exercise.name;
          _descriptionController.text = exercise.description ?? '';
          _techniqueNotesController.text = exercise.techniqueNotes ?? '';
          _equipmentController.text = exercise.equipment;
          _selectedPrimaryMuscle = exercise.primaryMuscleGroup;
          _selectedSecondaryMuscles = List.from(exercise.secondaryMuscleGroups);
          _selectedDifficulty = exercise.difficulty;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _techniqueNotesController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPrimaryMuscle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a primary muscle group')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(exerciseRepositoryProvider);
      final now = DateTime.now();

      final exercise = Exercise(
        id: widget.exerciseId ?? 'exercise_${now.millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        primaryMuscleGroup: _selectedPrimaryMuscle!,
        secondaryMuscleGroups: _selectedSecondaryMuscles,
        equipment: _equipmentController.text.trim().isEmpty
            ? 'bodyweight'
            : _equipmentController.text.trim(),
        difficulty: _selectedDifficulty,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        techniqueNotes: _techniqueNotesController.text.trim().isEmpty
            ? null
            : _techniqueNotesController.text.trim(),
        isBuiltIn: false,
        createdAt: widget.exerciseId != null
            ? (await repo.getById(widget.exerciseId!))?.createdAt ?? now
            : now,
        updatedAt: now,
      );

      await repo.addOrUpdate(exercise);
      ref.invalidate(exercisesProvider);
      ref.invalidate(exercisesByMuscleGroupProvider(_selectedPrimaryMuscle!));

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.exerciseId == null ? 'Exercise added' : 'Exercise updated')),
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

  Future<void> _deleteExercise() async {
    if (widget.exerciseId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exercise'),
        content: const Text('Are you sure you want to delete this exercise?'),
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
      final repo = ref.read(exerciseRepositoryProvider);
      final exercise = await repo.getById(widget.exerciseId!);
      if (exercise != null) {
        await repo.delete(widget.exerciseId!);
        ref.invalidate(exercisesProvider);
        ref.invalidate(exercisesByMuscleGroupProvider(exercise.primaryMuscleGroup));

        if (mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exercise deleted')),
          );
        }
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
    final isEditing = widget.exerciseId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Exercise' : 'New Exercise'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _isLoading ? null : _deleteExercise,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an exercise name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Primary muscle group
                  DropdownButtonFormField<MuscleGroup>(
                    value: _selectedPrimaryMuscle,
                    decoration: const InputDecoration(
                      labelText: 'Primary Muscle Group *',
                      border: OutlineInputBorder(),
                    ),
                    items: MuscleGroup.values.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPrimaryMuscle = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a primary muscle group';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Secondary muscle groups
                  MultiSelectChip(
                    label: 'Secondary Muscle Groups',
                    options: MuscleGroup.values,
                    selected: _selectedSecondaryMuscles,
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedSecondaryMuscles = selected;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Equipment
                  TextFormField(
                    controller: _equipmentController,
                    decoration: const InputDecoration(
                      labelText: 'Equipment',
                      hintText: 'e.g., bodyweight, dumbbell, barbell',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty
                  DropdownButtonFormField<ExerciseDifficulty>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty',
                      border: OutlineInputBorder(),
                    ),
                    items: ExerciseDifficulty.values.map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.displayName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedDifficulty = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // Technique notes
                  TextFormField(
                    controller: _techniqueNotesController,
                    decoration: const InputDecoration(
                      labelText: 'Technique Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  ElevatedButton(
                    onPressed: _saveExercise,
                    child: const Text('Save Exercise'),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Multi-select chip widget for secondary muscle groups
class MultiSelectChip extends StatelessWidget {
  final String label;
  final List<MuscleGroup> options;
  final List<MuscleGroup> selected;
  final Function(List<MuscleGroup>) onSelectionChanged;

  const MultiSelectChip({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((group) {
            final isSelected = selected.contains(group);
            return FilterChip(
              label: Text(group.displayName),
              selected: isSelected,
              onSelected: (selected) {
                final newSelection = List<MuscleGroup>.from(this.selected);
                if (selected) {
                  if (!newSelection.contains(group)) {
                    newSelection.add(group);
                  }
                } else {
                  newSelection.remove(group);
                }
                onSelectionChanged(newSelection);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

