import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile model
class UserModel {
  final String uid;
  final String? email;
  final String gender; // 'male' or 'female'
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final String experienceLevel; // 'beginner', 'intermediate', 'advanced'
  final String goal; // 'muscle_gain', 'fat_loss', 'maintain'
  final int workoutsPerWeek; // 2-6
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    this.email,
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.experienceLevel,
    required this.goal,
    required this.workoutsPerWeek,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON (works for both local storage and Firestore)
  Map<String, dynamic> toJson({bool forFirestore = false}) {
    final json = {
      'uid': uid,
      'email': email,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'experienceLevel': experienceLevel,
      'goal': goal,
      'workoutsPerWeek': workoutsPerWeek,
    };

    if (forFirestore) {
      json['createdAt'] = Timestamp.fromDate(createdAt);
      json['updatedAt'] = updatedAt != null ? Timestamp.fromDate(updatedAt!) : null;
    } else {
      json['createdAt'] = createdAt.toIso8601String();
      json['updatedAt'] = updatedAt?.toIso8601String();
    }

    return json;
  }

  /// Create from JSON (works for both local storage and Firestore)
  factory UserModel.fromJson(Map<String, dynamic> json) {
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

    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      gender: json['gender'] as String,
      age: json['age'] as int,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      experienceLevel: json['experienceLevel'] as String,
      goal: json['goal'] as String,
      workoutsPerWeek: json['workoutsPerWeek'] as int,
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? gender,
    int? age,
    double? height,
    double? weight,
    String? experienceLevel,
    String? goal,
    int? workoutsPerWeek,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      goal: goal ?? this.goal,
      workoutsPerWeek: workoutsPerWeek ?? this.workoutsPerWeek,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Calculate BMI
  double get bmi {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }
}




