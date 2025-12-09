import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

/// Service for calculating nutrition targets (BMR, TDEE, macros)
class NutritionCalculatorService {
  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  double calculateBMR(UserModel user) {
    // Men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
    // Women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161

    final baseBMR = 10 * user.weight + 6.25 * user.height - 5 * user.age;

    if (user.gender == AppConstants.male) {
      return baseBMR + 5;
    } else {
      return baseBMR - 161;
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  double calculateTDEE(UserModel user) {
    final bmr = calculateBMR(user);
    
    // Activity multipliers based on workouts per week
    double activityMultiplier;
    switch (user.workoutsPerWeek) {
      case 2:
        activityMultiplier = 1.375; // Lightly active
        break;
      case 3:
        activityMultiplier = 1.55; // Moderately active
        break;
      case 4:
        activityMultiplier = 1.725; // Very active
        break;
      case 5:
      case 6:
        activityMultiplier = 1.9; // Extremely active
        break;
      default:
        activityMultiplier = 1.2; // Sedentary
    }

    return bmr * activityMultiplier;
  }

  /// Calculate daily calorie target based on goal
  double calculateCalorieTarget(UserModel user) {
    final tdee = calculateTDEE(user);

    switch (user.goal) {
      case AppConstants.muscleGain:
        // Bulk: +300-500 calories
        return tdee + 400;
      case AppConstants.fatLoss:
        // Cut: -500 calories (1 lb/week)
        return tdee - 500;
      case AppConstants.maintain:
      default:
        return tdee;
    }
  }

  /// Calculate protein target (grams per day)
  double calculateProteinTarget(UserModel user) {
    // General recommendation: 1.6-2.2g per kg bodyweight
    // Higher for muscle gain, moderate for fat loss
    double proteinPerKg;

    switch (user.goal) {
      case AppConstants.muscleGain:
        proteinPerKg = 2.0; // Higher for muscle building
        break;
      case AppConstants.fatLoss:
        proteinPerKg = 2.2; // Higher to preserve muscle during cut
        break;
      case AppConstants.maintain:
      default:
        proteinPerKg = 1.8;
    }

    return user.weight * proteinPerKg;
  }

  /// Calculate fat target (grams per day)
  double calculateFatTarget(UserModel user) {
    // General recommendation: 0.8-1.2g per kg bodyweight
    // Or 20-30% of total calories
    final calorieTarget = calculateCalorieTarget(user);
    final fatCalories = calorieTarget * 0.25; // 25% from fat
    return fatCalories / 9; // 9 calories per gram of fat
  }

  /// Calculate carbs target (grams per day)
  double calculateCarbsTarget(UserModel user) {
    final calorieTarget = calculateCalorieTarget(user);
    final proteinTarget = calculateProteinTarget(user);
    final fatTarget = calculateFatTarget(user);

    // Remaining calories go to carbs
    final proteinCalories = proteinTarget * 4; // 4 calories per gram
    final fatCalories = fatTarget * 9; // 9 calories per gram
    final carbCalories = calorieTarget - proteinCalories - fatCalories;

    return carbCalories / 4; // 4 calories per gram of carbs
  }

  /// Get all nutrition targets
  Map<String, double> getAllTargets(UserModel user) {
    return {
      'bmr': calculateBMR(user),
      'tdee': calculateTDEE(user),
      'calories': calculateCalorieTarget(user),
      'protein': calculateProteinTarget(user),
      'carbs': calculateCarbsTarget(user),
      'fat': calculateFatTarget(user),
    };
  }
}


