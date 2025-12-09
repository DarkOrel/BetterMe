/// Food item model (template/catalog item)
class FoodItem {
  final String id;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g; // in grams
  final double carbsPer100g; // in grams
  final double fatPer100g; // in grams
  final String? barcode;
  final String? imageUrl;
  final String? brand;

  FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.barcode,
    this.imageUrl,
    this.brand,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'carbsPer100g': carbsPer100g,
      'fatPer100g': fatPer100g,
      'barcode': barcode,
      'imageUrl': imageUrl,
      'brand': brand,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      caloriesPer100g: (json['caloriesPer100g'] as num).toDouble(),
      proteinPer100g: (json['proteinPer100g'] as num).toDouble(),
      carbsPer100g: (json['carbsPer100g'] as num).toDouble(),
      fatPer100g: (json['fatPer100g'] as num).toDouble(),
      barcode: json['barcode'] as String?,
      imageUrl: json['imageUrl'] as String?,
      brand: json['brand'] as String?,
    );
  }
}


