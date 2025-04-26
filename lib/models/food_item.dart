class FoodItem {
  final String name;
  final String imageUrl;
  final double price;
  final int preparationTime;
  final int availableQuantity;
  final bool isAvailable;

  FoodItem({
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.preparationTime,
    required this.availableQuantity,
    required this.isAvailable,
  });

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      price: (map['price'] as num).toDouble(),
      preparationTime: map['preparationTime'] as int,
      availableQuantity: map['availableQuantity'] as int,
      isAvailable: map['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'preparationTime': preparationTime,
      'availableQuantity': availableQuantity,
      'isAvailable': isAvailable,
    };
  }
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final bool isFreeDelivery;
  final int deliveryTime;
  final List<String> cuisine;
  final List<FoodItem> menu;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.isFreeDelivery,
    required this.deliveryTime,
    required this.cuisine,
    required this.menu,
  });
} 