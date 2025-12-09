import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

/// Experience level selection step widget
class OnboardingExperienceStep extends StatelessWidget {
  final String? selectedLevel;
  final Function(String) onLevelSelected;

  const OnboardingExperienceStep({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
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
              'What is your experience level?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _ExperienceOption(
              label: 'Beginner',
              description: 'New to strength training',
              value: AppConstants.beginner,
              isSelected: selectedLevel == AppConstants.beginner,
              onTap: () => onLevelSelected(AppConstants.beginner),
            ),
            const SizedBox(height: 16),
            _ExperienceOption(
              label: 'Intermediate',
              description: '1-2 years of experience',
              value: AppConstants.intermediate,
              isSelected: selectedLevel == AppConstants.intermediate,
              onTap: () => onLevelSelected(AppConstants.intermediate),
            ),
            const SizedBox(height: 16),
            _ExperienceOption(
              label: 'Advanced',
              description: '3+ years of experience',
              value: AppConstants.advanced,
              isSelected: selectedLevel == AppConstants.advanced,
              onTap: () => onLevelSelected(AppConstants.advanced),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceOption extends StatelessWidget {
  final String label;
  final String description;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExperienceOption({
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




