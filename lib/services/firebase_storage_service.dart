import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../core/config/app_config.dart';

/// Firebase Storage service for file uploads
class FirebaseStorageService {
  FirebaseStorage? _storage;

  FirebaseStorageService() {
    if (AppConfig.kUseFirebaseBackend) {
      _storage = FirebaseStorage.instance;
    }
  }

  /// Upload food image
  Future<String> uploadFoodImage({
    required String userId,
    required File imageFile,
    required String mealId,
  }) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('uploadFoodImage() skipped (local-only mode)');
      return 'local://food_image_$mealId.jpg';
    }

    try {
      final ref = _storage!
          .ref()
          .child(AppConstants.foodImagesPath)
          .child(userId)
          .child('$mealId.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error in uploadFoodImage: $e');
      throw Exception('Failed to upload food image: $e');
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('uploadProfileImage() skipped (local-only mode)');
      return 'local://profile_image_$userId.jpg';
    }

    try {
      final ref = _storage!
          .ref()
          .child(AppConstants.profileImagesPath)
          .child('$userId.jpg');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error in uploadProfileImage: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete image
  Future<void> deleteImage(String imageUrl) async {
    if (!AppConfig.kUseFirebaseBackend) {
      debugPrint('deleteImage() skipped (local-only mode)');
      return;
    }

    try {
      final ref = _storage!.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error in deleteImage: $e');
      throw Exception('Failed to delete image: $e');
    }
  }
}
