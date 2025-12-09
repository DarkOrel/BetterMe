import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/weekly_program_model.dart';
import '../core/constants/app_constants.dart';

/// Service for generating PPL workout programs
class PPLGeneratorService {
  /// Generate a weekly PPL program based on user profile
  WeeklyProgram generateWeeklyProgram({
    required UserModel user,
    required DateTime weekStart,
  }) {
    debugPrint('Generating PPL program for ${user.workoutsPerWeek} days/week');

    final weekEnd = weekStart.add(const Duration(days: 6));
    final workoutDays = <WorkoutDay>[];

    // Generate workout schedule based on days per week
    final schedule = _generateSchedule(user.workoutsPerWeek);

    for (var i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final workoutType = schedule[i];

      if (workoutType == 'Rest') {
        workoutDays.add(WorkoutDay(
          date: date,
          workoutType: 'Rest',
          exercises: [],
        ));
      } else {
        final exercises = _generateExercisesForType(
          workoutType,
          user.experienceLevel,
          user.goal,
        );

        workoutDays.add(WorkoutDay(
          date: date,
          workoutType: workoutType,
          exercises: exercises,
        ));
      }
    }

    return WeeklyProgram(
      id: 'program_${weekStart.millisecondsSinceEpoch}',
      userId: user.uid,
      weekStart: weekStart,
      weekEnd: weekEnd,
      workoutDays: workoutDays,
    );
  }

  /// Generate schedule array (7 days)
  List<String> _generateSchedule(int workoutsPerWeek) {
    final schedule = List<String>.filled(7, 'Rest');

    switch (workoutsPerWeek) {
      case 2:
        schedule[0] = AppConstants.pushWorkout;
        schedule[3] = AppConstants.pullWorkout;
        break;
      case 3:
        schedule[0] = AppConstants.pushWorkout;
        schedule[2] = AppConstants.pullWorkout;
        schedule[4] = AppConstants.legsWorkout;
        break;
      case 4:
        schedule[0] = AppConstants.pushWorkout;
        schedule[1] = AppConstants.pullWorkout;
        schedule[3] = AppConstants.legsWorkout;
        schedule[4] = AppConstants.pushWorkout;
        break;
      case 5:
        schedule[0] = AppConstants.pushWorkout;
        schedule[1] = AppConstants.pullWorkout;
        schedule[2] = AppConstants.legsWorkout;
        schedule[4] = AppConstants.pushWorkout;
        schedule[5] = AppConstants.pullWorkout;
        break;
      case 6:
        schedule[0] = AppConstants.pushWorkout;
        schedule[1] = AppConstants.pullWorkout;
        schedule[2] = AppConstants.legsWorkout;
        schedule[3] = AppConstants.pushWorkout;
        schedule[4] = AppConstants.pullWorkout;
        schedule[5] = AppConstants.legsWorkout;
        break;
    }

    return schedule;
  }

  /// Generate exercises for a workout type
  List<WorkoutExercise> _generateExercisesForType(
    String workoutType,
    String experienceLevel,
    String goal,
  ) {
    final exercises = <WorkoutExercise>[];

    switch (workoutType) {
      case AppConstants.pushWorkout:
        exercises.addAll(_getPushExercises(experienceLevel, goal));
        break;
      case AppConstants.pullWorkout:
        exercises.addAll(_getPullExercises(experienceLevel, goal));
        break;
      case AppConstants.legsWorkout:
        exercises.addAll(_getLegsExercises(experienceLevel, goal));
        break;
    }

    return exercises;
  }

  List<WorkoutExercise> _getPushExercises(String experienceLevel, String goal) {
    final baseExercises = [
      WorkoutExercise(
        exerciseId: 'bench_press',
        exerciseName: 'Bench Press',
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Shoulders', 'Triceps'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'overhead_press',
        exerciseName: 'Overhead Press',
        primaryMuscle: 'Shoulders',
        secondaryMuscles: ['Triceps'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'tricep_dips',
        exerciseName: 'Tricep Dips',
        primaryMuscle: 'Triceps',
        secondaryMuscles: ['Shoulders'],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      ),
    ];

    if (experienceLevel != AppConstants.beginner) {
      baseExercises.add(
        WorkoutExercise(
          exerciseId: 'incline_bench',
          exerciseName: 'Incline Bench Press',
          primaryMuscle: 'Chest',
          secondaryMuscles: ['Shoulders'],
          sets: _getSetsForLevel(experienceLevel, isAccessory: true),
        ),
      );
    }

    return baseExercises;
  }

  List<WorkoutExercise> _getPullExercises(String experienceLevel, String goal) {
    final baseExercises = [
      WorkoutExercise(
        exerciseId: 'deadlift',
        exerciseName: 'Deadlift',
        primaryMuscle: 'Back',
        secondaryMuscles: ['Hamstrings', 'Glutes'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'pull_ups',
        exerciseName: 'Pull-ups',
        primaryMuscle: 'Back',
        secondaryMuscles: ['Biceps'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'barbell_rows',
        exerciseName: 'Barbell Rows',
        primaryMuscle: 'Back',
        secondaryMuscles: ['Biceps'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'bicep_curls',
        exerciseName: 'Bicep Curls',
        primaryMuscle: 'Biceps',
        secondaryMuscles: [],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      ),
    ];

    return baseExercises;
  }

  List<WorkoutExercise> _getLegsExercises(String experienceLevel, String goal) {
    final baseExercises = [
      WorkoutExercise(
        exerciseId: 'squat',
        exerciseName: 'Squat',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'romanian_deadlift',
        exerciseName: 'Romanian Deadlift',
        primaryMuscle: 'Hamstrings',
        secondaryMuscles: ['Glutes'],
        sets: _getSetsForLevel(experienceLevel),
      ),
      WorkoutExercise(
        exerciseId: 'leg_press',
        exerciseName: 'Leg Press',
        primaryMuscle: 'Quadriceps',
        secondaryMuscles: ['Glutes'],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      ),
      WorkoutExercise(
        exerciseId: 'calf_raises',
        exerciseName: 'Calf Raises',
        primaryMuscle: 'Calves',
        secondaryMuscles: [],
        sets: _getSetsForLevel(experienceLevel, isAccessory: true),
      ),
    ];

    return baseExercises;
  }

  List<SetLog> _getSetsForLevel(String experienceLevel, {bool isAccessory = false}) {
    int numSets;
    int reps;

    if (isAccessory) {
      numSets = experienceLevel == AppConstants.beginner ? 2 : 3;
      reps = 10;
    } else {
      switch (experienceLevel) {
        case AppConstants.beginner:
          numSets = 3;
          reps = 8;
          break;
        case AppConstants.intermediate:
          numSets = 4;
          reps = 8;
          break;
        case AppConstants.advanced:
          numSets = 4;
          reps = 6;
          break;
        default:
          numSets = 3;
          reps = 8;
      }
    }

    return List.generate(numSets, (index) {
      return SetLog(
        setIndex: index + 1,
        reps: reps,
        weight: null, // User will log weight during workout
        rpe: null,
        completed: false,
      );
    });
  }
}


