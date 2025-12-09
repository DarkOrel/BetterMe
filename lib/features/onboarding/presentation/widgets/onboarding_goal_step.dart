import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Goal selection step widget
class OnboardingGoalStep extends StatelessWidget {
  final String? selectedGoal;
  final Function(String) onGoalSelected;

  const OnboardingGoalStep({
    super.key,
    required this.selectedGoal,
    required this.onGoalSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'What is your goal?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _GoalOption(
              label: 'Muscle Gain',
              description: 'Build muscle and strength',
              value: AppConstants.muscleGain,
              isSelected: selectedGoal == AppConstants.muscleGain,
              onTap: () => onGoalSelected(AppConstants.muscleGain),
            ),
            const SizedBox(height: 16),
            _GoalOption(
              label: 'Fat Loss',
              description: 'Lose weight and burn fat',
              value: AppConstants.fatLoss,
              isSelected: selectedGoal == AppConstants.fatLoss,
              onTap: () => onGoalSelected(AppConstants.fatLoss),
            ),
            const SizedBox(height: 16),
            _GoalOption(
              label: 'Maintain',
              description: 'Maintain current physique',
              value: AppConstants.maintain,
              isSelected: selectedGoal == AppConstants.maintain,
              onTap: () => onGoalSelected(AppConstants.maintain),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final String description;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.description,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}




