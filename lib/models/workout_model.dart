import 'package:cloud_firestore/cloud_firestore.dart';
import 'exercise_model.dart';

/// Workout model representing a complete workout session
class WorkoutModel {
  final String id;
  final String userId;
  final String workoutType; // 'Push', 'Pull', 'Legs'
  final DateTime date;
  final List<ExerciseModel> exercises;
  final bool completed;
  final Duration? duration;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkoutModel({
    required this.id,
    required this.userId,
    required this.workoutType,
    required this.date,
    required this.exercises,
    this.completed = false,
    this.duration,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON (works for both local storage and Firestore)
  Map<String, dynamic> toJson({bool forFirestore = false}) {
    final json = {
      'id': id,
      'userId': userId,
      'workoutType': workoutType,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'completed': completed,
      'duration': duration?.inMinutes,
      'notes': notes,
    };

    if (forFirestore) {
      json['date'] = Timestamp.fromDate(date);
      json['createdAt'] = Timestamp.fromDate(createdAt);
      json['updatedAt'] = updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;
    } else {
      json['date'] = date.toIso8601String();
      json['createdAt'] = createdAt.toIso8601String();
      json['updatedAt'] = updatedAt?.toIso8601String();
    }

    return json;
  }

  /// Create from JSON (works for both local storage and Firestore)
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is Map && dateValue['_seconds'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(
            (dateValue['_seconds'] as int) * 1000);
      }
      return DateTime.now();
    }

    return WorkoutModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      workoutType: json['workoutType'] as String,
      date: parseDate(json['date']),
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      completed: json['completed'] as bool? ?? false,
      duration: json['duration'] != null
          ? Duration(minutes: json['duration'] as int)
          : null,
      notes: json['notes'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  /// Create a copy with updated fields
  WorkoutModel copyWith({
    String? id,
    String? userId,
    String? workoutType,
    DateTime? date,
    List<ExerciseModel>? exercises,
    bool? completed,
    Duration? duration,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutType: workoutType ?? this.workoutType,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      completed: completed ?? this.completed,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get total sets in workout
  int get totalSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  }

  /// Get total volume (sets × reps × weight)
  double get totalVolume {
    return exercises.fold(0.0, (sum, exercise) {
      final exerciseVolume = exercise.sets *
          exercise.reps *
          (exercise.weight ?? 0.0);
      return sum + exerciseVolume;
    });
  }
}




