import '../models/weekly_program_model.dart';
import '../models/muscle_load_model.dart';
import '../core/constants/app_constants.dart';

/// Service for calculating muscle load from workout data
class MuscleLoadCalculatorService {
  /// Calculate muscle load for all muscle groups from a weekly program
  Map<String, MuscleLoadModel> calculateWeeklyLoad(
    WeeklyProgram program,
    DateTime weekStart,
  ) {
    final muscleLoads = <String, MuscleLoadModel>{};

    // Initialize all muscle groups
    for (final muscleGroup in AppConstants.muscleGroups) {
      muscleLoads[muscleGroup] = MuscleLoadModel(
        muscleGroup: muscleGroup,
        weeklySets: 0,
        weeklyReps: 0,
        weeklyVolume: 0.0,
        weekStart: weekStart,
        weekEnd: weekStart.add(const Duration(days: 6)),
      );
    }

    // Process each workout day
    for (final workoutDay in program.workoutDays) {
      if (workoutDay.workoutType == 'Rest') continue;

      for (final exercise in workoutDay.exercises) {
        final primaryMuscle = exercise.primaryMuscle;
        final secondaryMuscles = exercise.secondaryMuscles;

        // Count sets and reps
        int totalReps = 0;
        double totalVolume = 0.0;

        for (final set in exercise.sets) {
          if (set.completed) {
            totalReps += set.reps;
            totalVolume += (set.weight ?? 0.0) * set.reps;
          }
        }

        // Add to primary muscle
        if (muscleLoads.containsKey(primaryMuscle)) {
          final current = muscleLoads[primaryMuscle]!;
          muscleLoads[primaryMuscle] = MuscleLoadModel(
            muscleGroup: primaryMuscle,
            weeklySets: current.weeklySets + exercise.sets.length,
            weeklyReps: current.weeklyReps + totalReps,
            weeklyVolume: current.weeklyVolume + totalVolume,
            weekStart: current.weekStart,
            weekEnd: current.weekEnd,
          );
        }

        // Add to secondary muscles (50% contribution)
        for (final secondary in secondaryMuscles) {
          if (muscleLoads.containsKey(secondary)) {
            final current = muscleLoads[secondary]!;
            muscleLoads[secondary] = MuscleLoadModel(
              muscleGroup: secondary,
              weeklySets: current.weeklySets + (exercise.sets.length ~/ 2),
              weeklyReps: current.weeklyReps + (totalReps ~/ 2),
              weeklyVolume: current.weeklyVolume + (totalVolume * 0.5),
              weekStart: current.weekStart,
              weekEnd: current.weekEnd,
            );
          }
        }
      }
    }

    return muscleLoads;
  }

  /// Get load level for a muscle group
  String getLoadLevel(int weeklySets) {
    if (weeklySets >= 20) return 'high';
    if (weeklySets >= 12) return 'medium';
    return 'low';
  }

  /// Get color code for muscle map visualization
  String getColorCode(int weeklySets) {
    final level = getLoadLevel(weeklySets);
    switch (level) {
      case 'high':
        return 'green';
      case 'medium':
        return 'yellow';
      case 'low':
      default:
        return 'blue';
    }
  }
}

