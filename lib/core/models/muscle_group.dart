/// Muscle group enum for categorizing exercises
enum MuscleGroup {
  chest('Chest'),
  shoulders('Shoulders'),
  back('Back'),
  biceps('Biceps'),
  triceps('Triceps'),
  abs('Abs / Core'),
  glutes('Glutes'),
  quads('Quadriceps'),
  hamstrings('Hamstrings'),
  calves('Calves');

  final String displayName;
  const MuscleGroup(this.displayName);

  static MuscleGroup? fromString(String value) {
    try {
      return MuscleGroup.values.firstWhere(
        (e) => e.name == value.toLowerCase() || e.displayName.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

