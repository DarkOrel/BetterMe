import 'package:dio/dio.dart';
import '../core/constants/app_constants.dart';

/// Service for interacting with OpenFoodFacts API
class OpenFoodFactsService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.openFoodFactsBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Get product information by barcode
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final response = await _dio.get('/product/$barcode.json');

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final product = response.data['product'] as Map<String, dynamic>;
        
        // Extract nutrition information
        final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
        
        return {
          'name': product['product_name'] ?? product['product_name_en'] ?? 'Unknown',
          'calories': (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
          'protein': (nutriments['proteins_100g'] ?? 0).toDouble(),
          'carbs': (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
          'fat': (nutriments['fat_100g'] ?? 0).toDouble(),
          'imageUrl': product['image_url'] ?? product['image_front_url'],
          'barcode': barcode,
        };
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Search products by name
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/cgi/search.pl',
        queryParameters: {
          'search_terms': query,
          'search_simple': 1,
          'action': 'process',
          'json': 1,
          'page_size': 20,
        },
      );

      if (response.statusCode == 200) {
        final products = response.data['products'] as List<dynamic>? ?? [];
        return products.map((product) {
          final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
          return {
            'name': product['product_name'] ?? 'Unknown',
            'calories': (nutriments['energy-kcal_100g'] ?? 0).toDouble(),
            'protein': (nutriments['proteins_100g'] ?? 0).toDouble(),
            'carbs': (nutriments['carbohydrates_100g'] ?? 0).toDouble(),
            'fat': (nutriments['fat_100g'] ?? 0).toDouble(),
            'imageUrl': product['image_url'] ?? product['image_front_url'],
            'barcode': product['code'],
          };
        }).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}




