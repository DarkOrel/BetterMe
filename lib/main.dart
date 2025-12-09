import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/repositories/exercise_repository.dart';
import 'core/repositories/workout_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize repositories
  final exerciseRepo = ExerciseRepository();
  await exerciseRepo.init();
  await exerciseRepo.seedDefaultsIfNeeded();

  final workoutRepo = WorkoutRepository();
  await workoutRepo.init();

  // Initialize Firebase once only
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    // Ignore duplicate-app errors (can happen on hot restart in debug)
    if (e.code != 'duplicate-app') {
      debugPrint('Firebase initialization error (non-fatal): ${e.code} - ${e.message}');
      // Continue app startup even if Firebase init fails
    }
  } catch (e) {
    debugPrint('Unexpected error during Firebase initialization (non-fatal): $e');
    // Continue app startup even if Firebase init fails
  }

  runApp(
    const ProviderScope(
      child: FitnessAIApp(),
    ),
  );
}

/// Main application widget
class FitnessAIApp extends ConsumerWidget {
  const FitnessAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Fitness AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}




