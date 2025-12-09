import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/nutrition_provider.dart';
import '../../../../models/meal_model.dart';

/// Nutrition page displaying meal logs and stats
class NutritionPage extends ConsumerWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(todaysMealsProvider);
    final stats = ref.watch(nutritionStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'barcode':
                  context.push('/nutrition/barcode');
                  break;
                case 'photo':
                  context.push('/nutrition/photo');
                  break;
                case 'manual':
                  context.push('/nutrition/log');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'barcode',
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(width: 8),
                    Text('Scan Barcode'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'photo',
                child: Row(
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(width: 8),
                    Text('Photo Meal'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'manual',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Manual Entry'),
                  ],
                ),
              ),
            ],
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: meals.when(
        data: (mealsList) {
          return Column(
            children: [
              // Stats summary
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(
                      label: 'Calories',
                      value: '${stats['calories']!.toInt()}',
                      target: 2000,
                    ),
                    _StatItem(
                      label: 'Protein',
                      value: '${stats['protein']!.toInt()}g',
                      target: 150,
                    ),
                    _StatItem(
                      label: 'Carbs',
                      value: '${stats['carbs']!.toInt()}g',
                      target: 200,
                    ),
                    _StatItem(
                      label: 'Fat',
                      value: '${stats['fat']!.toInt()}g',
                      target: 65,
                    ),
                  ],
                ),
              ),

              // Meal list
              Expanded(
                child: mealsList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No meals logged today',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => context.push('/nutrition/log'),
                              child: const Text('Log Meal'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: mealsList.length,
                        itemBuilder: (context, index) {
                          final meal = mealsList[index];
                          return _MealCard(meal: meal);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show options dialog
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text('Scan Barcode'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/nutrition/barcode');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Photo Meal'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/nutrition/photo');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Manual Entry'),
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/nutrition/log');
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final int target;

  const _StatItem({
    required this.label,
    required this.value,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          '/ $target',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealModel meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: meal.imageUrl != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(meal.imageUrl!),
              )
            : const CircleAvatar(
                child: Icon(Icons.restaurant),
              ),
        title: Text(meal.foodName),
        subtitle: Text(
          '${meal.calories.toInt()} kcal • ${meal.protein.toInt()}g protein',
        ),
        trailing: Text(
          meal.mealType.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}




