import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/workout/presentation/pages/workout_page.dart';
import '../../features/workout/presentation/pages/exercise_detail_page.dart';
import '../../features/muscle_map/presentation/pages/muscle_map_page.dart';
import '../../features/nutrition/presentation/pages/nutrition_page.dart';
import '../../features/nutrition/presentation/pages/log_meal_page.dart';
import '../../features/nutrition/presentation/pages/barcode_scan_page.dart';
import '../../features/nutrition/presentation/pages/meal_photo_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/body/presentation/pages/body_screen.dart';
import '../../features/exercises/presentation/pages/exercises_screen.dart';
import '../../features/exercises/presentation/pages/edit_exercise_screen.dart';
import '../../features/workouts/presentation/pages/my_workouts_screen.dart';
import '../../features/workouts/presentation/pages/edit_workout_screen.dart';
import '../../features/workouts/presentation/pages/start_workout_screen.dart';
import '../../core/models/muscle_group.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_init_provider.dart';
import '../../core/config/app_config.dart';

/// Router provider for navigation
final routerProvider = Provider<GoRouter>((ref) {
  // Ensure Firebase Auth is initialized with anonymous user on startup
  ref.watch(authInitProvider);
  
  final authState = ref.watch(authStateProvider);
  final userProfileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/body',
    redirect: (BuildContext context, GoRouterState state) {
      // Allow access to body screen and new features without profile check
      final isBody = state.matchedLocation == '/body';
      final isExercises = state.matchedLocation.startsWith('/exercises');
      final isWorkouts = state.matchedLocation.startsWith('/workouts');
      
      if (isBody || isExercises || isWorkouts) {
        return null; // Allow access
      }

      // Check if user profile exists (works for both local and Firebase modes)
      // userProfileAsync is a FutureProvider, so we check if it has a value
      final hasUserProfile = userProfileAsync.hasValue && userProfileAsync.value != null;
      // Also check auth state for Firebase mode
      final isAuthenticated = authState.value != null;
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isHome = state.matchedLocation == '/home';

      // If user profile exists and we're on onboarding, redirect to body screen
      if (hasUserProfile && isOnboarding) {
        return '/body';
      }

      // If no user profile and trying to access home (and provider has finished loading), redirect to onboarding
      // Allow navigation to home if provider is still loading (might be completing onboarding)
      if (!hasUserProfile && isHome && userProfileAsync.hasValue) {
        return '/onboarding';
      }

      // If no user profile and not on onboarding/home (and provider has finished loading), redirect to onboarding
      if (!hasUserProfile && !isOnboarding && !isHome && !isBody && !isExercises && !isWorkouts && userProfileAsync.hasValue) {
        return '/onboarding';
      }

      // For Firebase mode, also check auth state
      if (AppConfig.kUseFirebaseBackend) {
        if (!isAuthenticated && !isOnboarding && !isBody && !isExercises && !isWorkouts) {
          return '/onboarding';
        }
        if (isAuthenticated && isOnboarding) {
          return '/body';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/workout',
        name: 'workout',
        builder: (context, state) => const WorkoutPage(),
        routes: [
          GoRoute(
            path: 'exercise/:id',
            name: 'exercise-detail',
            builder: (context, state) {
              final exerciseId = state.pathParameters['id']!;
              return ExerciseDetailPage(exerciseId: exerciseId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/muscle-map',
        name: 'muscle-map',
        builder: (context, state) => const MuscleMapPage(),
      ),
      GoRoute(
        path: '/nutrition',
        name: 'nutrition',
        builder: (context, state) => const NutritionPage(),
        routes: [
          GoRoute(
            path: 'log',
            name: 'log-meal',
            builder: (context, state) {
              // Handle extra data if passed
              final extra = state.extra as Map<String, dynamic>?;
              return LogMealPage(prefilledData: extra);
            },
          ),
          GoRoute(
            path: 'barcode',
            name: 'barcode-scan',
            builder: (context, state) => const BarcodeScanPage(),
          ),
          GoRoute(
            path: 'photo',
            name: 'meal-photo',
            builder: (context, state) => const MealPhotoPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      // New body/exercises/workouts routes
      GoRoute(
        path: '/body',
        name: 'body',
        builder: (context, state) => const BodyScreen(),
      ),
      GoRoute(
        path: '/exercises',
        name: 'exercises',
        redirect: (context, state) => '/body', // Redirect to body if accessing /exercises directly
        routes: [
          GoRoute(
            path: ':muscleGroupName',
            name: 'exercises-by-group',
            builder: (context, state) {
              final muscleGroupName = state.pathParameters['muscleGroupName']!;
              return ExercisesScreen(muscleGroupName: muscleGroupName);
            },
          ),
          GoRoute(
            path: 'new',
            name: 'new-exercise',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return EditExerciseScreen(
                initialMuscleGroup: extra?['muscleGroup'] as MuscleGroup?,
              );
            },
          ),
          GoRoute(
            path: 'edit/:exerciseId',
            name: 'edit-exercise',
            builder: (context, state) {
              final exerciseId = state.pathParameters['exerciseId']!;
              return EditExerciseScreen(exerciseId: exerciseId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/workouts',
        name: 'workouts',
        builder: (context, state) => const MyWorkoutsScreen(),
        routes: [
          GoRoute(
            path: 'new',
            name: 'new-workout',
            builder: (context, state) => const EditWorkoutScreen(),
          ),
          GoRoute(
            path: ':workoutId',
            name: 'workout-detail',
            builder: (context, state) {
              final workoutId = state.pathParameters['workoutId']!;
              if (workoutId == 'new') {
                return const EditWorkoutScreen();
              }
              return EditWorkoutScreen(workoutId: workoutId);
            },
            routes: [
              GoRoute(
                path: 'start',
                name: 'start-workout',
                builder: (context, state) {
                  final workoutId = state.pathParameters['workoutId']!;
                  return StartWorkoutScreen(workoutId: workoutId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

