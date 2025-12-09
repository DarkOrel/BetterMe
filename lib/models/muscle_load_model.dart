/// Muscle load model representing weekly training volume for a muscle group
class MuscleLoadModel {
  final String muscleGroup;
  final int weeklySets;
  final int weeklyReps;
  final double weeklyVolume; // total weight × reps
  final DateTime weekStart;
  final DateTime weekEnd;

  MuscleLoadModel({
    required this.muscleGroup,
    required this.weeklySets,
    required this.weeklyReps,
    required this.weeklyVolume,
    required this.weekStart,
    required this.weekEnd,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'muscleGroup': muscleGroup,
      'weeklySets': weeklySets,
      'weeklyReps': weeklyReps,
      'weeklyVolume': weeklyVolume,
      'weekStart': weekStart.toIso8601String(),
      'weekEnd': weekEnd.toIso8601String(),
    };
  }

  /// Create from JSON
  factory MuscleLoadModel.fromJson(Map<String, dynamic> json) {
    return MuscleLoadModel(
      muscleGroup: json['muscleGroup'] as String,
      weeklySets: json['weeklySets'] as int,
      weeklyReps: json['weeklyReps'] as int,
      weeklyVolume: (json['weeklyVolume'] as num).toDouble(),
      weekStart: DateTime.parse(json['weekStart'] as String),
      weekEnd: DateTime.parse(json['weekEnd'] as String),
    );
  }

  /// Get load level: 'high', 'medium', 'low'
  String get loadLevel {
    if (weeklySets >= 20) return 'high';
    if (weeklySets >= 12) return 'medium';
    return 'low';
  }

  /// Get color based on load level
  String get colorCode {
    switch (loadLevel) {
      case 'high':
        return 'green';
      case 'medium':
        return 'yellow';
      case 'low':
        return 'blue';
      default:
        return 'blue';
    }
  }
}




