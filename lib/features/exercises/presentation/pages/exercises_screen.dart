import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/muscle_group.dart';
import '../../../../providers/exercise_provider.dart';

/// Exercises list screen filtered by muscle group
class ExercisesScreen extends ConsumerStatefulWidget {
  final String muscleGroupName;

  const ExercisesScreen({
    super.key,
    required this.muscleGroupName,
  });

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  MuscleGroup? get _muscleGroup {
    return MuscleGroup.fromString(widget.muscleGroupName);
  }

  @override
  Widget build(BuildContext context) {
    final muscleGroup = _muscleGroup;
    if (muscleGroup == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercises')),
        body: const Center(child: Text('Invalid muscle group')),
      );
    }

    final exercisesAsync = ref.watch(exercisesByMuscleGroupProvider(muscleGroup));

    return Scaffold(
      appBar: AppBar(
        title: Text(muscleGroup.displayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/exercises/new', extra: {'muscleGroup': muscleGroup});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // Exercises list
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = _searchQuery.isEmpty
                    ? exercises
                    : exercises.where((e) => e.name.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No exercises found for ${muscleGroup.displayName}'
                              : 'No exercises match "$_searchQuery"',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.push('/exercises/new', extra: {'muscleGroup': muscleGroup});
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final exercise = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.equipment} • ${exercise.difficulty.displayName}',
                        ),
                        trailing: exercise.isBuiltIn
                            ? const Icon(Icons.lock, size: 16, color: Colors.grey)
                            : const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/exercises/edit/${exercise.id}');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/exercises/new', extra: {'muscleGroup': muscleGroup});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

