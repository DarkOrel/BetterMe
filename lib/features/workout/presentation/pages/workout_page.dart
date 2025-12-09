import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/workout_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../models/workout_model.dart';

/// Workout page displaying and managing workouts
class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  String? _selectedWorkoutType;

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout'),
      ),
      body: workoutState.when(
        data: (workout) {
          if (workout == null) {
            return _WorkoutSelectionView(
              onWorkoutTypeSelected: (type) async {
                setState(() => _selectedWorkoutType = type);
                final notifier = ref.read(workoutStateProvider.notifier);
                await notifier.generateWorkout(type);
              },
              selectedType: _selectedWorkoutType,
            );
          }

          return _WorkoutDetailView(workout: workout);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(workoutStateProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutSelectionView extends StatelessWidget {
  final Function(String) onWorkoutTypeSelected;
  final String? selectedType;

  const _WorkoutSelectionView({
    required this.onWorkoutTypeSelected,
    this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Select Workout Type',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          _WorkoutTypeCard(
            type: AppConstants.pushWorkout,
            description: 'Chest, Shoulders, Triceps',
            color: Colors.blue,
            isSelected: selectedType == AppConstants.pushWorkout,
            onTap: () => onWorkoutTypeSelected(AppConstants.pushWorkout),
          ),
          const SizedBox(height: 16),
          _WorkoutTypeCard(
            type: AppConstants.pullWorkout,
            description: 'Back, Biceps, Rear Delts',
            color: Colors.green,
            isSelected: selectedType == AppConstants.pullWorkout,
            onTap: () => onWorkoutTypeSelected(AppConstants.pullWorkout),
          ),
          const SizedBox(height: 16),
          _WorkoutTypeCard(
            type: AppConstants.legsWorkout,
            description: 'Quads, Hamstrings, Glutes, Calves',
            color: Colors.purple,
            isSelected: selectedType == AppConstants.legsWorkout,
            onTap: () => onWorkoutTypeSelected(AppConstants.legsWorkout),
          ),
        ],
      ),
    );
  }
}

class _WorkoutTypeCard extends StatelessWidget {
  final String type;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _WorkoutTypeCard({
    required this.type,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type[0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutDetailView extends ConsumerWidget {
  final WorkoutModel workout;

  const _WorkoutDetailView({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Workout header
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.workoutType,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('${workout.exercises.length} exercises'),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  final notifier = ref.read(workoutStateProvider.notifier);
                  await notifier.saveWorkout(workout);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Workout saved!')),
                    );
                  }
                },
                child: const Text('Save Workout'),
              ),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workout.exercises.length,
            itemBuilder: (context, index) {
              final exercise = workout.exercises[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(
                    '${exercise.sets} sets × ${exercise.reps} reps\n${exercise.primaryMuscle}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () {
                      context.push('/workout/exercise/${exercise.id}');
                    },
                  ),
                  onTap: () {
                    context.push('/workout/exercise/${exercise.id}');
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}




