import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({
    required this.foodItem,
    this.quantity = 1,
  });

  double get total => foodItem.price * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0, (sum, item) => sum + item.total);

  void addItem(FoodItem foodItem) {
    final existingIndex = _items.indexWhere((item) => item.foodItem.name == foodItem.name);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(foodItem: foodItem));
    }
    notifyListeners();
  }

  void removeItem(String foodName) {
    _items.removeWhere((item) => item.foodItem.name == foodName);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void updateQuantity(String foodName, int newQuantity) {
    final index = _items.indexWhere((item) => item.foodItem.name == foodName);
    if (index >= 0) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
} 