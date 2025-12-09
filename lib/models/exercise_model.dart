/// Exercise model representing a single exercise in a workout
class ExerciseModel {
  final String id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String? tips;
  final String? demoVideoUrl;
  final int sets;
  final int reps;
  final double? weight; // in kg
  final int? rpe; // Rate of Perceived Exertion (1-10)
  final String? notes;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.tips,
    this.demoVideoUrl,
    required this.sets,
    required this.reps,
    this.weight,
    this.rpe,
    this.notes,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle,
      'secondaryMuscles': secondaryMuscles,
      'tips': tips,
      'demoVideoUrl': demoVideoUrl,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscle: json['primaryMuscle'] as String,
      secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tips: json['tips'] as String?,
      demoVideoUrl: json['demoVideoUrl'] as String?,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      rpe: json['rpe'] as int?,
      notes: json['notes'] as String?,
    );
  }

  /// Create a copy with updated fields
  ExerciseModel copyWith({
    String? id,
    String? name,
    String? primaryMuscle,
    List<String>? secondaryMuscles,
    String? tips,
    String? demoVideoUrl,
    int? sets,
    int? reps,
    double? weight,
    int? rpe,
    String? notes,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      tips: tips ?? this.tips,
      demoVideoUrl: demoVideoUrl ?? this.demoVideoUrl,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rpe: rpe ?? this.rpe,
      notes: notes ?? this.notes,
    );
  }
}




