import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../services/barcode_scanner_service.dart';
import '../../../../services/openfoodfacts_service.dart';

/// Barcode scan page for food logging
class BarcodeScanPage extends ConsumerStatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  ConsumerState<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends ConsumerState<BarcodeScanPage> {
  bool _isScanning = false;
  String? _scannedBarcode;
  Map<String, dynamic>? _productData;

  Future<void> _scanBarcode() async {
    setState(() {
      _isScanning = true;
      _scannedBarcode = null;
      _productData = null;
    });

    try {
      final scannerService = BarcodeScannerService();
      final barcode = await scannerService.scanOnce();

      if (barcode != null && barcode.isNotEmpty) {
        setState(() => _scannedBarcode = barcode);

        // Try to fetch product data
        final service = OpenFoodFactsService();
        final product = await service.getProductByBarcode(barcode);

        if (product != null && mounted) {
          setState(() => _productData = product);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found in database. Please enter manually.'),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barcode scanning is not yet implemented. Please enter food details manually.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning barcode: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _addToMeal() {
    if (_productData != null) {
      // Navigate to log meal page with pre-filled data
      context.push('/nutrition/log', extra: {
        'foodName': _productData!['name'] ?? '',
        'calories': _productData!['calories']?.toString() ?? '0',
        'protein': _productData!['protein']?.toString() ?? '0',
        'carbs': _productData!['carbs']?.toString() ?? '0',
        'fat': _productData!['fat']?.toString() ?? '0',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanner Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 32),

            // Instructions
            Text(
              'Scan a barcode to quickly add food',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Point your camera at the barcode on the food package',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Scan Button
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _scanBarcode,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.qr_code_scanner),
              label: Text(_isScanning ? 'Scanning...' : 'Scan Barcode'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),

            // Scanned Barcode Info
            if (_scannedBarcode != null) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scanned Barcode',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scannedBarcode!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'monospace',
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Product Data
            if (_productData != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _productData!['name'] ?? 'Unknown Product',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _NutritionRow(
                        label: 'Calories',
                        value: '${_productData!['calories'] ?? 0} kcal',
                      ),
                      const Divider(),
                      _NutritionRow(
                        label: 'Protein',
                        value: '${_productData!['protein'] ?? 0} g',
                      ),
                      const Divider(),
                      _NutritionRow(
                        label: 'Carbs',
                        value: '${_productData!['carbs'] ?? 0} g',
                      ),
                      const Divider(),
                      _NutritionRow(
                        label: 'Fat',
                        value: '${_productData!['fat'] ?? 0} g',
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addToMeal,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text('Add to Meal'),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

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

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}


