/// Set model representing a single set of an exercise
class SetModel {
  final String id;
  final int setNumber;
  final int reps;
  final double? weight; // in kg
  final int? rpe; // Rate of Perceived Exertion (1-10)
  final bool completed;
  final String? notes;

  SetModel({
    required this.id,
    required this.setNumber,
    required this.reps,
    this.weight,
    this.rpe,
    this.completed = false,
    this.notes,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'setNumber': setNumber,
      'reps': reps,
      'weight': weight,
      'rpe': rpe,
      'completed': completed,
      'notes': notes,
    };
  }

  /// Create from JSON
  factory SetModel.fromJson(Map<String, dynamic> json) {
    return SetModel(
      id: json['id'] as String,
      setNumber: json['setNumber'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      rpe: json['rpe'] as int?,
      completed: json['completed'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  /// Create a copy with updated fields
  SetModel copyWith({
    String? id,
    int? setNumber,
    int? reps,
    double? weight,
    int? rpe,
    bool? completed,
    String? notes,
  }) {
    return SetModel(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      rpe: rpe ?? this.rpe,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }
}




