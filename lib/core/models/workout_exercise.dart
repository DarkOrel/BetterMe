/// Exercise within a workout template
class WorkoutExercise {
  final String exerciseId; // Reference to Exercise.id
  final int targetSets;
  final String targetReps; // e.g., "8-12" or "10"
  final int? targetRestSeconds;

  WorkoutExercise({
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    this.targetRestSeconds,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'targetRestSeconds': targetRestSeconds,
    };
  }

  /// Create from JSON
  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      exerciseId: json['exerciseId'] as String,
      targetSets: json['targetSets'] as int,
      targetReps: json['targetReps'] as String,
      targetRestSeconds: json['targetRestSeconds'] as int?,
    );
  }

  /// Create a copy with updated fields
  WorkoutExercise copyWith({
    String? exerciseId,
    int? targetSets,
    String? targetReps,
    int? targetRestSeconds,
  }) {
    return WorkoutExercise(
      exerciseId: exerciseId ?? this.exerciseId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
    );
  }
}

