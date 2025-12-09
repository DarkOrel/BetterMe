import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/firebase_providers.dart';
import '../../../../providers/user_provider.dart';

/// Profile page displaying user information and settings
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: userProfileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile data'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          profile.gender == 'male' ? 'M' : 'F',
                          style: const TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'User Profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        profile.email ?? 'No email',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile details
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Gender'),
                      trailing: Text(profile.gender.toUpperCase()),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.cake),
                      title: const Text('Age'),
                      trailing: Text('${profile.age} years'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.height),
                      title: const Text('Height'),
                      trailing: Text('${profile.height} cm'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.monitor_weight),
                      title: const Text('Weight'),
                      trailing: Text('${profile.weight} kg'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.trending_up),
                      title: const Text('BMI'),
                      trailing: Text(profile.bmi.toStringAsFixed(1)),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.fitness_center),
                      title: const Text('Experience'),
                      trailing: Text(profile.experienceLevel.toUpperCase()),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.flag),
                      title: const Text('Goal'),
                      trailing: Text(profile.goal.replaceAll('_', ' ').toUpperCase()),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Workouts per Week'),
                      trailing: Text('${profile.workoutsPerWeek}'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Actions
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // Navigate to edit profile
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        context.push('/settings');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                      onTap: () async {
                        final authService = ref.read(firebaseAuthServiceProvider);
                        await authService.signOut();
                        if (context.mounted) {
                          context.go('/onboarding');
                        }
                      },
                    ),
                  ],
                ),
              ),


              // Subscription placeholder
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Premium Features',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('Unlock advanced AI features'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Show subscription paywall
                        },
                        child: const Text('Subscribe'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}




