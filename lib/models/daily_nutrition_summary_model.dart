/// Daily nutrition summary model
class DailyNutritionSummary {
  final String userId;
  final DateTime date;
  final double totalCalories;
  final double totalProtein; // in grams
  final double totalCarbs; // in grams
  final double totalFat; // in grams
  final double targetCalories;
  final double targetProtein; // in grams
  final double targetCarbs; // in grams
  final double targetFat; // in grams

  DailyNutritionSummary({
    required this.userId,
    required this.date,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
    required this.targetCalories,
    required this.targetProtein,
    required this.targetCarbs,
    required this.targetFat,
  });

  /// Get remaining calories
  double get remainingCalories => targetCalories - totalCalories;

  /// Get remaining protein
  double get remainingProtein => targetProtein - totalProtein;

  /// Get remaining carbs
  double get remainingCarbs => targetCarbs - totalCarbs;

  /// Get remaining fat
  double get remainingFat => targetFat - totalFat;

  /// Get calories percentage
  double get caloriesPercentage => (totalCalories / targetCalories) * 100;

  /// Get protein percentage
  double get proteinPercentage => (totalProtein / targetProtein) * 100;

  /// Get carbs percentage
  double get carbsPercentage => (totalCarbs / targetCarbs) * 100;

  /// Get fat percentage
  double get fatPercentage => (totalFat / targetFat) * 100;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': date.toIso8601String(),
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFat': totalFat,
      'targetCalories': targetCalories,
      'targetProtein': targetProtein,
      'targetCarbs': targetCarbs,
      'targetFat': targetFat,
    };
  }

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFat: (json['totalFat'] as num).toDouble(),
      targetCalories: (json['targetCalories'] as num).toDouble(),
      targetProtein: (json['targetProtein'] as num).toDouble(),
      targetCarbs: (json['targetCarbs'] as num).toDouble(),
      targetFat: (json['targetFat'] as num).toDouble(),
    );
  }
}


