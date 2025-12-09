import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../core/config/app_config.dart';
import 'auth_provider.dart';
import 'local_storage_provider.dart';

/// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Current user profile provider
/// Tries Firestore first (if enabled), falls back to local storage
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final localStorage = ref.watch(localStorageServiceProvider);
  
  if (AppConfig.kUseFirebaseBackend) {
    // Try Firestore first
    final firestore = ref.watch(firestoreServiceProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser != null) {
      try {
        final user = await firestore.getUser(currentUser.uid);
        if (user != null) {
          return user;
        }
      } catch (e) {
        // If Firestore fails, fall back to local storage
      }
    }
  }
  
  // Fall back to local storage (works for both modes)
  return await localStorage.getUser();
});

/// User profile state provider (for mutations)
final userProfileStateProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  
  // currentUser is now a User? from Firebase Auth
  final userId = currentUser?.uid;
  
  return UserProfileNotifier(firestore, localStorage, userId);
});

/// User profile notifier for state management
class UserProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final FirestoreService _firestore;
  final LocalStorageService _localStorage;
  final String? _userId;

  UserProfileNotifier(this._firestore, this._localStorage, this._userId)
      : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      state = const AsyncValue.loading();
      
      UserModel? user;
      
      if (AppConfig.kUseFirebaseBackend && _userId != null) {
        // Try Firestore first
        try {
          user = await _firestore.getUser(_userId!);
        } catch (e) {
          // If Firestore fails, fall back to local storage
        }
      }
      
      // Fall back to local storage if Firestore didn't return a user
      user ??= await _localStorage.getUser();
      
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Save user profile
  /// Saves to both Firestore (if enabled) and local storage for offline access
  /// Handles errors gracefully - does not crash UI
  Future<void> saveUser(UserModel user) async {
    try {
      state = const AsyncValue.loading();
      
      // Always save to local storage for offline access
      await _localStorage.saveUser(user);
      
      // Also save to Firestore if Firebase backend is enabled
      // FirestoreService will log errors but not throw
      if (AppConfig.kUseFirebaseBackend) {
        await _firestore.saveUser(user);
      }
      
      state = AsyncValue.data(user);
    } catch (e) {
      debugPrint('Error in saveUser (non-fatal): $e');
      // Still set state to data to allow UI to continue
      state = AsyncValue.data(user);
    }
  }

  /// Update user profile
  /// Handles errors gracefully - does not crash UI
  Future<void> updateUser(UserModel user) async {
    try {
      state = const AsyncValue.loading();
      
      if (!AppConfig.kUseFirebaseBackend) {
        // Use local storage
        await _localStorage.saveUser(user);
      } else {
        // Use Firestore (will log errors but not throw)
        await _firestore.updateUser(user);
      }
      
      state = AsyncValue.data(user);
    } catch (e) {
      debugPrint('Error in updateUser (non-fatal): $e');
      // Still set state to data to allow UI to continue
      state = AsyncValue.data(user);
    }
  }
}




