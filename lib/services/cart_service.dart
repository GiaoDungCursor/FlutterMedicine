import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/medicine.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => _items.isEmpty;

  // Add medicine to cart
  void addToCart(Medicine medicine, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.medicine.id == medicine.id,
    );

    if (existingIndex >= 0) {
      // Update quantity if already in cart
      _items[existingIndex].quantity += quantity;
    } else {
      // Add new item
      _items.add(CartItem(medicine: medicine, quantity: quantity));
    }

    notifyListeners();
  }

  // Remove item from cart
  void removeFromCart(String medicineId) {
    _items.removeWhere((item) => item.medicine.id == medicineId);
    notifyListeners();
  }

  // Update quantity
  void updateQuantity(String medicineId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(medicineId);
      return;
    }

    final index = _items.indexWhere((item) => item.medicine.id == medicineId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get item by medicine ID
  CartItem? getItem(String medicineId) {
    try {
      return _items.firstWhere((item) => item.medicine.id == medicineId);
    } catch (e) {
      return null;
    }
  }
}

