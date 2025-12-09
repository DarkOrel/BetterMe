import 'muscle_group.dart';

/// Exercise model representing an exercise in the exercise library
class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final String equipment; // e.g., "bodyweight", "dumbbell", "barbell", "machine"
  final ExerciseDifficulty difficulty;
  final String? description;
  final String? techniqueNotes;
  final bool isBuiltIn; // Built-in exercises cannot be deleted
  final DateTime createdAt;
  final DateTime? updatedAt;

  Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscleGroup,
    this.secondaryMuscleGroups = const [],
    required this.equipment,
    required this.difficulty,
    this.description,
    this.techniqueNotes,
    this.isBuiltIn = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON for Hive storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryMuscleGroup': primaryMuscleGroup.name,
      'secondaryMuscleGroups': secondaryMuscleGroups.map((e) => e.name).toList(),
      'equipment': equipment,
      'difficulty': difficulty.name,
      'description': description,
      'techniqueNotes': techniqueNotes,
      'isBuiltIn': isBuiltIn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      primaryMuscleGroup: MuscleGroup.values.firstWhere(
        (e) => e.name == json['primaryMuscleGroup'],
        orElse: () => MuscleGroup.chest,
      ),
      secondaryMuscleGroups: (json['secondaryMuscleGroups'] as List<dynamic>?)
              ?.map((e) => MuscleGroup.values.firstWhere(
                    (mg) => mg.name == e,
                    orElse: () => MuscleGroup.chest,
                  ))
              .toList() ??
          [],
      equipment: json['equipment'] as String? ?? 'bodyweight',
      difficulty: ExerciseDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => ExerciseDifficulty.beginner,
      ),
      description: json['description'] as String?,
      techniqueNotes: json['techniqueNotes'] as String?,
      isBuiltIn: json['isBuiltIn'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  /// Create a copy with updated fields
  Exercise copyWith({
    String? id,
    String? name,
    MuscleGroup? primaryMuscleGroup,
    List<MuscleGroup>? secondaryMuscleGroups,
    String? equipment,
    ExerciseDifficulty? difficulty,
    String? description,
    String? techniqueNotes,
    bool? isBuiltIn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      equipment: equipment ?? this.equipment,
      difficulty: difficulty ?? this.difficulty,
      description: description ?? this.description,
      techniqueNotes: techniqueNotes ?? this.techniqueNotes,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Exercise difficulty levels
enum ExerciseDifficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  final String displayName;
  const ExerciseDifficulty(this.displayName);
}

