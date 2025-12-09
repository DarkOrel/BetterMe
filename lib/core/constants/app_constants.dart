/// Application-wide constants
class AppConstants {
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String workoutHistoryCollection = 'workout_history';
  static const String nutritionCollection = 'nutrition';
  static const String muscleLoadCollection = 'muscle_load';

  // Storage paths
  static const String foodImagesPath = 'food_images';
  static const String profileImagesPath = 'profile_images';

  // Muscle groups
  static const List<String> muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Forearms',
    'Quadriceps',
    'Hamstrings',
    'Glutes',
    'Calves',
    'Abs',
    'Traps',
    'Lats',
  ];

  // Workout types
  static const String pushWorkout = 'Push';
  static const String pullWorkout = 'Pull';
  static const String legsWorkout = 'Legs';

  // Experience levels
  static const String beginner = 'beginner';
  static const String intermediate = 'intermediate';
  static const String advanced = 'advanced';

  // Goals
  static const String muscleGain = 'muscle_gain';
  static const String fatLoss = 'fat_loss';
  static const String maintain = 'maintain';

  // Gender
  static const String male = 'male';
  static const String female = 'female';

  // API endpoints (for OpenFoodFacts)
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v0';
}




