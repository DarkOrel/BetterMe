/// Weekly PPL program model
class WeeklyProgram {
  final String id;
  final String userId;
  final DateTime weekStart;
  final DateTime weekEnd;
  final List<WorkoutDay> workoutDays;

  WeeklyProgram({
    required this.id,
    required this.userId,
    required this.weekStart,
    required this.weekEnd,
    required this.workoutDays,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
      'workoutDays': workoutDays.map((d) => d.toJson()).toList(),
    };
  }

  factory WeeklyProgram.fromJson(Map<String, dynamic> json) {
    return WeeklyProgram(
      id: json['id'] as String,
      userId: json['userId'] as String,
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
      workoutDays: (json['workoutDays'] as List<dynamic>)
          .map((d) => WorkoutDay.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Workout day in weekly program
class WorkoutDay {
  final DateTime date;
  final String workoutType; // 'Push', 'Pull', 'Legs', 'Rest'
  final List<WorkoutExercise> exercises;

  WorkoutDay({
    required this.date,
    required this.workoutType,
    required this.exercises,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'workoutType': workoutType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      date: DateTime.parse(json['date'] as String),
      workoutType: json['workoutType'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Exercise in a workout (references Exercise template)
class WorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final List<SetLog> sets;
  final String? notes;

  WorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.sets,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'primaryMuscle': primaryMuscle,
      'secondaryMuscles': secondaryMuscles,
      'sets': sets.map((s) => s.toJson()).toList(),
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sets: (json['sets'] as List<dynamic>)
          .map((s) => SetLog.fromJson(s as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}

/// Set log with individual set data
class SetLog {
  final int setIndex;
  final int reps;
  final double? weight; // in kg
  final int? rpe; // Rate of Perceived Exertion (1-10)
  final bool completed;

  SetLog({
    required this.setIndex,
    required this.reps,
    this.weight,
    this.rpe,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'setIndex': setIndex,
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      'completed': completed,
    };
  }

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      setIndex: json['setIndex'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      rpe: json['rpe'] as int?,
      completed: json['completed'] as bool? ?? false,
    );
  }

  SetLog copyWith({
    int? setIndex,
    int? reps,
    double? weight,
    int? rpe,
    bool? completed,
  }) {
    return SetLog(
      setIndex: setIndex ?? this.setIndex,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rpe: rpe ?? this.rpe,
      completed: completed ?? this.completed,
    );
  }
}


