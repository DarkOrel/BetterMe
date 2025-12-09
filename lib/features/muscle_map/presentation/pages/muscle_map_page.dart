import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/muscle_load_provider.dart';
import '../../../../core/constants/app_constants.dart';

/// Muscle map page showing 2D body model with muscle group training volume
class MuscleMapPage extends ConsumerWidget {
  const MuscleMapPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muscleLoads = ref.watch(muscleLoadProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Map'),
      ),
      body: SafeArea(
        child: muscleLoads.when(
          data: (loads) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Legend
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        alignment: WrapAlignment.center,
                        children: [
                          _LegendItem(color: Colors.green, label: 'High Volume'),
                          _LegendItem(color: Colors.yellow, label: 'Medium Volume'),
                          _LegendItem(color: Colors.blue, label: 'Low Volume'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Body model placeholder
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '2D Body Model',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: 200,
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text('Body SVG/PNG\nwill be displayed here'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Click on muscle groups to see details'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Muscle group list
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muscle Groups',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: AppConstants.muscleGroups.length,
                            itemBuilder: (context, index) {
                              final muscle = AppConstants.muscleGroups[index];
                              final load = loads[muscle];
                              final color = _getColorForLoad(load?.loadLevel ?? 'low');

                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  label: Text(muscle),
                                  backgroundColor: color,
                                  onDeleted: load != null
                                      ? () {
                                          // Show details
                                        }
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }

  Color _getColorForLoad(String level) {
    switch (level) {
      case 'high':
        return Colors.green.shade200;
      case 'medium':
        return Colors.yellow.shade200;
      case 'low':
        return Colors.blue.shade200;
      default:
        return Colors.grey.shade200;
    }
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}




