import 'package:cloud_firestore/cloud_firestore.dart';

/// Meal model representing a logged meal/food item
class MealModel {
  final String id;
  final String userId;
  final String foodName;
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final String? imageUrl;
  final String? barcode;
  final DateTime date;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final DateTime createdAt;

  MealModel({
    required this.id,
    required this.userId,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
    this.barcode,
    required this.date,
    required this.mealType,
    required this.createdAt,
  });

  /// Convert to JSON (works for both local storage and Firestore)
  Map<String, dynamic> toJson({bool forFirestore = false}) {
    final json = {
      'id': id,
      'userId': userId,
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'mealType': mealType,
    };

    if (forFirestore) {
      json['date'] = Timestamp.fromDate(date);
      json['createdAt'] = Timestamp.fromDate(createdAt);
    } else {
      json['date'] = date.toIso8601String();
      json['createdAt'] = createdAt.toIso8601String();
    }

    return json;
  }

  /// Create from JSON (works for both local storage and Firestore)
  factory MealModel.fromJson(Map<String, dynamic> json) {
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

    return MealModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      foodName: json['foodName'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      barcode: json['barcode'] as String?,
      date: parseDate(json['date']),
      mealType: json['mealType'] as String,
      createdAt: parseDate(json['createdAt']),
    );
  }

  /// Create a copy with updated fields
  MealModel copyWith({
    String? id,
    String? userId,
    String? foodName,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? imageUrl,
    String? barcode,
    DateTime? date,
    String? mealType,
    DateTime? createdAt,
  }) {
    return MealModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}




