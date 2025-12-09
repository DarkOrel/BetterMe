import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/onboarding_gender_step.dart';
import '../widgets/onboarding_basic_info_step.dart';
import '../widgets/onboarding_experience_step.dart';
import '../widgets/onboarding_goal_step.dart';
import '../widgets/onboarding_frequency_step.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../services/nutrition_calculator_service.dart';
import '../../../../services/ppl_generator_service.dart';
import '../../../../providers/local_storage_provider.dart';

/// Onboarding page with multi-step form
class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _currentStep = 0;
  bool _isLoading = false;
  
  // Form data
  String? _gender;
  int? _age;
  double? _height;
  double? _weight;
  String? _experienceLevel;
  String? _goal;
  int? _workoutsPerWeek;

  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    // Validate form data first
    if (_gender == null ||
        _age == null ||
        _height == null ||
        _weight == null ||
        _experienceLevel == null ||
        _goal == null ||
        _workoutsPerWeek == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    // Sign in anonymously with Firebase to get a real user UID
    final authService = ref.read(firebaseAuthServiceProvider);
    User? firebaseUser = authService.currentUser;
    
    // If no current user, sign in anonymously
    if (firebaseUser == null) {
      firebaseUser = await authService.signInAnonymously();
      if (firebaseUser == null) {
        // If sign-in failed, show error and return
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to authenticate. Please try again.'),
            ),
          );
        }
        return;
      }
    }

    // Create user model with Firebase user UID
    final userModel = UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      gender: _gender!,
      age: _age!,
      height: _height!,
      weight: _weight!,
      experienceLevel: _experienceLevel!,
      goal: _goal!,
      workoutsPerWeek: _workoutsPerWeek!,
      createdAt: DateTime.now(),
    );

    try {
      // Calculate TDEE and nutrition targets
      final nutritionCalc = NutritionCalculatorService();
      final targets = nutritionCalc.getAllTargets(userModel);
      debugPrint('TDEE: ${targets['tdee']}, Calories: ${targets['calories']}');

      // Generate initial PPL program
      final pplGenerator = PPLGeneratorService();
      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weeklyProgram = pplGenerator.generateWeeklyProgram(
        user: userModel,
        weekStart: weekStart,
      );

      // Save user profile (saves to both Firestore and local storage)
      final notifier = ref.read(userProfileStateProvider.notifier);
      await notifier.saveUser(userModel);

      // Save weekly program to local storage
      final localStorage = ref.read(localStorageServiceProvider);
      await localStorage.saveWeeklyProgram(weeklyProgram);
      
      // Refresh user profile provider to ensure router sees updated state
      // This ensures the router redirect logic can check for user profile
      // We await the refresh to ensure the provider has reloaded before navigating
      final _ = await ref.refresh(userProfileProvider.future);
      
      setState(() => _isLoading = false);
      
      // After saving user + program, navigate to the main HomeScreen
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error saving profile (continuing anyway): $e');
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  OnboardingGenderStep(
                    selectedGender: _gender,
                    onGenderSelected: (gender) {
                      setState(() => _gender = gender);
                    },
                  ),
                  OnboardingBasicInfoStep(
                    age: _age,
                    height: _height,
                    weight: _weight,
                    onAgeChanged: (age) => setState(() => _age = age),
                    onHeightChanged: (height) => setState(() => _height = height),
                    onWeightChanged: (weight) => setState(() => _weight = weight),
                  ),
                  OnboardingExperienceStep(
                    selectedLevel: _experienceLevel,
                    onLevelSelected: (level) {
                      setState(() => _experienceLevel = level);
                    },
                  ),
                  OnboardingGoalStep(
                    selectedGoal: _goal,
                    onGoalSelected: (goal) {
                      setState(() => _goal = goal);
                    },
                  ),
                  OnboardingFrequencyStep(
                    selectedFrequency: _workoutsPerWeek,
                    onFrequencySelected: (frequency) {
                      setState(() => _workoutsPerWeek = frequency);
                    },
                  ),
                ],
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: _previousStep,
                      child: const Text('Back'),
                    )
                  else
                    const SizedBox.shrink(),
                  ElevatedButton(
                    onPressed: (_canProceed() && !_isLoading) ? _nextStep : null,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentStep == 4 ? 'Complete' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _gender != null;
      case 1:
        return _age != null && _height != null && _weight != null;
      case 2:
        return _experienceLevel != null;
      case 3:
        return _goal != null;
      case 4:
        return _workoutsPerWeek != null;
      default:
        return false;
    }
  }
}




