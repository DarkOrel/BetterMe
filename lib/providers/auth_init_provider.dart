import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_providers.dart';

/// Provider that ensures Firebase Auth is initialized with an anonymous user
/// This runs on app startup to ensure there's always an authenticated user
final authInitProvider = FutureProvider<void>((ref) async {
  final authService = ref.read(firebaseAuthServiceProvider);
  await authService.ensureSignedIn();
});
