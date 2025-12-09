import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/muscle_load_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import 'user_provider.dart';

/// Muscle load provider - streams muscle group training volumes
final muscleLoadProvider = StreamProvider<Map<String, MuscleLoadModel>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    return Stream.value({});
  }

  return firestore.streamMuscleLoads(null);
});

/// Muscle load state provider for saving muscle load data
final muscleLoadStateProvider = StateNotifierProvider<MuscleLoadNotifier, AsyncValue<void>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  
  return MuscleLoadNotifier(firestore);
});

/// Muscle load notifier for state management
class MuscleLoadNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestore;

  MuscleLoadNotifier(this._firestore) : super(const AsyncValue.data(null));

  /// Save muscle load data
  /// Uses current authenticated user's UID from FirestoreService
  Future<void> saveMuscleLoad(MuscleLoadModel muscleLoad) async {
    try {
      state = const AsyncValue.loading();
      // Pass null to let FirestoreService use _getCurrentUserId()
      await _firestore.saveMuscleLoad(null, muscleLoad);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}




