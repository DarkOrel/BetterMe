import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/muscle_group.dart';

/// Main body/muscle map screen - entry point of the app
class BodyScreen extends ConsumerWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.fitness_center),
            tooltip: 'My Workouts',
            onPressed: () => context.push('/workouts'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Body illustration placeholder
            _BodyIllustration(
              onMuscleGroupTap: (group) {
                context.push('/exercises/${group.name}');
              },
            ),
            const SizedBox(height: 24),
            // Muscle groups grid
            _MuscleGroupsGrid(
              onMuscleGroupTap: (group) {
                context.push('/exercises/${group.name}');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Body illustration widget with tappable areas
class _BodyIllustration extends StatelessWidget {
  final Function(MuscleGroup) onMuscleGroupTap;

  const _BodyIllustration({required this.onMuscleGroupTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Simple body shape using CustomPaint
          Center(
            child: CustomPaint(
              size: const Size(200, 350),
              painter: _BodyPainter(),
            ),
          ),
          // Tappable areas (simplified - using positioned buttons)
          // In a real implementation, you'd use GestureDetector with precise coordinates
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Chest',
                onTap: () => onMuscleGroupTap(MuscleGroup.chest),
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Shoulders',
                onTap: () => onMuscleGroupTap(MuscleGroup.shoulders),
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Back',
                onTap: () => onMuscleGroupTap(MuscleGroup.back),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: 20,
            child: _TappableArea(
              label: 'Biceps',
              onTap: () => onMuscleGroupTap(MuscleGroup.biceps),
            ),
          ),
          Positioned(
            top: 120,
            right: 20,
            child: _TappableArea(
              label: 'Triceps',
              onTap: () => onMuscleGroupTap(MuscleGroup.triceps),
            ),
          ),
          Positioned(
            top: 180,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Abs',
                onTap: () => onMuscleGroupTap(MuscleGroup.abs),
              ),
            ),
          ),
          Positioned(
            top: 220,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Glutes',
                onTap: () => onMuscleGroupTap(MuscleGroup.glutes),
              ),
            ),
          ),
          Positioned(
            top: 260,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Quads',
                onTap: () => onMuscleGroupTap(MuscleGroup.quads),
              ),
            ),
          ),
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Hamstrings',
                onTap: () => onMuscleGroupTap(MuscleGroup.hamstrings),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: _TappableArea(
                label: 'Calves',
                onTap: () => onMuscleGroupTap(MuscleGroup.calves),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple body painter for illustration
class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    // Head
    path.addOval(Rect.fromCircle(center: Offset(size.width / 2, 30), radius: 20));
    // Torso
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 40, 50, 80, 120),
      const Radius.circular(10),
    ));
    // Arms
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 60, 60, 20, 80),
      const Radius.circular(10),
    ));
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 + 40, 60, 20, 80),
      const Radius.circular(10),
    ));
    // Legs
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 - 30, 170, 25, 100),
      const Radius.circular(10),
    ));
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width / 2 + 5, 170, 25, 100),
      const Radius.circular(10),
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Tappable area widget
class _TappableArea extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TappableArea({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
              ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Muscle groups grid
class _MuscleGroupsGrid extends StatelessWidget {
  final Function(MuscleGroup) onMuscleGroupTap;

  const _MuscleGroupsGrid({required this.onMuscleGroupTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Muscle Groups',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: MuscleGroup.values.length,
          itemBuilder: (context, index) {
            final group = MuscleGroup.values[index];
            return Card(
              child: InkWell(
                onTap: () => onMuscleGroupTap(group),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    group.displayName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

