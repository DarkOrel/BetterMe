import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../models/meal_model.dart';
import '../../../../providers/nutrition_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../services/openfoodfacts_service.dart';
import '../../../../services/firebase_storage_service.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/barcode_scanner_service.dart';

/// Log meal page for adding food items
class LogMealPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? prefilledData;

  const LogMealPage({super.key, this.prefilledData});

  @override
  ConsumerState<LogMealPage> createState() => _LogMealPageState();
}

class _LogMealPageState extends ConsumerState<LogMealPage> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  
  String? _selectedMealType = 'breakfast';
  File? _selectedImage;
  String? _barcode;
  bool _isLoading = false;

  final _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  @override
  void initState() {
    super.initState();
    // Pre-fill data if provided
    if (widget.prefilledData != null) {
      final data = widget.prefilledData!;
      _foodNameController.text = data['foodName'] ?? '';
      _caloriesController.text = data['calories'] ?? '';
      _proteinController.text = data['protein'] ?? '';
      _carbsController.text = data['carbs'] ?? '';
      _fatController.text = data['fat'] ?? '';
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    try {
      final scannerService = BarcodeScannerService();
      final barcode = await scannerService.scanOnce();

      if (barcode != null && barcode.isNotEmpty) {
        setState(() {
          _barcode = barcode;
          _isLoading = true;
        });

        final service = OpenFoodFactsService();
        final product = await service.getProductByBarcode(barcode);

        if (product != null && mounted) {
          _foodNameController.text = product['name'] ?? '';
          _caloriesController.text = product['calories']?.toString() ?? '';
          _proteinController.text = product['protein']?.toString() ?? '';
          _carbsController.text = product['carbs']?.toString() ?? '';
          _fatController.text = product['fat']?.toString() ?? '';
        }

        setState(() => _isLoading = false);
      } else {
        // Barcode scanning not implemented yet or was canceled
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Barcode scanning is not yet implemented. Please enter food details manually.'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning barcode: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isLoading = true;
        });

        // Upload image and analyze
        final currentUser = ref.read(currentUserProvider);
        if (currentUser != null) {
          final storageService = FirebaseStorageService();
          final imageUrl = await storageService.uploadFoodImage(
            userId: currentUser.uid,
            imageFile: _selectedImage!,
            mealId: DateTime.now().millisecondsSinceEpoch.toString(),
          );

          final aiService = AIService();
          final results = await aiService.analyzeFoodImage(imageUrl: imageUrl);

          if (results.isNotEmpty && mounted) {
            final firstResult = results.first;
            _foodNameController.text = firstResult['name'] ?? '';
            _caloriesController.text = firstResult['calories']?.toString() ?? '';
            _proteinController.text = firstResult['protein']?.toString() ?? '';
            _carbsController.text = firstResult['carbs']?.toString() ?? '';
            _fatController.text = firstResult['fat']?.toString() ?? '';
          }
        }

        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        final storageService = FirebaseStorageService();
        imageUrl = await storageService.uploadFoodImage(
          userId: currentUser.uid,
          imageFile: _selectedImage!,
          mealId: DateTime.now().millisecondsSinceEpoch.toString(),
        );
      }

      final meal = MealModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser.uid,
        foodName: _foodNameController.text,
        calories: double.parse(_caloriesController.text),
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fat: double.parse(_fatController.text),
        imageUrl: imageUrl,
        barcode: _barcode,
        date: DateTime.now(),
        mealType: _selectedMealType!,
        createdAt: DateTime.now(),
      );

      final notifier = ref.read(nutritionStateProvider.notifier);
      await notifier.saveMeal(meal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal saved!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Meal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick actions
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _scanBarcode,
                            icon: const Icon(Icons.qr_code_scanner),
                            label: const Text('Scan Barcode'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Meal type
                    DropdownButtonFormField<String>(
                      value: _selectedMealType,
                      decoration: const InputDecoration(
                        labelText: 'Meal Type',
                        border: OutlineInputBorder(),
                      ),
                      items: _mealTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedMealType = value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Food name
                    TextFormField(
                      controller: _foodNameController,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter food name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Macros
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _caloriesController,
                            decoration: const InputDecoration(
                              labelText: 'Calories',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _proteinController,
                            decoration: const InputDecoration(
                              labelText: 'Protein (g)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _carbsController,
                            decoration: const InputDecoration(
                              labelText: 'Carbs (g)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _fatController,
                            decoration: const InputDecoration(
                              labelText: 'Fat (g)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    ElevatedButton(
                      onPressed: _saveMeal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Meal'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}




