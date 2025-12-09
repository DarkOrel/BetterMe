import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Meal photo page for food logging via image recognition
class MealPhotoPage extends ConsumerStatefulWidget {
  const MealPhotoPage({super.key});

  @override
  ConsumerState<MealPhotoPage> createState() => _MealPhotoPageState();
}

class _MealPhotoPageState extends ConsumerState<MealPhotoPage> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analyzedData;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _analyzedData = null;
        });

        // Analyze image (stubbed for now)
        _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    // TODO: Call AI service to analyze food image
    // For now, return mock data
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _analyzedData = {
          'foods': [
            {
              'name': 'Chicken Breast',
              'calories': 231,
              'protein': 43.5,
              'carbs': 0,
              'fat': 5.0,
            },
            {
              'name': 'Rice',
              'calories': 130,
              'protein': 2.7,
              'carbs': 28,
              'fat': 0.3,
            },
          ],
        };
      });
    }
  }

  void _addToMeal(Map<String, dynamic> food) {
    context.push('/nutrition/log', extra: {
      'foodName': food['name'] ?? '',
      'calories': food['calories']?.toString() ?? '0',
      'protein': food['protein']?.toString() ?? '0',
      'carbs': food['carbs']?.toString() ?? '0',
      'fat': food['fat']?.toString() ?? '0',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Meal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Preview
            if (_selectedImage != null)
              Card(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Card(
                child: Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No image selected',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Choose from Gallery'),
                  ),
                ),
              ],
            ),

            // Analyzing Indicator
            if (_isAnalyzing) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Analyzing image...'),
            ],

            // Analyzed Results
            if (_analyzedData != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              Text(
                'Detected Foods',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...(_analyzedData!['foods'] as List<dynamic>).map((food) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(food['name'] ?? 'Unknown'),
                    subtitle: Text(
                      '${food['calories']} kcal • ${food['protein']}g protein',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addToMeal(food as Map<String, dynamic>),
                    ),
                  ),
                );
              }).toList(),
            ],

            const SizedBox(height: 24),

            // Info Text
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'AI food recognition is currently in development. Results may vary.',
                        style: TextStyle(color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Manual Entry Option
            TextButton(
              onPressed: () => context.push('/nutrition/log'),
              child: const Text('Enter Manually Instead'),
            ),
          ],
        ),
      ),
    );
  }
}


