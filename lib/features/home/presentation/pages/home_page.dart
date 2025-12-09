import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/user_provider.dart';
import '../../../../providers/workout_provider.dart';
import '../../../../providers/nutrition_provider.dart';
import '../../../../core/constants/app_constants.dart';

/// Home screen displaying today's workout, stats, and quick actions
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final todaysWorkoutAsync = ref.watch(todaysWorkoutProvider);
    final nutritionStats = ref.watch(nutritionStatsProvider);
    
    final userProfile = userProfileAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting
            Text(
              'Hello, ${userProfile?.uid.substring(0, 8) ?? "User"}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),

            // Today's Workout Card
            todaysWorkoutAsync.when(
              data: (workout) => _TodaysWorkoutCard(workout: workout),
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading workout: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quick Stats
            Text(
              'Today\'s Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Calories',
                    value: '${nutritionStats['calories']!.toInt()}',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Protein',
                    value: '${nutritionStats['protein']!.toInt()}g',
                    icon: Icons.fitness_center,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Steps',
                    value: '0',
                    icon: Icons.directions_walk,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: todaysWorkoutAsync.when(
                    data: (workout) => _StatCard(
                      label: 'Workouts',
                      value: workout != null ? '1' : '0',
                      icon: Icons.sports_gymnastics,
                      color: Colors.purple,
                    ),
                    loading: () => _StatCard(
                      label: 'Workouts',
                      value: '0',
                      icon: Icons.sports_gymnastics,
                      color: Colors.purple,
                    ),
                    error: (_, __) => _StatCard(
                      label: 'Workouts',
                      value: '0',
                      icon: Icons.sports_gymnastics,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _QuickActionCard(
                  label: 'Start Workout',
                  icon: Icons.play_circle_filled,
                  color: Colors.blue,
                  onTap: () => context.push('/workout'),
                ),
                _QuickActionCard(
                  label: 'Muscle Map',
                  icon: Icons.accessibility_new,
                  color: Colors.green,
                  onTap: () => context.push('/muscle-map'),
                ),
                _QuickActionCard(
                  label: 'Scan Food',
                  icon: Icons.qr_code_scanner,
                  color: Colors.orange,
                  onTap: () => context.push('/nutrition/barcode'),
                ),
                _QuickActionCard(
                  label: 'Log Meal',
                  icon: Icons.restaurant,
                  color: Colors.purple,
                  onTap: () => context.push('/nutrition/log'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Section
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: () => context.push('/progress'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.blue, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'View Progress',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Track your weight, volume, and PRs',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysWorkoutCard extends StatelessWidget {
  final dynamic workout;

  const _TodaysWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    if (workout == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Workout',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('No workout scheduled for today'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.push('/workout'),
                child: const Text('Generate Workout'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Workout',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Chip(
                  label: Text(workout.workoutType),
                  backgroundColor: _getWorkoutColor(workout.workoutType),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('${workout.exercises.length} exercises'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.push('/workout'),
              child: const Text('Start Workout'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getWorkoutColor(String type) {
    switch (type) {
      case AppConstants.pushWorkout:
        return Colors.blue.shade100;
      case AppConstants.pullWorkout:
        return Colors.green.shade100;
      case AppConstants.legsWorkout:
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade100;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

